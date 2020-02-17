#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <sys/types.h>
#include <inttypes.h>

#include <fcntl.h>
#include <sys/mman.h>
#include <unistd.h>
#include <errno.h>

#include "keyboard.h"
#include "sockets.h"
#include "fifo.h"

// must be moved from quartus and gen
#include "hps_0.h"
#include "d_common.h"
#include "dmalloc.h"

#define EDS

#ifdef EDS
#include "hwlib.h"
#include "socal/socal.h"
#include "socal/hps.h"
#include "socal/alt_gpio.h"
#else
#define ALT_LWFPGASLVS_OFST   0
#define ALT_STM_OFST 0
#endif

#define HW_REGS_BASE ( ALT_STM_OFST )
#define HW_REGS_SPAN ( 0x04000000 )
#define HW_REGS_MASK ( HW_REGS_SPAN - 1 )


#define linescan_bytes_size (2592*6)
#define size_dma_alloc (linescan_bytes_size * 4096 * 3)
#define size_dma_alloc_words (size_dma_alloc >> 2)


#define BA_CTRL_REG     0x0000
#define BA_STATUS_REG   0x0020
#define BA_TIMER_REG    0x0040

#define BA_DMA_BUS_SIZE 0x0100
#define BA_DMA_ADDR     0x0110
#define BA_DMA_STATUS   0x0120

#define BA_LED_CLK_R    0x0200
#define BA_LED_CLK_G    0x0210
#define BA_LED_CLK_B    0x0220
#define BA_LINES_DELAY  0x0230
#define BA_PULSES_DECIM 0x0240

#define BA_ENCODER_CNT  0x0260

//bits of control register
#define CTRL_BIT_RST        0
#define CTRL_BIT_RST_CIS    1
#define CTRL_BIT_DMA        2
#define CTRL_BIT_CIS_MODE   4

//bits of status register
#define STS_BIT_PIX_FIFO_OVR        0
#define STS_BIT_DMA_FIFO_CMD_EMPTY  1
#define STS_BIT_DMA_FIFO_CMD_AEMPTY 2


#define SET_REG(adr,val) *((uint32_t *) (virtual_base + ( ( unsigned long  )( ALT_LWFPGASLVS_OFST + adr )  & ( unsigned long)( HW_REGS_MASK )))) = val
#define GET_REG(adr) *((uint32_t *) (virtual_base + ( ( unsigned long  )( ALT_LWFPGASLVS_OFST + adr )  & ( unsigned long)( HW_REGS_MASK ))))

#define SET_CTRL_REG(val) SET_REG(BA_CTRL_REG, val)
#define GET_CTRL_REG() GET_REG(BA_CTRL_REG)
#define GET_STATUS_REG() GET_REG(BA_STATUS_REG)

#define GET_TIMER_REG() GET_REG(BA_TIMER_REG)
#define GET_ENCODER_CNT_REG() GET_REG(BA_ENCODER_CNT)

#define SET_LED_CLK_R(val) SET_REG(BA_LED_CLK_R, val)
#define SET_LED_CLK_G(val) SET_REG(BA_LED_CLK_G, val)
#define SET_LED_CLK_B(val) SET_REG(BA_LED_CLK_B, val)

#define SET_LINES_DELAY(val) SET_REG(BA_LINES_DELAY, val)
#define SET_PULSES_DECIM(val) SET_REG(BA_PULSES_DECIM, val)

#define SET_RST() SET_CTRL_REG(GET_CTRL_REG() |  (1 << CTRL_BIT_RST))
#define CLR_RST() SET_CTRL_REG(GET_CTRL_REG() & ~(1 << CTRL_BIT_RST))

#define SET_RST_CIS() SET_CTRL_REG(GET_CTRL_REG() |  (1 << CTRL_BIT_RST_CIS))
#define CLR_RST_CIS() SET_CTRL_REG(GET_CTRL_REG() & ~(1 << CTRL_BIT_RST_CIS))


#define CIS_MODE_CONTINUOUS 0
#define CIS_MODE_BURST      1
#define CIS_MODE_EVENT      2

#define CIS_MODE CIS_MODE_EVENT
#define LINES_DELAY 4*2592          //delay in clock cycles
#define PULSES_DECIMATION 1               //decimation for encoder pulses

