	component soc is
		port (
			bus_clk_clk                     : out   std_logic;                                         -- clk
			ctrl_reg_in_port                : in    std_logic_vector(31 downto 0)  := (others => 'X'); -- in_port
			ctrl_reg_out_port               : out   std_logic_vector(31 downto 0);                     -- out_port
			dma_adr_export                  : out   std_logic_vector(31 downto 0);                     -- export
			dma_buf_size_export             : out   std_logic_vector(31 downto 0);                     -- export
			dma_status_export               : in    std_logic_vector(31 downto 0)  := (others => 'X'); -- export
			hps_io_hps_io_emac1_inst_TX_CLK : out   std_logic;                                         -- hps_io_emac1_inst_TX_CLK
			hps_io_hps_io_emac1_inst_TXD0   : out   std_logic;                                         -- hps_io_emac1_inst_TXD0
			hps_io_hps_io_emac1_inst_TXD1   : out   std_logic;                                         -- hps_io_emac1_inst_TXD1
			hps_io_hps_io_emac1_inst_TXD2   : out   std_logic;                                         -- hps_io_emac1_inst_TXD2
			hps_io_hps_io_emac1_inst_TXD3   : out   std_logic;                                         -- hps_io_emac1_inst_TXD3
			hps_io_hps_io_emac1_inst_RXD0   : in    std_logic                      := 'X';             -- hps_io_emac1_inst_RXD0
			hps_io_hps_io_emac1_inst_MDIO   : inout std_logic                      := 'X';             -- hps_io_emac1_inst_MDIO
			hps_io_hps_io_emac1_inst_MDC    : out   std_logic;                                         -- hps_io_emac1_inst_MDC
			hps_io_hps_io_emac1_inst_RX_CTL : in    std_logic                      := 'X';             -- hps_io_emac1_inst_RX_CTL
			hps_io_hps_io_emac1_inst_TX_CTL : out   std_logic;                                         -- hps_io_emac1_inst_TX_CTL
			hps_io_hps_io_emac1_inst_RX_CLK : in    std_logic                      := 'X';             -- hps_io_emac1_inst_RX_CLK
			hps_io_hps_io_emac1_inst_RXD1   : in    std_logic                      := 'X';             -- hps_io_emac1_inst_RXD1
			hps_io_hps_io_emac1_inst_RXD2   : in    std_logic                      := 'X';             -- hps_io_emac1_inst_RXD2
			hps_io_hps_io_emac1_inst_RXD3   : in    std_logic                      := 'X';             -- hps_io_emac1_inst_RXD3
			hps_io_hps_io_sdio_inst_CMD     : inout std_logic                      := 'X';             -- hps_io_sdio_inst_CMD
			hps_io_hps_io_sdio_inst_D0      : inout std_logic                      := 'X';             -- hps_io_sdio_inst_D0
			hps_io_hps_io_sdio_inst_D1      : inout std_logic                      := 'X';             -- hps_io_sdio_inst_D1
			hps_io_hps_io_sdio_inst_CLK     : out   std_logic;                                         -- hps_io_sdio_inst_CLK
			hps_io_hps_io_sdio_inst_D2      : inout std_logic                      := 'X';             -- hps_io_sdio_inst_D2
			hps_io_hps_io_sdio_inst_D3      : inout std_logic                      := 'X';             -- hps_io_sdio_inst_D3
			hps_io_hps_io_usb1_inst_D0      : inout std_logic                      := 'X';             -- hps_io_usb1_inst_D0
			hps_io_hps_io_usb1_inst_D1      : inout std_logic                      := 'X';             -- hps_io_usb1_inst_D1
			hps_io_hps_io_usb1_inst_D2      : inout std_logic                      := 'X';             -- hps_io_usb1_inst_D2
			hps_io_hps_io_usb1_inst_D3      : inout std_logic                      := 'X';             -- hps_io_usb1_inst_D3
			hps_io_hps_io_usb1_inst_D4      : inout std_logic                      := 'X';             -- hps_io_usb1_inst_D4
			hps_io_hps_io_usb1_inst_D5      : inout std_logic                      := 'X';             -- hps_io_usb1_inst_D5
			hps_io_hps_io_usb1_inst_D6      : inout std_logic                      := 'X';             -- hps_io_usb1_inst_D6
			hps_io_hps_io_usb1_inst_D7      : inout std_logic                      := 'X';             -- hps_io_usb1_inst_D7
			hps_io_hps_io_usb1_inst_CLK     : in    std_logic                      := 'X';             -- hps_io_usb1_inst_CLK
			hps_io_hps_io_usb1_inst_STP     : out   std_logic;                                         -- hps_io_usb1_inst_STP
			hps_io_hps_io_usb1_inst_DIR     : in    std_logic                      := 'X';             -- hps_io_usb1_inst_DIR
			hps_io_hps_io_usb1_inst_NXT     : in    std_logic                      := 'X';             -- hps_io_usb1_inst_NXT
			hps_io_hps_io_spim1_inst_CLK    : out   std_logic;                                         -- hps_io_spim1_inst_CLK
			hps_io_hps_io_spim1_inst_MOSI   : out   std_logic;                                         -- hps_io_spim1_inst_MOSI
			hps_io_hps_io_spim1_inst_MISO   : in    std_logic                      := 'X';             -- hps_io_spim1_inst_MISO
			hps_io_hps_io_spim1_inst_SS0    : out   std_logic;                                         -- hps_io_spim1_inst_SS0
			hps_io_hps_io_uart0_inst_RX     : in    std_logic                      := 'X';             -- hps_io_uart0_inst_RX
			hps_io_hps_io_uart0_inst_TX     : out   std_logic;                                         -- hps_io_uart0_inst_TX
			hps_io_hps_io_i2c0_inst_SDA     : inout std_logic                      := 'X';             -- hps_io_i2c0_inst_SDA
			hps_io_hps_io_i2c0_inst_SCL     : inout std_logic                      := 'X';             -- hps_io_i2c0_inst_SCL
			hps_io_hps_io_i2c1_inst_SDA     : inout std_logic                      := 'X';             -- hps_io_i2c1_inst_SDA
			hps_io_hps_io_i2c1_inst_SCL     : inout std_logic                      := 'X';             -- hps_io_i2c1_inst_SCL
			hps_io_hps_io_gpio_inst_GPIO09  : inout std_logic                      := 'X';             -- hps_io_gpio_inst_GPIO09
			hps_io_hps_io_gpio_inst_GPIO35  : inout std_logic                      := 'X';             -- hps_io_gpio_inst_GPIO35
			hps_io_hps_io_gpio_inst_GPIO40  : inout std_logic                      := 'X';             -- hps_io_gpio_inst_GPIO40
			hps_io_hps_io_gpio_inst_GPIO53  : inout std_logic                      := 'X';             -- hps_io_gpio_inst_GPIO53
			hps_io_hps_io_gpio_inst_GPIO54  : inout std_logic                      := 'X';             -- hps_io_gpio_inst_GPIO54
			hps_io_hps_io_gpio_inst_GPIO61  : inout std_logic                      := 'X';             -- hps_io_gpio_inst_GPIO61
			i_pll_0_refclk_50mhz_clk        : in    std_logic                      := 'X';             -- clk
			irq0_irq                        : in    std_logic_vector(31 downto 0)  := (others => 'X'); -- irq
			led_clk_on_blue_export          : out   std_logic_vector(31 downto 0);                     -- export
			led_clk_on_green_export         : out   std_logic_vector(31 downto 0);                     -- export
			led_clk_on_red_export           : out   std_logic_vector(31 downto 0);                     -- export
			lines_delay_export              : out   std_logic_vector(31 downto 0);                     -- export
			memory_mem_a                    : out   std_logic_vector(14 downto 0);                     -- mem_a
			memory_mem_ba                   : out   std_logic_vector(2 downto 0);                      -- mem_ba
			memory_mem_ck                   : out   std_logic;                                         -- mem_ck
			memory_mem_ck_n                 : out   std_logic;                                         -- mem_ck_n
			memory_mem_cke                  : out   std_logic;                                         -- mem_cke
			memory_mem_cs_n                 : out   std_logic;                                         -- mem_cs_n
			memory_mem_ras_n                : out   std_logic;                                         -- mem_ras_n
			memory_mem_cas_n                : out   std_logic;                                         -- mem_cas_n
			memory_mem_we_n                 : out   std_logic;                                         -- mem_we_n
			memory_mem_reset_n              : out   std_logic;                                         -- mem_reset_n
			memory_mem_dq                   : inout std_logic_vector(31 downto 0)  := (others => 'X'); -- mem_dq
			memory_mem_dqs                  : inout std_logic_vector(3 downto 0)   := (others => 'X'); -- mem_dqs
			memory_mem_dqs_n                : inout std_logic_vector(3 downto 0)   := (others => 'X'); -- mem_dqs_n
			memory_mem_odt                  : out   std_logic;                                         -- mem_odt
			memory_mem_dm                   : out   std_logic_vector(3 downto 0);                      -- mem_dm
			memory_oct_rzqin                : in    std_logic                      := 'X';             -- oct_rzqin
			outclk_0_clk                    : out   std_logic;                                         -- clk
			outclk_1_clk                    : out   std_logic;                                         -- clk
			sdram0_address                  : in    std_logic_vector(27 downto 0)  := (others => 'X'); -- address
			sdram0_burstcount               : in    std_logic_vector(7 downto 0)   := (others => 'X'); -- burstcount
			sdram0_waitrequest              : out   std_logic;                                         -- waitrequest
			sdram0_readdata                 : out   std_logic_vector(127 downto 0);                    -- readdata
			sdram0_readdatavalid            : out   std_logic;                                         -- readdatavalid
			sdram0_read                     : in    std_logic                      := 'X';             -- read
			sdram0_writedata                : in    std_logic_vector(127 downto 0) := (others => 'X'); -- writedata
			sdram0_byteenable               : in    std_logic_vector(15 downto 0)  := (others => 'X'); -- byteenable
			sdram0_write                    : in    std_logic                      := 'X';             -- write
			status_reg_export               : in    std_logic_vector(31 downto 0)  := (others => 'X'); -- export
			timer_cnt_export                : in    std_logic_vector(31 downto 0)  := (others => 'X')  -- export
		);
	end component soc;

	u0 : component soc
		port map (
			bus_clk_clk                     => CONNECTED_TO_bus_clk_clk,                     --              bus_clk.clk
			ctrl_reg_in_port                => CONNECTED_TO_ctrl_reg_in_port,                --             ctrl_reg.in_port
			ctrl_reg_out_port               => CONNECTED_TO_ctrl_reg_out_port,               --                     .out_port
			dma_adr_export                  => CONNECTED_TO_dma_adr_export,                  --              dma_adr.export
			dma_buf_size_export             => CONNECTED_TO_dma_buf_size_export,             --         dma_buf_size.export
			dma_status_export               => CONNECTED_TO_dma_status_export,               --           dma_status.export
			hps_io_hps_io_emac1_inst_TX_CLK => CONNECTED_TO_hps_io_hps_io_emac1_inst_TX_CLK, --               hps_io.hps_io_emac1_inst_TX_CLK
			hps_io_hps_io_emac1_inst_TXD0   => CONNECTED_TO_hps_io_hps_io_emac1_inst_TXD0,   --                     .hps_io_emac1_inst_TXD0
			hps_io_hps_io_emac1_inst_TXD1   => CONNECTED_TO_hps_io_hps_io_emac1_inst_TXD1,   --                     .hps_io_emac1_inst_TXD1
			hps_io_hps_io_emac1_inst_TXD2   => CONNECTED_TO_hps_io_hps_io_emac1_inst_TXD2,   --                     .hps_io_emac1_inst_TXD2
			hps_io_hps_io_emac1_inst_TXD3   => CONNECTED_TO_hps_io_hps_io_emac1_inst_TXD3,   --                     .hps_io_emac1_inst_TXD3
			hps_io_hps_io_emac1_inst_RXD0   => CONNECTED_TO_hps_io_hps_io_emac1_inst_RXD0,   --                     .hps_io_emac1_inst_RXD0
			hps_io_hps_io_emac1_inst_MDIO   => CONNECTED_TO_hps_io_hps_io_emac1_inst_MDIO,   --                     .hps_io_emac1_inst_MDIO
			hps_io_hps_io_emac1_inst_MDC    => CONNECTED_TO_hps_io_hps_io_emac1_inst_MDC,    --                     .hps_io_emac1_inst_MDC
			hps_io_hps_io_emac1_inst_RX_CTL => CONNECTED_TO_hps_io_hps_io_emac1_inst_RX_CTL, --                     .hps_io_emac1_inst_RX_CTL
			hps_io_hps_io_emac1_inst_TX_CTL => CONNECTED_TO_hps_io_hps_io_emac1_inst_TX_CTL, --                     .hps_io_emac1_inst_TX_CTL
			hps_io_hps_io_emac1_inst_RX_CLK => CONNECTED_TO_hps_io_hps_io_emac1_inst_RX_CLK, --                     .hps_io_emac1_inst_RX_CLK
			hps_io_hps_io_emac1_inst_RXD1   => CONNECTED_TO_hps_io_hps_io_emac1_inst_RXD1,   --                     .hps_io_emac1_inst_RXD1
			hps_io_hps_io_emac1_inst_RXD2   => CONNECTED_TO_hps_io_hps_io_emac1_inst_RXD2,   --                     .hps_io_emac1_inst_RXD2
			hps_io_hps_io_emac1_inst_RXD3   => CONNECTED_TO_hps_io_hps_io_emac1_inst_RXD3,   --                     .hps_io_emac1_inst_RXD3
			hps_io_hps_io_sdio_inst_CMD     => CONNECTED_TO_hps_io_hps_io_sdio_inst_CMD,     --                     .hps_io_sdio_inst_CMD
			hps_io_hps_io_sdio_inst_D0      => CONNECTED_TO_hps_io_hps_io_sdio_inst_D0,      --                     .hps_io_sdio_inst_D0
			hps_io_hps_io_sdio_inst_D1      => CONNECTED_TO_hps_io_hps_io_sdio_inst_D1,      --                     .hps_io_sdio_inst_D1
			hps_io_hps_io_sdio_inst_CLK     => CONNECTED_TO_hps_io_hps_io_sdio_inst_CLK,     --                     .hps_io_sdio_inst_CLK
			hps_io_hps_io_sdio_inst_D2      => CONNECTED_TO_hps_io_hps_io_sdio_inst_D2,      --                     .hps_io_sdio_inst_D2
			hps_io_hps_io_sdio_inst_D3      => CONNECTED_TO_hps_io_hps_io_sdio_inst_D3,      --                     .hps_io_sdio_inst_D3
			hps_io_hps_io_usb1_inst_D0      => CONNECTED_TO_hps_io_hps_io_usb1_inst_D0,      --                     .hps_io_usb1_inst_D0
			hps_io_hps_io_usb1_inst_D1      => CONNECTED_TO_hps_io_hps_io_usb1_inst_D1,      --                     .hps_io_usb1_inst_D1
			hps_io_hps_io_usb1_inst_D2      => CONNECTED_TO_hps_io_hps_io_usb1_inst_D2,      --                     .hps_io_usb1_inst_D2
			hps_io_hps_io_usb1_inst_D3      => CONNECTED_TO_hps_io_hps_io_usb1_inst_D3,      --                     .hps_io_usb1_inst_D3
			hps_io_hps_io_usb1_inst_D4      => CONNECTED_TO_hps_io_hps_io_usb1_inst_D4,      --                     .hps_io_usb1_inst_D4
			hps_io_hps_io_usb1_inst_D5      => CONNECTED_TO_hps_io_hps_io_usb1_inst_D5,      --                     .hps_io_usb1_inst_D5
			hps_io_hps_io_usb1_inst_D6      => CONNECTED_TO_hps_io_hps_io_usb1_inst_D6,      --                     .hps_io_usb1_inst_D6
			hps_io_hps_io_usb1_inst_D7      => CONNECTED_TO_hps_io_hps_io_usb1_inst_D7,      --                     .hps_io_usb1_inst_D7
			hps_io_hps_io_usb1_inst_CLK     => CONNECTED_TO_hps_io_hps_io_usb1_inst_CLK,     --                     .hps_io_usb1_inst_CLK
			hps_io_hps_io_usb1_inst_STP     => CONNECTED_TO_hps_io_hps_io_usb1_inst_STP,     --                     .hps_io_usb1_inst_STP
			hps_io_hps_io_usb1_inst_DIR     => CONNECTED_TO_hps_io_hps_io_usb1_inst_DIR,     --                     .hps_io_usb1_inst_DIR
			hps_io_hps_io_usb1_inst_NXT     => CONNECTED_TO_hps_io_hps_io_usb1_inst_NXT,     --                     .hps_io_usb1_inst_NXT
			hps_io_hps_io_spim1_inst_CLK    => CONNECTED_TO_hps_io_hps_io_spim1_inst_CLK,    --                     .hps_io_spim1_inst_CLK
			hps_io_hps_io_spim1_inst_MOSI   => CONNECTED_TO_hps_io_hps_io_spim1_inst_MOSI,   --                     .hps_io_spim1_inst_MOSI
			hps_io_hps_io_spim1_inst_MISO   => CONNECTED_TO_hps_io_hps_io_spim1_inst_MISO,   --                     .hps_io_spim1_inst_MISO
			hps_io_hps_io_spim1_inst_SS0    => CONNECTED_TO_hps_io_hps_io_spim1_inst_SS0,    --                     .hps_io_spim1_inst_SS0
			hps_io_hps_io_uart0_inst_RX     => CONNECTED_TO_hps_io_hps_io_uart0_inst_RX,     --                     .hps_io_uart0_inst_RX
			hps_io_hps_io_uart0_inst_TX     => CONNECTED_TO_hps_io_hps_io_uart0_inst_TX,     --                     .hps_io_uart0_inst_TX
			hps_io_hps_io_i2c0_inst_SDA     => CONNECTED_TO_hps_io_hps_io_i2c0_inst_SDA,     --                     .hps_io_i2c0_inst_SDA
			hps_io_hps_io_i2c0_inst_SCL     => CONNECTED_TO_hps_io_hps_io_i2c0_inst_SCL,     --                     .hps_io_i2c0_inst_SCL
			hps_io_hps_io_i2c1_inst_SDA     => CONNECTED_TO_hps_io_hps_io_i2c1_inst_SDA,     --                     .hps_io_i2c1_inst_SDA
			hps_io_hps_io_i2c1_inst_SCL     => CONNECTED_TO_hps_io_hps_io_i2c1_inst_SCL,     --                     .hps_io_i2c1_inst_SCL
			hps_io_hps_io_gpio_inst_GPIO09  => CONNECTED_TO_hps_io_hps_io_gpio_inst_GPIO09,  --                     .hps_io_gpio_inst_GPIO09
			hps_io_hps_io_gpio_inst_GPIO35  => CONNECTED_TO_hps_io_hps_io_gpio_inst_GPIO35,  --                     .hps_io_gpio_inst_GPIO35
			hps_io_hps_io_gpio_inst_GPIO40  => CONNECTED_TO_hps_io_hps_io_gpio_inst_GPIO40,  --                     .hps_io_gpio_inst_GPIO40
			hps_io_hps_io_gpio_inst_GPIO53  => CONNECTED_TO_hps_io_hps_io_gpio_inst_GPIO53,  --                     .hps_io_gpio_inst_GPIO53
			hps_io_hps_io_gpio_inst_GPIO54  => CONNECTED_TO_hps_io_hps_io_gpio_inst_GPIO54,  --                     .hps_io_gpio_inst_GPIO54
			hps_io_hps_io_gpio_inst_GPIO61  => CONNECTED_TO_hps_io_hps_io_gpio_inst_GPIO61,  --                     .hps_io_gpio_inst_GPIO61
			i_pll_0_refclk_50mhz_clk        => CONNECTED_TO_i_pll_0_refclk_50mhz_clk,        -- i_pll_0_refclk_50mhz.clk
			irq0_irq                        => CONNECTED_TO_irq0_irq,                        --                 irq0.irq
			led_clk_on_blue_export          => CONNECTED_TO_led_clk_on_blue_export,          --      led_clk_on_blue.export
			led_clk_on_green_export         => CONNECTED_TO_led_clk_on_green_export,         --     led_clk_on_green.export
			led_clk_on_red_export           => CONNECTED_TO_led_clk_on_red_export,           --       led_clk_on_red.export
			lines_delay_export              => CONNECTED_TO_lines_delay_export,              --          lines_delay.export
			memory_mem_a                    => CONNECTED_TO_memory_mem_a,                    --               memory.mem_a
			memory_mem_ba                   => CONNECTED_TO_memory_mem_ba,                   --                     .mem_ba
			memory_mem_ck                   => CONNECTED_TO_memory_mem_ck,                   --                     .mem_ck
			memory_mem_ck_n                 => CONNECTED_TO_memory_mem_ck_n,                 --                     .mem_ck_n
			memory_mem_cke                  => CONNECTED_TO_memory_mem_cke,                  --                     .mem_cke
			memory_mem_cs_n                 => CONNECTED_TO_memory_mem_cs_n,                 --                     .mem_cs_n
			memory_mem_ras_n                => CONNECTED_TO_memory_mem_ras_n,                --                     .mem_ras_n
			memory_mem_cas_n                => CONNECTED_TO_memory_mem_cas_n,                --                     .mem_cas_n
			memory_mem_we_n                 => CONNECTED_TO_memory_mem_we_n,                 --                     .mem_we_n
			memory_mem_reset_n              => CONNECTED_TO_memory_mem_reset_n,              --                     .mem_reset_n
			memory_mem_dq                   => CONNECTED_TO_memory_mem_dq,                   --                     .mem_dq
			memory_mem_dqs                  => CONNECTED_TO_memory_mem_dqs,                  --                     .mem_dqs
			memory_mem_dqs_n                => CONNECTED_TO_memory_mem_dqs_n,                --                     .mem_dqs_n
			memory_mem_odt                  => CONNECTED_TO_memory_mem_odt,                  --                     .mem_odt
			memory_mem_dm                   => CONNECTED_TO_memory_mem_dm,                   --                     .mem_dm
			memory_oct_rzqin                => CONNECTED_TO_memory_oct_rzqin,                --                     .oct_rzqin
			outclk_0_clk                    => CONNECTED_TO_outclk_0_clk,                    --             outclk_0.clk
			outclk_1_clk                    => CONNECTED_TO_outclk_1_clk,                    --             outclk_1.clk
			sdram0_address                  => CONNECTED_TO_sdram0_address,                  --               sdram0.address
			sdram0_burstcount               => CONNECTED_TO_sdram0_burstcount,               --                     .burstcount
			sdram0_waitrequest              => CONNECTED_TO_sdram0_waitrequest,              --                     .waitrequest
			sdram0_readdata                 => CONNECTED_TO_sdram0_readdata,                 --                     .readdata
			sdram0_readdatavalid            => CONNECTED_TO_sdram0_readdatavalid,            --                     .readdatavalid
			sdram0_read                     => CONNECTED_TO_sdram0_read,                     --                     .read
			sdram0_writedata                => CONNECTED_TO_sdram0_writedata,                --                     .writedata
			sdram0_byteenable               => CONNECTED_TO_sdram0_byteenable,               --                     .byteenable
			sdram0_write                    => CONNECTED_TO_sdram0_write,                    --                     .write
			status_reg_export               => CONNECTED_TO_status_reg_export,               --           status_reg.export
			timer_cnt_export                => CONNECTED_TO_timer_cnt_export                 --            timer_cnt.export
		);

