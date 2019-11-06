This respository aims to have a minimal redpitaya project under Vivado.

## Create a new project with Red Pitaya constraints
Proceed as follow:
- Change "source.txt" to match your vivado installation and project directory.
- Open Vivado
- Use the TCL command line
- Copy the lines in "source.txt" to initialize Vivado and set the working directory
- Copy the lines in "project_template.tcl":
	- Either one by one, reading the comments to ensure you understand each part of the procedure.
	- Or in bulk directly in the TCL command line by typing "source project_template.tcl".

## Explanations
The file "project_template.tcl" contains the minimal tcl commands to create a working Red Pitaya project.
This project will do nothing but it will generate a bit stream, which is a good start for anyone getting started with Vivado and Red Pitaya.

The script does the following:
- Creates a new project based on the red pitaya hardware (Zynq-7 : xc7z010clg400-1)
- Creates a subfolder "tmp" to store all the files generated automatically.
- Loads the Red Pitaya ports and add them to the Block Design (file "config/init_ports_setup.tcl")
(- Loads any custom ip that one may have built in "tmp/custom_ip ", if the lines are uncommented)
- Adds the Zynq-7 processing system block
- Adds the SATA buffer blocks
- Wires the clock and the SATA buffers to ensure that the constraints are satisfied later
- Generates all the files required for synthesis and implementation
(- Loads any additional Verilog files in the folder "additional_v_sources", if the lines are uncommented)
- Loads the Red Pitaya constraints (files "config/clocks.xdc" and "config/ports.xdc")
- Sets up the synthesis and implementation runs (synth_1 and impl_1)
- Starts the synthesis, implementation, and bit stream generation


## Continue
The bit stream will be generated in the implementation subfolder (tmp\my_project\my_project.runs\impl_1).
The file is "system_wrapper.bit"
You can copy it to your Red Pitaya root folder and launch it using the usual command:
"cat /opt/redpitaya/fpga/fpga_0.94.bit > /dev/xdevcfg"

## Acknowledgements
This small repository is a minimal version of the much more interesting one by Anton Potočnik : https://github.com/apotocnik/redpitaya_guide
Make sure you check out his great tutorials on his website : http://antonpotocnik.com/?cat=29

For more advanced tutorials make sure you look at Pavel Demin's work as well : 
pavel-demin.github.io/red-pitaya-notes/
https://github.com/pavel-demin/red-pitaya-notes

The Red Pitaya Github repository is there : https://github.com/RedPitaya/RedPitaya
The documentation (not very interesting for begginners however) : https://redpitaya.readthedocs.io/en/latest/quickStart/quickStart.html
