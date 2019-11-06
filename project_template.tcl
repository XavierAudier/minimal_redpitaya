# Commands are available here :
# https://www.xilinx.com/support/documentation/sw_manuals/xilinx2013_4/ug835-vivado-tcl-commands.pdf

# defining variables
set project_name "my_project"
# The name of the fpga board for the redpitaya
set part_name xc7z010clg400-1 

# creating subfolder for the project block design sources
set bd_path tmp/$project_name/$project_name.srcs/sources_1/bd/system

# delete the whole project folder before adding anything
file delete -force tmp/$project_name

# create new project
create_project $project_name tmp/$project_name -part $part_name

# create main block design 
create_bd_design system

# The script has just initialized the repository to put all the files that will be generated.
# Only the Zynq7 part bname has been given, but everything still needs to be set correctly.


# Load initial RedPitaya ports
source config/init_ports_setup.tcl
# The GUI should just show input and output ports right now.


# Set Path for the custom IP cores
# In order to do that you should have already created the usable IP from the sources, and put them in the folder tmp/custom_ip
#set_property IP_REPO_PATHS tmp/custom_ip [current_project]
update_ip_catalog


# Now we start adding blocks to the block design

# Zynq processing system with RedPitaya specific preset
startgroup
create_bd_cell -type ip -vlnv xilinx.com:ip:processing_system7 processing_system7_0
set_property -dict [list CONFIG.PCW_USE_S_AXI_HP0 {1}] [get_bd_cells processing_system7_0]
# importing the settings from seperate file
set_property -dict [list CONFIG.PCW_IMPORT_BOARD_PRESET {config/red_pitaya_presets.xml}] [get_bd_cells processing_system7_0]
endgroup

# Differential IOs nee a buffer
startgroup
create_bd_cell -type ip -vlnv xilinx.com:ip:util_ds_buf util_ds_buf_1
set_property -dict [list CONFIG.C_SIZE {2}] [get_bd_cells util_ds_buf_1]
create_bd_cell -type ip -vlnv xilinx.com:ip:util_ds_buf util_ds_buf_2
set_property -dict [list CONFIG.C_SIZE {2}] [get_bd_cells util_ds_buf_2]
set_property -dict [list CONFIG.C_BUF_TYPE {OBUFDS}] [get_bd_cells util_ds_buf_2]
endgroup


# Up to here we have done the minimal requirements in terms of blocks.
# However the M_AXI and S_AXI need to have some clock wiring.
connect_bd_net [get_bd_pins processing_system7_0/M_AXI_GP0_ACLK] [get_bd_pins processing_system7_0/FCLK_CLK0]
connect_bd_net [get_bd_pins processing_system7_0/S_AXI_HP0_ACLK] [get_bd_pins processing_system7_0/FCLK_CLK0]
# Additionally, the SATA connector needs to have connections
connect_bd_net [get_bd_ports daisy_p_i] [get_bd_pins util_ds_buf_1/IBUF_DS_P]
connect_bd_net [get_bd_ports daisy_n_i] [get_bd_pins util_ds_buf_1/IBUF_DS_N]
connect_bd_net [get_bd_ports daisy_p_o] [get_bd_pins util_ds_buf_2/OBUF_DS_P]
connect_bd_net [get_bd_ports daisy_n_o] [get_bd_pins util_ds_buf_2/OBUF_DS_N]
connect_bd_net [get_bd_pins util_ds_buf_1/IBUF_OUT] [get_bd_pins util_ds_buf_2/OBUF_IN]



# The code shoudl work just fine, since it's doing nothing.
# We still need to write the current design into the .BD file.
# ====================================================================================
# Generate output products and wrapper, add constraint any any additional files 
# We can now generate the block design, and the files that will be used for simulation and future implementations.
generate_target all [get_files  $bd_path/system.bd]

# We create the wrapper
make_wrapper -files [get_files $bd_path/system.bd] -top
# We add the generated system wrapper to the list of files
add_files -norecurse $bd_path/hdl/system_wrapper.v

# Load any additional Verilog files in the project folder
#set files [glob -nocomplain additional_v_sources/*.v additional_v_sources/*.sv]
#if {[llength $files] > 0} {
#  add_files -norecurse $files
#}

# Load RedPitaya constraint files
set files [glob -nocomplain config/*.xdc]
if {[llength $files] > 0} {
  add_files -norecurse -fileset constrs_1 $files
}


# Updates the Vivado tools given the current file set
set_property VERILOG_DEFINE {TOOL_VIVADO} [current_fileset]

# Set comfiguration to run the synthesis and the implementation
set_property STRATEGY Flow_PerfOptimized_High [get_runs synth_1]
set_property STRATEGY Performance_NetDelay_high [get_runs impl_1]


# Generate bitstream 
launch_runs synth_1 -jobs 6
launch_runs impl_1 -to_step write_bitstream -jobs 6
# If a run fails, use the reset_run command
#reset_run impl_1