#define NETWORK
//host IP
char *s_addr = "192.168.1.1";



int fd, fd_dma;
volatile uint32_t *dma_alloc;
//uint32_t *dma_alloc;
void *virtual_base;



void sdma_write_cmd(uint32_t start_adr, uint32_t buffer_size)
{
    SET_REG(BA_DMA_ADDR, start_adr);
    SET_REG(BA_DMA_BUS_SIZE, buffer_size);
    
    SET_CTRL_REG(GET_CTRL_REG() |  (1 << CTRL_BIT_DMA));
    //printf("simple dma started adr=%x\n",start_adr);
    SET_CTRL_REG(GET_CTRL_REG() &  ~(1 << CTRL_BIT_DMA));
}

uint16_t sdma_get_bufs_cnt()
{
    return GET_REG(BA_DMA_STATUS);
}

//Set how many DMA channels works. For correct buffers addressing
#define DMA_CNT 3

//Select DMA channel (0-2) for transmitting to host
#define DMA_SEL 0


//request DMA some buffers cnt. And while DMAs ready transmit buffers to host.
void simple_dma_process(uint32_t adr)
{
  const uint32_t CMD_FIFO_SIZE = 8;
  //const uint32_t CMD_FIFO_SIZE = 1;

  const uint32_t buf_size_bytes = linescan_bytes_size*512;

  const uint32_t buf_size_words = buf_size_bytes >> 2; 
  const uint32_t buf_size_dma   = buf_size_bytes >> 4;
  uint32_t buf_adr_dma = adr;
  uint32_t read_idx = 0;
  uint32_t fifo_slots_free = CMD_FIFO_SIZE;
  uint32_t buffers_cnt = 0, buffers_cnt_prev = 0, released_buffers_cnt = 0;

  uint32_t idx_in_dma_alloc = 0;
  uint32_t written_cmds = 0;
  
  uint32_t test_buffers_cnt = 2;
  //uint32_t test_buffers_cnt = 1000000;
  
  while(buffers_cnt < test_buffers_cnt)
  {
    //while(fifo_slots_free > 0 )
    while((fifo_slots_free > 0) && (written_cmds < test_buffers_cnt))
    {
      buf_adr_dma = adr + idx_in_dma_alloc * buf_size_dma;
      //printf("***%d\n", idx_in_dma_alloc * buf_size_dma);
      sdma_write_cmd(buf_adr_dma, buf_size_dma);
      //buf_adr_dma += buf_size_dma;
      
      fifo_slots_free--;

      if(((idx_in_dma_alloc + DMA_CNT) * buf_size_dma) >= (size_dma_alloc >> 4))
      {
        idx_in_dma_alloc = 0;
      }
      else
      {
        //idx_in_dma_alloc++;
        idx_in_dma_alloc += DMA_CNT;      //beecose 3 DMA
      }
        written_cmds++;
    }

    buffers_cnt = sdma_get_bufs_cnt();

    released_buffers_cnt = buffers_cnt - buffers_cnt_prev;
    buffers_cnt_prev = buffers_cnt;

    if(released_buffers_cnt)
    {
        //if(buffers_cnt % 128 == 0)
            printf("done %d buffers\n\r", buffers_cnt);

        //printf("released_buffers_cnt=%d\n", released_buffers_cnt);
        msync((void *)dma_alloc,size_dma_alloc, MS_SYNC);
        fifo_slots_free += released_buffers_cnt;

        //printf("released_buffers_cnt = %d\n", released_buffers_cnt);
        //printf("read_idx = %X\n", read_idx);

#ifdef NETWORK
        //socket_send(&dma_alloc[read_idx], (released_buffers_cnt*buf_size_words) << 2);
        //socket_send(&dma_alloc[read_idx], ((released_buffers_cnt*buf_size_words) << 2)*DMA_CNT);
        socket_send(&dma_alloc[read_idx + released_buffers_cnt * buf_size_words*DMA_SEL], released_buffers_cnt*buf_size_bytes);
#endif
      //
        //read_idx += (released_buffers_cnt * buf_size_words);
        read_idx += (released_buffers_cnt * buf_size_words)*DMA_CNT;
        
        if(read_idx >= size_dma_alloc_words)
          read_idx -= size_dma_alloc_words;
    }
  }
  printf("done %d buffers\n\r", sdma_get_bufs_cnt());
}




