#**************************************************************
# Create Clock
#**************************************************************
create_clock -period "50.0 MHz" [get_ports FPGA_CLK1_50]
#create_clock -period "50.0 MHz" [get_ports FPGA_CLK2_50]
#create_clock -period "50.0 MHz" [get_ports FPGA_CLK3_50]

# for enhancing USB BlasterII to be reliable, 25MHz
create_clock -name {altera_reserved_tck} -period 40 {altera_reserved_tck}
set_input_delay -clock altera_reserved_tck -clock_fall 3 [get_ports altera_reserved_tdi]
set_input_delay -clock altera_reserved_tck -clock_fall 3 [get_ports altera_reserved_tms]
set_output_delay -clock altera_reserved_tck 3 [get_ports altera_reserved_tdo]

derive_pll_clocks
set_max_delay -from [get_clocks u0|pll_0|altera_pll_i|general[0].gpll~PLL_OUTPUT_COUNTER|divclk] -to [get_clocks u0|pll_0|altera_pll_i|general[2].gpll~PLL_OUTPUT_COUNTER|divclk ] 3.9