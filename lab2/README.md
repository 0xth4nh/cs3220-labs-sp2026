# CS3220 Lab #2 : Branch Prediction

110 pts in total, will be rescaled into 15% of your final score of the course.  

**Part 1: Baseline Branch Predictor**: 50 pts

**Part 2: Performance Measurement & Optimization**: 50 pts + 10 bonus pts (overflow allowed)

***Submission ddl***: Feb 23rd

This lab is a continuation of lab #1. In this project, you will implement a branch predictor for your RISC-V CPU. You are suggested to work on top of the solution for lab #1 from the TAs, which are located in the current folder. Alternatively, you can copy your *.v and *.vh files from lab #1 here and start from your own implementation.

## Part 1: Baseline Branch Predictor (50 points): 

In this part, you'll be implementing a baseline branch predictor and a branch target buffer for your RISC-V CPU. Here's a concise overview of the design: 

The baseline design adopts a G-share branch predictor (please refer to lecture-6): 

1. The branch history register (BHR) has a length of 8 bits, you will use `PC[9:2] XOR BHR` to index a Pattern History Table (PHT).

+ BHR may be referred to as GHR ( "Global branch history register") in the slides, they are the same item.

2. The PHT is composed of 2^8 2-bit counters to make branch prediction. Each counter is initialized with 1 (indicating a weakly not taken).

3. The branch target buffer (BTB) has 16 entries, and you will use `PC[5:2]` to index it. Each entry of the BTB is composed of 3 parts: a valid bit, a tag field, and a target address:

+ the tag field is used to determine whether the current PC address in the FE stage is the one recorded in the BTB entry;
+ the valid bit is used to identify whether this entry contains a valid history, rather than unused;
+ the target address is used to predict the branch / jump target.


Summary of the G-share branch prediction algorithm: 

* FE Stage ([fe_stage.v](fe_stage.v)): 

    Both BTB and PHT are concurrently accessed in this stage. 
    
    1. If there's a BTB hit, use PHT outcome to determine the target address for the next instruction fetch: if the outcome is taken, use BTB target address. If BTB misses, use PC+4 for next instruction. 

    2. The address for the next instruction fetch and index (`PC[9:2] XOR BHR`) used in FE stage is passed to EX stage for PHT update.

* EX stage ([agex_stage.v](agex_stage.v)): 

    1. Check if the next instruction fecthed in the FE stage is correct or not: if not, flush the pipeline.

    - If the branch is taken, and the next instruction we fetched is not the branch target, we are supposed flush the pipeline;
    - If the branch is not taken, and the next instruction we fetched is not PC+4, we should flush the pipeline.

    2. For branch instructions (bne, beq, jalr, etc.), insert the target address into the BTB, no matter taken or not.
    
    3. If PHT is used for branching prediction in the FE stage, update PHT using the propagated PHT index (`PC[9:2] XOR BHR`). 

    4. Update the BHR. 

    + As BHR and PHT are implemented in the FE stage, you are supposed to forward the relevant signals to the FE stage for the updates mentioned in 2, 3 and 4 via from_AGEX_to_FE.

To pass earn full credit of this part, implement the baseline branch predictor described above and make sure your baseline branch predictor passes [testall.mem](/test/part4/testall.mem) and all testcases under part2.

**Grading**:
We will check the testcases are correctly executed or not.

There won’t be any performance improvement in testall.mem because the branch should always be predicted to not taken, since each branch instruction is executed only once (the branch predictor only works if you encounter same instruction multiple times).  

This testcase is only intend to test that the branch predictor you implement is not distructive for the other functionalities of the RISC-V processor. 


## Part 2: Performance Measurement & Optimization (50 points + 10 bonus pts)

