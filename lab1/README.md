# CS3220 Lab #1 : Pipeline Design 

100 pts in total, will be rescaled into 15% of your final score of the course.  

**Part 1**: 50 pts

**Part 2**: 50 pts

**Part 3 (Optional)**: 20 bonus pts

***Submission ddl***: Feb 9

**Description**:
In this assignment, you will create a 5-stage RISC-V pipelined processor using Verilog, focusing on a subset of the RISC-V ISA. We will be using the Tiny RISC-V version from Cornell, which is provided in the [Tiny RISC-V ISA](tinyrv-isa.txt) file. 

In part 0, you will familiarize yourself with the essential software tools required for the experiments on the PACE cluster. In part-1, you only need to implement *addi, add, beq* instructions to pass all 5 test cases in test/part1/test[1-5].mem. In part 2, you will extend your processor by adding more instructions in order to pass the test cases under test/part2/. Part 3 is optional for bonus pts, where you will add more instructions.

## Part 0: Experiment Setup

Please follow the [instructions](part0/part0_pace.md) provided to run experiments on the PACE cluster.

**What to submit**:

No submission is required for Part 0. However, ensure that you know how to visualize waveforms with GTKWave.

## Part 1: Minimal functionality

In this part, you'll implement a subset of RISC-V instructions and are required to pass 5 tests under the test/part1 directory. Refer to the test cases and the README file in test/part1 for detailed requirements. 

1. [20pts] Complete the agex_stage.v file. No modifications to other files are necessary. Your implementation should pass test/part1/test[1-5].mem. If not all of the test cases pass, you'll only receive partial scores. To test all cases together, run `run_tests.sh part1`, and it will produce part1_results.log and part1_tests.log for you. You can also run each test case independently, see [FAQ for part 1](#faq-for-part-1). Note: If you encounter latch size errors, modify the corresponding latch size definition in define.vh.

2. [10pts] Explain the actions in each pipeline stage while executing test/part1/test1.mem. Include waveform screenshots illustrating relevant signals. For example, in the Execute stage (EX stag), you should visualize and explain the input (regval1_AGEX, regval2_AGEX) and output (aluout_AGEX) signals of the ALU, and the opcode (op_I_AGEX).

3. [10pts] Explain how your RISC-V processor resolves Read-After-Write hazards in test/part1/test2.mem. Include waveform screenshots illustrating the discussed signals. 

4. [10pts] Explain how your RISC-V processor handles branch misprediction in test/part1/test4.mem. Include waveform screenshots illustrating relevant signals. Note: In Lab 1, branches are always predicted as not-taken; in Lab 2, you will implement your own branch predictor.

**What to submit**:

Submit the following to Canvas:

+ Include a PDF file containing your explanations and the corresponding screenshots.

Submit the following to Gradescope:

+ For the coding part, we use Gradescope, so upload the `*.v` and `*.vh` files for autograding.

