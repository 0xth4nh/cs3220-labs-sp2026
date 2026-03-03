# CS3220 Lab #3 : A Case Study of A RISC-V with An External ALU

110 pts in total, will be rescaled into 15% of your final score of the course.  

**Part 1: Connect An External ALU with A RISC-V**: 60 pts

**Part 2: Performance Optimization**: 40 pts

**Bonus**: 10 pts

***Submission ddl***: Mar 9th

This lab builds upon the knowledge you've gained from previous lectures and labs on RISC-V CPU design. Specifically, you'll be integrating the RISC-V CPU you designed in earlier labs with an external ALU to enhance its efficiency for certain complex workloads.

## Part 1: Connect An External ALU with A RISC-V (60 points): 

In this section, you'll integrate the RISC-V CPU you designed in Lab #2 with a supplied external ALU. Your responsibility is to adjust the RISC-V implementation to accommodate the external ALU's operations and verify that the RISC-V CPU can accurately run the given test cases.

The [external ALU](external_alu_wrapper.v) has following specifications:
<!-- * `OPREG1`, `OPREG2`, and `OPREG3` are 5-bit inputs that specify the registers to be used as operands for the ALU operation.
    * 4 registers for each of them; in total 12 registers -->
* `OP1` and `OP2` are 32-bit inputs that specify the values to be used as operands for the ALU operation. (Floating point numbers in IEEE 754 format)
* `OP3` is a 32-bit output that holds the result of the ALU operation. (Floating point numbers in IEEE 754 format)
* `ALUOP` is a 4-bit input that specifies the ALU operation to be performed. The ALUOP values are as follows:
    * 0001: DIV
    * 0010: MULT
    <!-- * `ALUOP[3]` is a 1-bit input that specifies whether the ALU operation is signed or unsigned. If `ALUOP[3]` is 0, the operation is unsigned; if `ALUOP[3]` is 1, the operation is signed. -->
* `CSR_ALU_OUT` (Control/Status Register) is a 3-bit input port that represents the status of the ALU operation. The `CSR_ALU_OUT` values are as follows:
    * `CSR_ALU_OUT`[0] is a 1-bit output that signals if the ALU OP1 port is READY/BUSY
        * i.e., whether the ALU will be able to latch in your inputs (operands and ALUOP)
    * `CSR_ALU_OUT`[1] is a 1-bit output that signals if the ALU OP2 port is READY/BUSY
        * i.e., whether the ALU will be able to latch in your inputs (operands and ALUOP)
    * `CSR_ALU_OUT`[2] is a 1-bit output that signals if the result of the ALU operation is VALID/INVALID
        * 1: VALID; 0: INVALID