1. [40 pts] For this part, you will evaluate branch prediction accuracy by adding counters to measure it (# of correctly predicted branches / # total branch instructions). Utilize the [towers.mem](test/towers/towers.mem) testcase for this assessment and write your measurement results in a pdf report. 

+ Note that jump instructions should be counted as branch instructions here as well.

+ The simulator may report that the simulation failed, this is intended and please ignore this message.

+ To gain credits from Part 2, your baseline predictor should have > 30% accuracy.

+ To allow autograding, you have to print out the prediction accuracy in the following format: `Accuracy=xx%`, where `xx` is your accuracy. The accuracy can be a integer or a floating point number. You can refer to `sim_main.cpp` on how to access the register values in the Verilog modules via the verilator public data structure. **Note that you will need to modify `sim_main.cpp` to print the accuracy line.**

+ For the above point, the best course of action is to implement the branch‑prediction counters inside your Verilog file, and then use `sim_main.cpp` only to read those counter registers and print the line `Accuracy=xx%` for autograding.

2. [10 pts + 10 pts bonus] Enhance the performance of your branch predictor on the [towers.mem](test/towers/towers.mem) testcase by making design changes: you can explore other BHR hashing functions (e.g. using different bits of PC for the XOR operation), or change the PHT or BTB sizes. Implement at least three different design changes, and present the corresponding performance outcomes in your report. If your modifications result in more than a 5% increase in prediction accuracy compared to the baseline branch predictor, you will earn 10 bonus points.

## Submission

+ Provide a zip file containing your source code for Part 1 and Part 2. Generate the submission.zip file using the command `make submit`. Avoid manual zip file creation to prevent any issues with the autograding script, which could lead to a 30% score deduction.

+ Submit a concise PDF report for Part 2 (limited to 2 pages) containing the following information:
1.  Your performance measurements for the baseline G-share branch predictor and your three variants.
2.  Discuss the design parameters that were modified and explain how these changes influenced branch prediction accuracy, either positively or negatively.
3. Do not put this pdf inside the zip file.

<!-- Your scores will be depending on the performance improvement. If you get more than 5% performance improvement over the baseline configuration, you will receive 2 pts, if not, you will get 1 pt based on your report contents.  
Discuss your design space explorations and write a report about your evaluations. 
Evaluate your design with the provided benchmark and report the performance numbers. 
Please print out cycle count, BP accuracy (# of corrected predicted branch/# branch insts), # taken branches, # not-taken branches. # branches.  The cases are no branch predictor, baseline branch predictor (part-1), and your improved versions. Please show the results those are hurting the performance. 
Please show at least 3 different design changes that you have made in addition to the baseline branch predictor. Total 4 branch predictor's results + no branch predictor's result (project #1).  -->

<!-- **Grading**
The contents of the report will be used for the grading part-2.  
Please discuss what design parameters have you changed and discuss why it changes (good or bad or the same) performance.  


**What to submit** 
Report (max 2 pages) (No need to submit the code again)  -->

## FAQ

[Q] I passed [testall.mem](test/part4/testall.mem) but failed to pass some testcases under [test/part2](test/part2). What should I do? \
[A] Please carefully check whether your when-to-flush logic is correctly implemented in the AGEX stage based on the following criteria:  
- If the branch is taken, and the next instruction we fetched is not the branch target, we are supposed to flush the pipeline.  
- If the branch is not taken, and the next instruction we fetched is not PC+4, we should flush the pipeline as well.

[Q] What do the BTB and PHT look like, and how do we make predictions? \
[A] Each BTB entry contains three parts: a valid bit, a tag field (PC[31:6]), and a target address. The PHT has 256 entries of 2‑bit counters, indexed by `PC[9:2] XOR BHR`. All branch prediction logic is implemented in the FE stage.

[Q] How do we update the BHR (Branch History Register)? \
[A] For each branch instruction, left shift the BHR by one bit and insert the latest result in the rightmost bit: 1 if taken, 0 if not taken. BHR is the same as GHR mentioned in the slides.

[Q] How do we update the BTB? \
[A] When you detect a branch or jump in AGEX, insert it into the BTB regardless of whether it is taken. Store PC[31:6] in the tag field, the calculated target address in the target field, and set the valid bit to 1.

[Q] Do we insert a BTB entry only for the taken branch or even when it is not taken? \
[A] You need to insert a BTB entry even when the branch is not taken, because the same branch might be taken the next time.

[Q] If we insert a not‑taken branch for the BTB entry, what will be the target address? \
[A] You can still compute the target address as if it is taken and insert it in the BTB.

[Q] How do we update the PHT? \
[A] Pass the PHT index (`PC[9:2] XOR BHR`) from FE to AGEX through pipeline latches. Forward this PHT index from AGEX back to FE using the `from_AGEX_to_FE` wire, and update the 2‑bit counter at that index based on the actual outcome.

[Q] When should we flush the pipeline? \
[A] Flush when the next instruction is fetched from an incorrect address. If the branch is taken and the fetched instruction is not at the branch target, flush. If the branch is not taken and the fetched instruction is not at PC+4, also flush.

[Q] What if the target in the BTB is wrong? \
[A] Treat it like a branch misprediction: flush the pipeline and update the BTB entry with the correct target.

[Q] With a branch predictor, will the pipeline still have pipeline bubbles? \
[A] The pipeline will still have bubbles for dependency stalls, but not for correctly predicted branch instructions.

[Q] What is the expected branch prediction accuracy on towers.mem? \
[A] The baseline implementation should achieve around 30–40% accuracy with approximately 990–991 total branches (including jumps) for `towers.mem`.

[Q] Why is the expected accuracy so low for the baseline implementation? \
[A] Small programs have few repeated branch occurrences, giving the predictor fewer opportunities to learn. Additionally, this is a relatively simple predictor design.

[Q] Where should I put the counters for tracking branch predictions? \
[A] Implement counters in the AGEX stage because instructions there are never flushed and lie on the real execution path. Counting in FE or DE may include wrong‑path instructions.

[Q] My branch prediction accuracy is extremely high (>80%) or my total branch count is not around 990. What’s wrong? \
[A] Check if your BTB is returning invalid target addresses (such as 0), which can cause repeated execution of the same code. Also verify that you are using the correct index bits for BTB access and updates.

[Q] I’m getting around 160/990 correct predictions (about 16% accuracy). How can I improve this? \
[A] Verify that jump instructions properly update your PHT, BTB, and BHR, and that you are treating jumps as branches for both counting and predictor updates.

[Q] I’m failing only `jalr.mem` but passing everything else. What should I check? \
[A] Verify that `br_mispred_AGEX` is set correctly for jump instructions (including JALR). Trace through the waveform and compare `PC_AGEX` values with `jalr.dump` to find where execution diverges.

[Q] I can’t see the PHT values in my waveform. How can I view them? \
[A] The PHT has too many entries to display directly. Assign one or a few specific entries to separate wires or debug outputs so you can observe those entries in the waveform.

[Q] I’m debugging my code. I see that there is an X in the BTB/BHT. How would it be possible? \
[A] The FE stage can have pipeline bubbles. Therefore, BTB/PHT might be indexed with uninitialized values (X). Make sure that when you update BTB/PHT, only valid branch/jump instructions (with non‑X control signals) are allowed to change their contents.

[Q] I don’t see performance improvement in testall.mem. Why?  \
[A] This is expected. All branch instructions in `testall.mem` are executed only once and are not taken. In order for a branch predictor to be effective, the processor has to see the same branch multiple times so the predictor can be trained.

[Q] My pipeline did not work for lab 1. What should I do?  \
[A] Please use the reference design provided by the TAs instead of your own Lab 1 implementation.

[Q] I want to add a new file (e.g., `bp.v`). Can I? \
[A] Please do not add new files, as this might break the auto‑grading script.

[Q] Do I have to show performance improvement in order to get full credit for Part 1? \
[A] No. Performance improvement is only required and evaluated in Part 2.

[Q] Are we expected to implement data forwarding in Lab 2? \
[A] No, data forwarding is not required for this lab.

[Q] Let’s say my instruction stream is as follows:  
```
BR(1)
ADD
BR(2)
```
When BR(1) is in EX, it will update the BHR, but BR(2) will be in FE at that time. Which value of BHR should FE use—the old value or the updated value from EX? \
[A] This is one of the optimization opportunities. How you handle this case is up to you. Remember that the branch predictor is just a predictor and will not affect the correctness of the program, only performance.

[Q] How do I initialize the PHT entries to “1”? \
[A] Explicitly write `2'b01` into every PHT entry during reset (e.g., in a `for` loop in the reset branch of your always block).

[Q] I ran `towers.mem` and my test case is failed unlike other test cases. Is that expected? \
[A] Yes. The `towers.mem` program returns `255`, which does not match the normal PASS criteria of the simulator. You do not need to worry about this for grading.

[Q] Do all three design changes in Part 2 need to result in better performance? \
[A] No. Worse performance will not prevent full credit for Part 2, as long as you implement and evaluate at least three meaningful variants. For the 10 bonus points, you need at least one implementation with a ≥5% accuracy increase over the baseline.