//request DMA some buffers cnt, wait it. And then transmit to host.
void simple_dma_buf_collect(uint32_t adr)
{
  const uint32_t CMD_FIFO_SIZE = 8;
  //const uint32_t CMD_FIFO_SIZE = 1;

  const uint32_t buf_size_bytes = linescan_bytes_size*512;

  const uint32_t buf_size_dma   = buf_size_bytes >> 4;
  uint32_t buf_adr_dma = adr;
  uint32_t fifo_slots_free = CMD_FIFO_SIZE;
  uint32_t buffers_cnt = 0, buffers_cnt_prev = 0, released_buffers_cnt = 0;

  uint32_t idx_in_dma_alloc = 0;
  uint32_t written_cmds = 0;
  
  uint32_t test_buffers_cnt = 2;
  //uint32_t test_buffers_cnt = 1000000;
  
  while(buffers_cnt < test_buffers_cnt)
  {
    while((fifo_slots_free > 0) && (written_cmds < test_buffers_cnt))
    {
      buf_adr_dma = adr + idx_in_dma_alloc * buf_size_dma;
      sdma_write_cmd(buf_adr_dma, buf_size_dma);
      
      fifo_slots_free--;

      if(((idx_in_dma_alloc + DMA_CNT) * buf_size_dma) >= (size_dma_alloc >> 4))
      {
        idx_in_dma_alloc = 0;
      }
      else
      {
        idx_in_dma_alloc += DMA_CNT;      //beecose 3 DMA
      }
        written_cmds++;
    }

    buffers_cnt = sdma_get_bufs_cnt();

    released_buffers_cnt = buffers_cnt - buffers_cnt_prev;
    buffers_cnt_prev = buffers_cnt;

    if(released_buffers_cnt)
    {
      fifo_slots_free += released_buffers_cnt;
    }
  }


  msync((void *)dma_alloc,size_dma_alloc, MS_SYNC);

#ifdef NETWORK
  socket_send(&dma_alloc[0], test_buffers_cnt*buf_size_bytes*DMA_CNT);
#endif
  
  printf("done %d buffers\n\r", sdma_get_bufs_cnt());
}

//process DMA channels all time
void dma_process_background(uint32_t adr, char reset, uint32_t buf_size_bytes, uint32_t *adr_done)
{
    const uint32_t CMD_FIFO_SIZE = 7;

    static uint32_t buf_adr_dma;
    static uint32_t fifo_slots_free = 0;

    uint32_t buf_size_dma   = buf_size_bytes >> 4;

    static uint32_t idx_in_dma_alloc = 0;
    uint32_t buffers_cnt = 0, released_buffers_cnt = 0;
    static uint32_t buffers_cnt_prev = 0;

    if(reset)
    {
        fifo_slots_free = CMD_FIFO_SIZE;
        idx_in_dma_alloc = 0;
        buffers_cnt_prev = 0;
        return;
    }

    while(fifo_slots_free > 0 )
    {
        buf_adr_dma = adr + idx_in_dma_alloc * buf_size_dma;
        sdma_write_cmd(buf_adr_dma, buf_size_dma);
        
        if(fifo_put(buf_adr_dma))
        {
            printf("fifo_put(): adr fifo overflow!!!\n\r");
        }

        fifo_slots_free--;

        if(((idx_in_dma_alloc + DMA_CNT) * buf_size_dma) >= (size_dma_alloc >> 4))
        {
            idx_in_dma_alloc = 0;
        }
        else
        {
            idx_in_dma_alloc += DMA_CNT;      
        }

    }

    buffers_cnt = sdma_get_bufs_cnt();
    released_buffers_cnt = buffers_cnt - buffers_cnt_prev;
    buffers_cnt_prev = buffers_cnt;

    *adr_done = 0;
    if(released_buffers_cnt)
    {
      if(released_buffers_cnt > 1)
        printf("warning: released_buffers_cnt = %d\n\r",released_buffers_cnt);
      
      if(fifo_get(adr_done))
        printf("fifo_get(): adr fifo underflow!!!\n\r");

      //printf("fifo_get(): done adr %X\n\r",*adr_done);
      //printf("buffers_cnt: %d\n\r", buffers_cnt);

      fifo_slots_free += released_buffers_cnt;
    }
}