***Please carefully read [FAQ for part 1](#faq-for-part-1) before seeking assistance from TAs.***

***Start part 2 as early as possible and do not wait untill the last week, as it involves heavier workload than part 1.*** 

## Part 2: Extending the instruction set

1. [50pts] You'll extend your RISC-V processor to handle a broader range of instructions and are required to pass all the test cases under the test/part2/ directory. You may need to make changes to all the *.vh and *.v files. Partial scores will be granted based on the test case coverage if not all of test cases pass.

**Test cases**:

In part-2, all instructions in the test cases under test/part2/ such as add, addi, auipc, beq, bge, (all branch instructions), jal, jalr will be tested. To test all test cases together, use `run_tests.sh part2`, which will generate part2_results.log and part2_tests.log. Tests [7-9] are hand-written assembly code, which are easier to debug, so you may start with them. 

In part-2, we start to use more advanced RISC-V test cases. ```*.S``` is assembly code that takes RISC-V macro. Macros are defined at include/test_macros.h or include/riscv_test.h. It also uses ABI names and Pseudo Instructions. You can find a summary of information <a href="https://web.eecs.utk.edu/~smarz1/courses/ece356/notes/assembly/"> [here].  </a> ```*.dump``` is an dump file output from gcc riscv compiler. ```*.mem```  file has the format for verilog code. ```*.dec``` file is useful when using <a href="http://tice.sea.eseo.fr/riscv/">[RISC-V emulator] </a>

**What to submit**:

Submit the following to Gradescope:

+ For the coding part, we use Gradescope, so upload the `*.v` and `*.vh` files for autograding.

***Please carefully read [FAQ for part 2](#faq-for-part-2) before seeking assistance from TAs.***

***Avoid procrastination; start early to manage the workload effectively.*** 

## Part 3 (Optional) Complete the processor 

1. [20pts] In this part, you will complete the processor to fully support the RISC-V RV32I (except CSR instructions). Your goal is to ensure your program passes all the test cases in the test/part3/ directory. To receive full credits, your program must pass test/part3/testall.mem. Partial scores will be awarded based on the coverage of the Part 3 test suites.

**What to submit**: 

Submit the following to Gradescope:

+ For the coding part, we use Gradescope, so upload the `*.v` and `*.vh` files for autograding.

***Please carefully read [FAQ for part 3](#faq-for-part-3) before reaching out to TAs for help.***

## Useful Information

**References**

<a href="https://web.eecs.utk.edu/~smarz1/courses/ece356/notes/assembly/"> RISC-V RV32I Mannual</a>  

<a href="https://github.com/jameslzhu/riscv-card/releases/download/latest/riscv-card.pdf"> RISC-V Instruction Card</a>  


 
<a href="https://www.cs.cornell.edu/courses/cs3410/2019sp/riscv/interpreter/"> RISC-V emulator  (tiny RV2) </a> 

<a href="https://verilator.org/guide/latest/"> Verilator manual  </a> 

<a href="http://gtkwave.sourceforge.net/gtkwave.pdf"> GTKWave manual</a> 

<a href="https://web.archive.org/web/20221031194615/https://inst.eecs.berkeley.edu/~cs250/fa10/handouts/tut3-riscv.pdf"> Tutorial of the RISC-V TEST SUITE </a> 

## FAQ for part 1

**(Q)** How do I run a specific test file? \
**(A)** Please see ["define.vh"](define.vh): you need to change line 21 to change which test file to read: **`define IDMEMINITFILE  "/home/zhifan/workspace/cs3220-23fall/lab1/test/part1/test4.mem"**. You need to change "test4.mem" into "test2.mem" etc (be sure it points to the right file path, replace "/home/zhifan/workspace/cs3220-23fall/lab1/" with your local lab1 folder path), and then run command "make" in your terminal under lab1 folder. Please note that both imem and dmem use the SAME "IDMEMINITFILE". You can then use gtkwave to visualize the waveforms of your selected test case.

**(Q)** Debugging takes so much time. Any tips to reduce the debugging time? \
**(A)** Some suggestions:
1. Review code carefully and understand the ISA behavior correctly. 
2. If `make` command fails to compile, read the error messages carefully. 
3. `make` command generates vcd file. Please use GTKWave to see important signals and check whether the signals works as expected according to *.asm files or RISC-V enumlators. When debugging, it is always helpful to visualize `clk` signal and pc values along with other important signals.

**(Q)** How do I know whether my implementation is correct or not? \
**(A)** If you run ```make``` with a correct implementation, you will see a "Pass" message. 

**(Q)** Can I add new files? \
**(A)** Yes, but please make sure they are added in the zip file. 

**(Q)** Do we need to implement a branch predictor? \
**(A)** It's not required for lab 1. 

**(Q)** Do we need to create a stack for nested JAL instructions? \
**(A)** The hardware are not aware of any nested functions calls, so you do not need to implement it. 

**(Q)** BEQ t1, t1, imm : if a branch is taken, is the new PC = PC + imm or new PC = PC + 4+ imm? \
**(A)** The answer is PC = PC + offset. Please be careful when converting imm to offset. 

**(Q)** Do we need to worry about whether we should prevent all writes to the zero register and treat it as always zero, or if that is solely up to us dependent on our design? \
**(A)** This is purely S/W job. The H/W doesn't have to check whether x0 is writable or not. The Hardware also doesn't have explicitly insert 0 in hardware. 

**(Q)** Is the immediate field inside assembly code decimal? \
**(A)** If the number starts with 0x, it's hexadecimal.

**(Q)** When accessing the memory, why we drop out LSB 2 bits? \
**(A)** ISA is byte addressability but the verilog imem/dmem is declared as if it is word addressability since we don't do any unaligned accesses. Hence, we simply drop out lower two bits. Please note that, you don't need to do anything to support that. The framework provided to you already includes the code to ignore the lower 2 bits. 
  ```assign inst_FE = imem[PC_FE_latch[`IMEMADDRBITS-1:`IMEMWORDBITS]]; ```
```dmem[memaddr_MEM[`DMEMADDRBITS-1:`DMEMWORDBITS]]; ``` 

**(Q)** What does ``` assign inst_FE = imem[PC_FE_latch[`IMEMADDRBITS-1:`IMEMWORDBITS]];``` mean? \
**(A)** PC_FE_latch contains PC value. Again imem and dmem are word addressable, so we don't need LSB 2 bits. Since imem and dmem has only 2^14 size, we just use addr [15:2] bits to index imem/dmem.  

**(Q)** How do I know what is the correct instruction/code behavior? \
**(A)** You can use RISC-V enumlators or other RISC-V machine to execute the code. One example is <a href ="https://www.cs.cornell.edu/courses/cs3410/2019sp/riscv/interpreter/" >here</a>.

**(Q)** My code does not load any instructions. How do I fix that? \
**(A)** Carefully check your error messages and make sure you have set **IDMEMINITFILE** to the right path.

## FAQ  for part 2

**(Q)** I'm not sure how to understand part 2 test code. \
**(A)** The test in test/part2 is modified code from RISC-V test suite. It uses macro function to generate test code. 

**(Q)** What is li instructions in add.dump? \
**(A)** li instruction is one of the pseudo instructions. It is the same as addi x0, imm

**(Q)** I passed test[1-5].mem. why do I fail addi.mem? \
**(A)** It contains bne, auipc, jal instructions as well. So in order to pass part 2 test cases, you need to complete those instructions.

**(Q)** I'd like to use RISC-V emulator for testing the test code, but it won't take dump file. what should I do? \
**(A)** You can use the [test/dumptoasm.py](test/dumptoasm.py) to extract the assembly code.
  
**(Q)** I get the error "%Warning-LATCH: de_stage.v:120:1: Latch inferred for signal 'my_DE_stage.type_I_DE' (not all control paths of combinational always assign a value)" when running `make` with Verilator. \
**(A)** You can disable the Verilator linter by adding the comment `/* verilator lint_off LATCH */` on the line before the warning.

**(Q)** Behavior of ```lui```.  The documentation says that ``` - Semantics : R[rd] = imm << 12```. But U-immediate already shifted the immediate by 12 bits. Do I need to shift the sxt_imm_DE. Do I need to shift immediate value again? \
**(A)** No. if you have already shift immediage bits in instruction into sxt_imm_DE, you don't have to shift sxt_imm_DE again. 

**(Q)** ```bge``` is signed comparison and ```bgeu``` is unsigned comparison. What does it mean and what should I do? \
**(A)**  By default, in verilog all operations are unsigned. However, you can use signed comparisons in verilog by defining wires as signed variables. 
Here is an example for signed comparisons and unsigned comparisons 

```
wire signed [`DBITS-1:0] s_regval1_AGEX;  // note *signed* 
wire signed [`DBITS-1:0] s_regval2_AGEX;  //note *signed* 

assign s_regval1_AGEX = regval1_AGEX;
assign s_regval2_AGEX = regval2_AGEX;

// signed comparison
wire s_less;
assign s_less = (s_regval1_AGEX < s_regval2_AGEX); 

// unsigned comparison
wire less;
assign less = (regval1_AGEX < regval2_AGEX); 

``` 

**(Q)** ```bgeu``` and ```bltu``` use unsigned comparisons. Does it mean I shouldn't use signed extend immediage values at the decode stage and keep both unsiged and signed extension versions? \
**(A)** No, in RISC-V, all immediate values are sign-extended. ```begu``` and ```bltu``` are unsigned comparisons with sing-extended values (e.g. ```sxt_imm_DE```)

**(Q)** I'm still confused with ```signed``` keyword in verilog. Does it perform any sign conversion when I put ```signed``` keyword in the above example? \
**(A)** In Verilog, values are just binaries.  s_regval1_AGEX and regval1_AGEX have the same value. Signed unsigned are just a matter of interpretation. When arithmetic operations are used such as comparator, signed/unsigned decide how to interpret the value. 
e.g.)  In the above example, let's assume that reval1_AGEX  is  0x0000 and regval2_AGEX is  0xFFFF. In that case, s_regval1_AGEX is  0x0000 and s_regval2_AGEX is still 0xFFFF. However, s_regval2_AGEX is interpreted as -1 whereas regval2_AGEX is interpreted as 65535. Hence, `if (regval1_AGEX < regval2_AGEX)` returns false but `if (s_regval1_AGEX < s_regval2_AGEX)` returns true. 

**(Q)** Do I need to put the ```signed``` keyword for immediate values? \
**(A)** Yes, even though immediate values are sign-extended, if we want to treat the immediate value as 2's complement value such as in ``` SLTI_I```  instruction case, you need to put ```signed``` keyword. 

## FAQ for part 3 

**(Q)** Can you explain the behavior of ```slti``` and ```sltiu```. Does it store the outcome of shift value?  \
**(A)** The outcome of both instructions should be either 0 or 1. It checks whether (R[rs1] < sext(imm)) (signed comparisons for SLTI and unsigned comparisons for SLTIU) and if the condition is true, it sets 1 for the destination. 

**(Q)**  In tiny-isa description, ```srai``` , ```srli``` and  ```slli```  do not have immediate type. What should I do ? \
**(A)** Those instructions follow I-immediate type. However, only LSB 5-bits are used for immediate value (i.e. INST[24:20]). Please note that SRAI, SRL, SLL also use LSB 5-bits as source operand values.