* `CSR_ALU_IN` is a 3-bit output that control the status of the ALU operation. The `CSR_ALU_IN` values are as follows:
    * `CSR_ALU_IN`[0] is a 1-bit input that signals the the results can be overwritten by the ALU.
        * When set to 1, it acknowledges the ALU that the output is received and can be overwritten in following cycles; thus the output will become unstable
        * After reading the output, you may also want to set `CSR_ALU_IN`[0] back to 0, so you can catch the results when it's stable
        * reference: [divider.v](divider.v#L294)
    * `CSR_ALU_IN`[1] is a 1-bit input that signals the `OP1` fed to the ALU is stable
        * If it's set to 1, the ALU will latch in the `OP1` value; otherwise, the ALU will stall the current operation and wait for `OP1` to be stable.
        * It's ignored if the ALU is not ready to accept `OP1`.
    * `CSR_ALU_IN`[2] is a 1-bit input that signals the `OP2` fed to the ALU is stable
* The `ALUOP` need to be loaded first and the operands `OP1` and `OP2` need to be loaded in order. 
* The ALU is data driven, i.e., it will start the computation as soon as the operands are loaded, based on the loaded ALUOP.
* Potential delay between the two operands' loading, i.e., ALU can potentillay not be ready to load `OP2` when `OP1` is loaded.
* The ALU is adapted from this implementation:
    * https://github.com/dawsonjon/fpu
    * https://dawsonjon.github.io/Chips-2.0/language_reference/interface.html 

The specifications from RISC-V CPU is as follows:

1. For loading the operands, we will use `LW` instructions, to load the operands from the memory, with dst reg ID:
    * 11110: `OP1`
    * 11111: `OP2`
2. For loading the `ALUOP` to configure the ALU, we will use `LW` instructions, with dst reg ID
    * 11101: `ALUOP`
4. For reading the result/status from the ALU, we will use `SW` instructions, with src reg ID
    * 11011: `OP3`
    * 11010: `CSR_ALU_OUT`
5. Intended instruction sequence:
    * load `ALUOP` 
    * load `OP1`, `OP2` (**`OP1` and `OP2` need to be loaded in order**)
    * store `OP3`



Your tasks are as follows:
1. Integrate the ALU with the RISC-V CPU. You will need to modify the RISC-V CPU to accommodate the ALU's operations.
    * Go over all the TODOs and finish the implementation. ([FU_stage.v](FU_stage.v), [de_stage.v](de_stage.v))
2. You can assume enough `NOP`s inserted to separate the operands loading and storing the results. 
    * In other words you don't need to worry about the stalls needed to handle the ALU's readiness.

To pass this part and earn full credit, implement the integration described above and run your implementation on [alutest0.mem](test/part5/alutest0.mem) and ensure it passes this testcase.
* You can use the `./run_tests.sh part5` to test your implementation.




## Part 2: Performance Optimization (40 points)
What if there is no `NOP`s inserted between OP1 loading and OP2 loading, and the ALU might not be ready to load either `OP1` or `OP2`?

Modify the part 1 implementation to handle the stalls needed to handle the ALU's readiness. Your implementation should still work on the testcases in part 1.
* You may modify more files (except the [external ALU](external_alu_wrapper.v) and its dependent modules) as needed.

To pass this part and earn full credit, implement the integration described above and run your implementation on [alutest1.mem](test/part6/alutest1.mem) and ensure it passes this testcase.
* You can use the `./run_tests.sh part6` to test your implementation.


## Bonus points (10 points)
When the implementation is instructed to store ALU's results to the memory, it's possible that the ALU is still processing. It's even possible that the instruction to store `OP3` is issued before ALU even finishes loading either `OP1` or `OP2`. 

Modify the part 2 implementation to handle the stalls needed to handle stalls needed to handle the ALU's results storing to the memory. Your implementation should still work on the testcases in part 1 and part 2.

To pass this part and earn full credit, implement the integration described above and run your implementation on [alutest2.mem](test/part7/alutest2.mem) and ensure it passes this testcase.
* You can use the `./run_tests.sh part7` to test your implementation.


## Submission

+ Provide a zip file containing your source code. Generate the submission.zip file using the command `make submit`. Avoid manual zip file creation to prevent any issues with the autograding script.
+ Submit the zip file to gradescope. 



## Q&A (Courtesy from previous years' students' and TAs' Q&A)

**Q1. Under the RISC-V specifications, we are given destination and source register ids for using the LW and SW instructions, but I am a bit confused about its usage, for example to access OP3 for example do I do SW(11011)? And if so would this be done in the mem stage?**

A1. As the one making the processor, you don't have to issue any instructions. The details about SW and LW relate to what the programmer does to use the ALU. But it is your job to make sure that if there is a SW instruction with the specified register id, that the ALU and CPU are ready to transfer the output to the CPU or have already done so. In this case, the CSR signals are key to coordinating this.

**Q2. Are the registers for OP1, OP2, OP3, and ALUOP only ever used for this external ALU? Do we have to handle the case where these registers can be used as general purpose registers as well as registers for this external ALU or are we guaranteed that these registers are only ever used for external ALU computation?**

A2. For this lab, these registers (30, 31, 27, 29) are reserved only for external ALU operations.

**Q3. What is the overall strategy for implementing Lab 3?**

A3. Create a state machine in `de_stage.v` with additional control logic. You'll coordinate loading ALUOP, OP1, and OP2 to the external ALU, wait for computation, then retrieve OP3. The CSR signals coordinate between CPU and ALU. The recommended state transition is: load ALUOP → load OP1 → load OP2 → ALU processing → store results to memory.

**Q4. I am modifying the DE stage for part 1, and I saw the comment "Recommended states transition: load aluop → load op1 → load op2 → alu processing → store results to memory". I understand all the states except for the alu processing, are we supposed to invoke the external alu here?**

A4. The external ALU is able to invoke itself. Once it receives op1 and op2, it moves itself into the execute stage and does the calculation. This takes some amount of time, so the processor has to wait until the result is ready to bring it back to the CPU. The ALU is data-driven and automatically begins calculation once both operands are loaded based on the loaded ALUOP. Then you'll have to coordinate between the ALU and CPU to bring the result back. Part 1 and 2 both have enough NOPs in between the loadings and the store that you won't run into a case where the SW is issued, but the data isn't ready.

**Q5. Decode Stage store to memory. How would we store to memory in the decode stage as the TODO says "store results to memory"? I do not see anywhere to access the memory there.**

A5. The programmer will issue an SW instruction to store the result in register 27 to somewhere. By the time this instruction reaches DE, register 27 should contain the result from the ALU. If this instruction runs through, you've effectively stored the result to memory. The functionality to get the data from the ALU to CPU in register 27 is for us to implement.

**Q6. What's the difference between CSR_ALU_IN and CSR_ALU_OUT?**

A6. CSR_ALU_OUT is an input to your CPU (output from ALU) that shows ALU status. CSR_ALU_IN is an output from your CPU (input to ALU) that you control to tell the ALU what to do. Note: The README has this backwards (typo). These signals are themselves the ready/valid signals - it's not necessary to have another set of ready/valid signals to tell if they are ready/valid.

**Q7. The readme mentions that CSR_ALU_OUT can be saved to memory by the programmer. Do we assume that whatever value is in the designated register is the correct value, because there doesn't appear to be signals that indicate status stability. Do we assume the same thing for ALUOP? My understanding is the ALU will only latch to operands when CSR_ALU_IN[1,2] are set, but there is no signal for ALUOP. Do we assume that it can be loaded at any time?**

A7. (1) CSR_ALU_OUT and CSR_ALU_IN are themselves the signals to tell if the data signals are ready/valid. So you can somewhat assume it's "correct" whatever the value points to, but you need to be very certain when you read these signals. (2) Storing CSR_ALU_OUT is not necessary in THIS lab, so no worry about it. (3) For ALUOP, imagine a switch - the computation will carry on in a mode wherever the ALUOP is pointing to at that moment. And there is a default position for it, so if you do not load it, it will go to the default location. You should filter out ALUOP = 0, which is set during initialization and is invalid.

**Q8. What do the CSR_ALU_IN bits control?**

A8. CSR_ALU_IN bits are:
* Bit [0]: Result overwrite acknowledgment (1 = ALU can move to next operation/start state, 0 = ready to receive result)
* Bit [1]: OP1 is stable and ready to be latched by the ALU
* Bit [2]: OP2 is stable and ready to be latched by the ALU
* Note: ALUOP is NOT part of CSR_ALU_IN

**Q9. What do the CSR_ALU_OUT bits indicate?**

A9. CSR_ALU_OUT bits indicate:
* Bit [0]: OP1 port ready (1) or busy (0)
* Bit [1]: OP2 port ready (1) or busy (0)
* Bit [2]: Result valid (1) or invalid (0)

**Q10. When should CSR_ALU_IN[0] be 0 or 1? Should it initially be 0 or 1? When would we want to set it to 1?**

A10. CSR_ALU_IN[0] being set to 1 brings the ALU back to the start state, while setting it to 0 indicates that we are ready for the answer of the ALU. In other words, set it to 1 initially to start, and then once we have loaded all the operands (specifically after loading OP1), set it to 0. After reading OP3, you should set it back to 1 to acknowledge receipt and allow the ALU to proceed to the next operation.

**Q11. Confused about how to handle CSR_ALU_IN[0]: when CSR_ALU_IN[0] == 1, that means that ALU cannot overwrite OP3. My plan is, when wr_reg_WB == OP1 register, we get the OP1 value from the regfile. But if CSR_ALU_IN[0] == 1, we can't overwrite OP3, so that means I can't overwrite OP1 or OP2. So what do we do with this value read in from OP1?**

A11. On the ALU side, CSR_ALU_IN[0] is used to either keep the unit in standby state (i.e., it'll finish the operation and hold the output, but nothing else) or shift the unit into `get_a` mode. The signal won't affect you until the next operation, which will block you until you set the CSR_ALU_IN[0] signal to tell the ALU that the CPU's taken the result in. Then it's on you to set this signal to the proper value to shift the unit into `get_a` mode, to which op1 can be loaded in as usual.

**Q12. How do I access ALUOP, OP1, OP2, and OP3 values in my implementation?**

A12. Use WB stage forwarding signals (`regval_WB` and `wregno_WB`). The programmer uses LW/SW instructions - your job is to ensure CPU and ALU coordinate properly using CSR signals. Values are stable after writeback to the register file - check CSR_ALU_OUT bits to confirm when to proceed.

**Q13. Do values need to be loaded in a specific order?**

A13. Yes - ALUOP must be loaded first, then OP1, then OP2 in that order. The ALU accepts inputs sequentially and may not be ready for OP2 when OP1 is loaded.

**Q14. In my FU, I am trying to figure out why my part 1 is not working and am curious as to why the FU stage all of a sudden gets a large number such as 3F800000 randomly in despite the numbers I manually provided?**

A14. The ALU performs floating-point operations in IEEE 754 format. Translate the value from HEX into floating point to verify correctness. For example, 0x3F800000 = 1.0 in floating point.

**Q15. Should I use negedge or posedge for state updates and register file updates?**

A15. Use posedge for most logic. However, register file updates and ALU mailbox register updates should use the negedge block in DE stage to avoid race conditions with the register file read logic. Use CSR_ALU_OUT to determine when values are stable.

**Q16. What's the difference between Part 1, Part 2, and Bonus?**

A16. 
* Part 1 (60 pts): Assume sufficient NOPs between operations - no stalling needed for ALU readiness
* Part 2 (40 pts): No NOPs between OP1/OP2 loading - implement stalls when ALU ports aren't ready (check CSR_ALU_OUT[0] and CSR_ALU_OUT[1])
* Bonus (10 pts): SW to OP3 may occur before ALU finishes computation - stall until result is valid (check CSR_ALU_OUT[2])

**Q17. Where do I implement stalls for Part 2 and Bonus?**

A17. Check CSR_ALU_OUT before loading operands or storing results. Create an `alu_not_ready_stall` signal that checks:
* For Part 2: `(is_load_op1 && ~CSR_ALU_OUT[0]) || (is_load_op2 && ~CSR_ALU_OUT[1])`
* For Bonus: Also include `(is_store_op3 && ~CSR_ALU_OUT[2])`
Include this stall signal in your `pipeline_stall_DE` logic. When ports are busy or results aren't valid, you'll need to stall the pipeline, not just pipeline_stall_DE.

**Q18. My OP3 value is correct but appears too late. Why?**

A18. Common causes:
1. Extra register stages between DE and FU
2. Incorrect state transitions
3. Not properly checking CSR_ALU_OUT for completion
4. Using DE stage values instead of WB stage values

**Q19. How long should external ALU computation take?**

A19. Approximately 600-700 ps. If significantly longer, check state transitions and CSR_ALU_IN settings.

**Q20. CSR_ALU_OUT never changes - what's wrong?**

A20. Check:
1. ALUOP is valid (not 0) - filter out initialization values
2. Using WB stage values (`wr_reg_WB`, `wregno_WB`, `regval_WB`), not DE stage values
3. CSR_ALU_IN bits are set correctly and sequentially
4. Check `external_alu_wrapper.v` signals in waveform viewer to verify inputs are being latched

**Q21. Register has correct value but test fails. What should I check?**

A21. This is a timing issue - the value must be in register 27 BEFORE the SW instruction executes. Trace timing in GTKWave to see when the value becomes available versus when SW reaches the pipeline stage that reads it.

**Q22. How do I debug in GTKWave?**

A22. Start at `external_alu_wrapper.v` inputs/outputs. Verify when inputs/outputs become valid, then trace signals backwards through pipeline stages. Check the register file (`regfile`) in DE stage to see when values are written. Look at the state transitions and CSR signal changes.

**Q23. Which test command should I use for each part?**

A23. 
* Part 1: `./run_tests.sh part5`
* Part 2: `./run_tests.sh part6`
* Bonus: `./run_tests.sh part7`