//process all 3 DMAs and print first 8 words and last 8 words from every DMA buffer channel
void simple_dma_keys(uint32_t adr)
{
  int key = 0; 
  uint32_t adr_done;
  uint32_t buf_size_bytes;

  buf_size_bytes = linescan_bytes_size*512;

  //reset static variables in function
  dma_process_background(0, 1, 0, NULL);
  
  while(key != 'q')
  {
    if(get_key(&key))
    {
        switch(key)
        {
            case 'd'    :   usleep(1*1000*1000);    //make delay to see fifo overflow
                            break;

            default     :   break;
        }
        printf("key %c \n\r", key);
    }

    dma_process_background(adr, 0, buf_size_bytes, &adr_done);

    if(adr_done != 0)
    {
      adr_done -= adr;
      msync((void *)dma_alloc,size_dma_alloc, MS_SYNC);
      printf("adr_done = %X\n\r", adr_done);
      
      //print first 8 and last 8 words in every DMA buffer 
      //DMA 0
      printf("%8X ", dma_alloc[(adr_done << 2) + 0]);
      printf("%8X ", dma_alloc[(adr_done << 2) + 1]);
      printf("%8X ", dma_alloc[(adr_done << 2) + (1*buf_size_bytes >> 2) - 2]);
      printf("%8X ", dma_alloc[(adr_done << 2) + (1*buf_size_bytes >> 2) - 1]);
      printf("\n\r");
      //DMA 1
      printf("%8X ", dma_alloc[(adr_done << 2) + 0 + (1*buf_size_bytes >> 2)]);
      printf("%8X ", dma_alloc[(adr_done << 2) + 1 + (1*buf_size_bytes >> 2)]);
      printf("%8X ", dma_alloc[(adr_done << 2) + (2*buf_size_bytes >> 2)-2]);
      printf("%8X ", dma_alloc[(adr_done << 2) + (2*buf_size_bytes >> 2)-1]);
      printf("\n\r");
      //DMA 2
      printf("%8X ", dma_alloc[(adr_done << 2) + 0 + (2*buf_size_bytes >> 2)]);
      printf("%8X ", dma_alloc[(adr_done << 2) + 1 + (2*buf_size_bytes >> 2)]);
      printf("%8X ", dma_alloc[(adr_done << 2) + (3*buf_size_bytes >> 2)-2]);
      printf("%8X ", dma_alloc[(adr_done << 2) + (3*buf_size_bytes >> 2)-1]);
      printf("\n\r");

      printf("\n\r\n\r");
    }
    
    if(GET_STATUS_REG() & 0x1)  //detect pixel fifo overflow
    {
        printf("pixel fifo overflow! \n\r");
        break;
    }
  }
}


void test_rgb()
{
  uint32_t i;

  CLR_RST();
  CLR_RST_CIS();

  while(1)
  {
    for(i = 0; i < 3; i++)
    {
      switch(i)
      {
        case 0 : 
            SET_LED_CLK_R((0 << 16) | 100);
            SET_LED_CLK_G((10 << 16) | 0);
            SET_LED_CLK_B((10 << 16) | 0);
            break;

        case 1 : 
            SET_LED_CLK_R((10 << 16) | 0);
            SET_LED_CLK_G((0 << 16) | 100);
            SET_LED_CLK_B((10 << 16) | 0);
            break;

        case 2 : 
            SET_LED_CLK_R((10 << 16) | 0);
            SET_LED_CLK_G((10 << 16) | 0);
            SET_LED_CLK_B((0 << 16) | 100);
            break;

        default:  SET_LED_CLK_R((10 << 16) | 0);
                  SET_LED_CLK_G((10 << 16) | 0);
                  SET_LED_CLK_B((10 << 16) | 0);
                  break;
      }
      usleep(500*1000);
    }
  }
  SET_RST_CIS();
}


