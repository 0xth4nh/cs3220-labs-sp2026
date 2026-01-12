# Lab 0 RTL Getting Started

**Objective:** The main purpose of this lab, along with the succeeding one, is to acquaint you with RTL programming, specifically Verilog. These initial steps aim to equip you with a strong foundation in Verilog, setting the stage for more advanced labs ahead.

**Description:** This lab involves the implementation of a variety of basic hardware modules using Verilog, including an ALU and FPU. In addition, you will be tasked with developing the requisite testbench code to verify the correctness of your modules. This dual approach not only provides hands-on experience with Verilog but also emphasizes the importance of testing and validation in hardware design.

1. **Included modules:**  a. Combinational Circuits; b. Vector Signals; c. Module Hierarchy; d. Always Block & Sequential Circuits; e. Finate State Machine; f. Arithmetic Logic unit; g. Floating Point Unit
2. **Specification about each modules:**
   1. [Combinational Circuits (0.5%)](./1-combinational_circuits/1-combuinational_circuits.md)
   2. [Vector Signals (0.5%)](./2-vector_signals/2-vector_signals.md)
   3. [Module Hierarchy (1.0%)](./3-module_hierarchy/3-module_hierarchy.md)
   4. [Always Block &amp; Sequential Circuits (0.5%)](./4-always_block/4-always_block.md)
   5. [Finite State Machine (0.5%)](./5-fsm/5-fsm.md)
   6. [Arithmetic Logic Unit (3%)](./6-alu/6-alu.md)
   7. [Floating Point Unit (4%)](./7-fpu/7-fpu.md)

**Submission Format:**

1. We use Gradescope for the code submission and grading.
2. Please submit the completed "Q1.v", "Q2.v", "Q3.v", "Q4.v", "Q5.v", "alu.v", "fpu.v" files (no need to zip—just upload the \*.v files) to Gradescope. DO NOT CHANGE THE FILENAME AND MODULENAME!

**Due:** Jan. 27th 2:00AM EST

**Grading Policy**:

1. If you pass the test cases.
   1. Note: All test cases are randomly generated for all modules.

**FAQ:**

[Q] How to debug the code?

[A] The gradescope will provide the input and output for both your code and the golden code if the test failed. You can compare the output to debug your code. Additionally, writing testbench is an important skill in processor design, you can also design your own testbench and install iverilog on your computer to debug the code.

[Q] Any online tutorials to watch?

[A] [link1](https://www.youtube.com/watch?v=lLg1AgA2Xoo&list=PLEBQazB0HUyT1WmMONxRZn9NmQ_9CIKhb&index=1): Focus on the concept and programing as we will use different devices

[link2](https://www.youtube.com/watch?v=9mpRF6bAY1g): modelsim (similar to vivado xsim)

[link3](https://www.youtube.com/watch?v=YodFKbKxElo&list=PLfGJEQLQIDBN0VsXQ68_FEYyqcym8CTDN), [link4](https://www.youtube.com/watch?v=S26TPZm4zzM&list=PL3Soy1ohxlP1TLpcbYXYcVWItRy_XrUk8): more comprehensive digital design and RTL programing tutorial videos
