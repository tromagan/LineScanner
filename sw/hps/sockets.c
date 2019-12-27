#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <string.h>

#include <sys/socket.h>
#include <sys/types.h>
#include <netinet/in.h>
#include <arpa/inet.h>

#include "sockets.h"


const char *s_addr = "192.168.0.215";   //server adr
//const char *s_addr = "192.168.1.1";   //server adr
const uint16_t  i_port = 2592;          //server port

int s = -1;

uint32_t socket_connect()
{
    printf("Create socket\n");
    s = socket(AF_INET, SOCK_STREAM, 0);
    if (s < 0) 
    {
      printf("create socket error\n");
      return 1;
    }


    struct sockaddr_in server_addr;
    memset(&server_addr, 0, sizeof(server_addr));
    server_addr.sin_family = AF_INET;
    server_addr.sin_addr.s_addr = inet_addr(s_addr);
    server_addr.sin_port = htons(i_port);

    printf("Trying connect\n");
    if (connect(s, (struct sockaddr *)&server_addr, sizeof(server_addr)) < 0) {
        printf("connect failed\n");
        return 1;
    }

    return 0;
}


uint32_t socket_send(volatile uint32_t *buf, uint32_t size_bytes)
{
  write(s, (void *)buf, size_bytes); 
  return 0;
}

void socket_close()
{
    if(s > 0)
        close(s);
}