void test_encoder()
{
  CLR_RST();

  while(1)
  {
    printf("encoder cnt: %d \n\r", GET_ENCODER_CNT_REG());
    usleep(500*1000);
  }
}


#define BUF_SIZE 2592*6*1
uint32_t buf[BUF_SIZE >> 2];

void test_send_socket()
{
    //uint32_t size = (linescan_bytes_size*1024);
  uint32_t size = BUF_SIZE;
    printf("start test_send_socket(), size(words) = %d\n", size);
    //dma_alloc = buf;
    while(1)
    {
        socket_send(&dma_alloc[0], size);
      //socket_send(buf, size);
        //usleep(50);
    }
}

int main( int argc, char *argv[] ) 
{
  

  set_conio_terminal_mode();

  fd_dma = dminit();
  fd = open( "/dev/mem", O_RDWR | O_SYNC );
  if( fd < 0 || fd_dma < 0) {
    perror( "open" );
    exit( -1 );
  }

  dma_alloc = mmap(0, size_dma_alloc, PROT_READ | PROT_WRITE, MAP_SHARED | MAP_LOCKED , fd_dma, 0);

  virtual_base = mmap( 0, HW_REGS_SPAN, PROT_READ | PROT_WRITE, MAP_SHARED, fd, HW_REGS_BASE );
  if( virtual_base == MAP_FAILED ) {
    perror( "mmap" );
    return 1;
  }
  //printf("ALT_LWFPGASLVS_OFST: 0x%x\n\r", ALT_LWFPGASLVS_OFST);



  SET_LINES_DELAY(LINES_DELAY);
  SET_PULSES_DECIM(PULSES_DECIMATION);
  SET_CTRL_REG(0x3 | (CIS_MODE << CTRL_BIT_CIS_MODE));

  
  printf("timer: %d\n\r", GET_TIMER_REG());

  //test_rgb();

  //test_encoder();

  //SET_RST();
  //SET_RST_CIS();

  uint32_t addr = (uint32_t) dphysaddr();
  if(addr == 0){
    printf("error get addr");
    return 1;
  }
  uint32_t calc_addr = ((uint32_t) addr >> 4);// return 

#ifdef NETWORK
  socket_connect(s_addr);
  //test_send_socket();
#endif

/////////////////////////////
//  SET_LED_CLK_R(LED_OFF << 16 | LED_ON)
/////////////////////////////

  // SET_LED_CLK_R((50 << 16) | 100);
  // SET_LED_CLK_G((1 << 16) | 100);
  // SET_LED_CLK_B((1 << 16) | 100);

  
  //full white
  SET_LED_CLK_R((180 << 16) | 100);
  SET_LED_CLK_G((110 << 16) | 100);
  SET_LED_CLK_B((310 << 16) | 100);

  // SET_LED_CLK_R((40 << 16) | 0);
  // SET_LED_CLK_G((40 << 16) | 0);
  // SET_LED_CLK_B((40 << 16) | 0);

  // SET_LED_CLK_R((0 << 16) | 10);
  // SET_LED_CLK_G((0 << 16) | 10);
  // SET_LED_CLK_B((0 << 16) | 10);

  
  
  CLR_RST();
  CLR_RST_CIS();
  //SET_CTRL_REG(0x0);
  printf("status reg %X\n\r", GET_STATUS_REG());
  
//test prcesses
  simple_dma_process(calc_addr);
  //simple_dma_buf_collect(calc_addr);
  //simple_dma_keys(calc_addr);
//
  
  printf("timer: %d\n\r", GET_TIMER_REG());

  SET_RST();
  SET_RST_CIS();




  if( munmap( virtual_base, HW_REGS_SPAN ) ) {// hw_regs size connect map
    perror( "munmap" );
    exit( -1 ); 
  }

  if( munmap ((void *)dma_alloc, size_dma_alloc) ) {// hw_regs size connect map
    perror( "munmap 2" );
    exit( -1 ); 
  }



  close(fd);
  close(fd_dma);
  socket_close();
  
  printf("exit\n\r");
  return 0;
}


/*
insmod dma_alloc.ko
LD_LIBRARY_PATH=/usr/arm-linux-gnueabihf/lib/
export LD_LIBRARY_PATH
*/