# Lab1 Part0

Follow this [document](https://docs.google.com/document/d/1AEyVnDq-EX87BF8rP6L7kGDFoxXFHFT3Fsqeemnlcyk/edit?usp=sharing) from lab0 to request an interactive desktop and setup experiment environment (you do not need to run step7 and step8 in the lab0 instruction).

Then, run `source /storage/ice-shared/cs3220/labs_setup.sh` in your terminal.

## Ready to run?
Step 0: go back to home folder and then download the testing file from repo 
```
cd ~
git clone https://github.com/gt-cs3220-2026/cs3220-labs-sp2026.git
```

Step 1: Change to the path of part0 and compile the verilog module of **adder_var_seq**. 
```
cd cs3220-labs-sp2026/lab1/part0
verilator --cc adder_var_seq.v --top-module adder_var_seq
```

Step 2: Compile the executable file
```
verilator -Wall --trace --exe --build -cc adder_var_seq.cpp adder_var_seq.v
```

Step 3: Run the exectuable file and obtain the waveform file (.vcd)
```
./obj_dir/Vadder_var_seq
```

Step 4: Open the GTKWave to visualize the generated trace:

```
# in your terminal, type in
gtkwave
```

open "File" -> "Open New Tab" -> "Select the generated waveform.vcd" -> "click Open" -> "click on TOP" -> "Right click the signals below " -> "Recurse Import" -> "Append" -> "Yes".
Then all waveforms will show up in the Waves window.
