## Generated SDC file "n64advanced.sdc"

## Copyright (C) 2017  Intel Corporation. All rights reserved.
## Your use of Intel Corporation's design tools, logic functions 
## and other software and tools, and its AMPP partner logic 
## functions, and any output files from any of the foregoing 
## (including device programming or simulation files), and any 
## associated documentation or information are expressly subject 
## to the terms and conditions of the Intel Program License 
## Subscription Agreement, the Intel Quartus Prime License Agreement,
## the Intel MegaCore Function License Agreement, or other 
## applicable license agreement, including, without limitation, 
## that your use is for the sole purpose of programming logic 
## devices manufactured by Intel and sold by Intel or its 
## authorized distributors.  Please refer to the applicable 
## agreement for further details.


## VENDOR  "Altera"
## PROGRAM "Quartus Prime"
## VERSION "Version 17.0.1 Build 598 06/07/2017 SJ Lite Edition"

## DATE    "Tue Jul 04 21:09:02 2017"

##
## DEVICE  "10M02SCE144C8G"
##


#**************************************************************
# Time Information
#**************************************************************

set_time_format -unit ns -decimal_places 3



#**************************************************************
# Create Clock
#**************************************************************

create_clock -name {VCLK} -period 20.000 -waveform { 0.000 10.000 } [get_ports { VCLK }]
create_clock -name {SYS_CLK} -period 20.000 -waveform { 0.000 10.000 } [get_ports { SYS_CLK }]


#**************************************************************
# Create Generated Clock
#**************************************************************

derive_pll_clocks -use_net_name -create_base_clocks


#**************************************************************
# Set Clock Latency
#**************************************************************



#**************************************************************
# Set Clock Uncertainty
#**************************************************************

derive_clock_uncertainty


#**************************************************************
# Set Input Delay
#**************************************************************

set_input_delay -clock { VCLK } -min 5.4 [get_ports {nDSYNC}]
set_input_delay -clock { VCLK } -max 6.4 [get_ports {nDSYNC}]
set_input_delay -clock { VCLK } -min 5.4 [get_ports {D_i[*]}]
set_input_delay -clock { VCLK } -max 6.4  [get_ports {D_i[*]}]


#**************************************************************
# Set Output Delay
#**************************************************************

set_output_delay -clock { n64a_linedbl:linedoubler|altpll_0:vid_pll|altpll:altpll_component|altpll_0_altpll:auto_generated|wire_pll1_clk[0] } -max 0.2 [get_ports {V1_o* V2_o* V3_o* nCSYNC_ADV712x}] -add
set_output_delay -clock { n64a_linedbl:linedoubler|altpll_0:vid_pll|altpll:altpll_component|altpll_0_altpll:auto_generated|wire_pll1_clk[0] } -min -1.5 [get_ports {V1_o* V2_o* V3_o* nCSYNC_ADV712x}] -add


#**************************************************************
# Set Clock Groups
#**************************************************************



#**************************************************************
# Set False Path
#**************************************************************



#**************************************************************
# Set Multicycle Path
#**************************************************************



#**************************************************************
# Set Maximum Delay
#**************************************************************



#**************************************************************
# Set Minimum Delay
#**************************************************************



#**************************************************************
# Set Input Transition
#**************************************************************
