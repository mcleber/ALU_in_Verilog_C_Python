
| Title | Verilog, C and Python ALU Practical Guide - Volume 1 |
|-------|-------|
| File  | `README_vol1.md` |
| Date  | 13 Jul 2026 |

---

# Verilog, C and Python ALU Practical Guide – Volume 1

## Preface

This material has been reorganized as a **study guide**, not just a collection of code.

The main idea is to learn step by step:

- understand the concept;
- study a small example;
- test it;
- expand it;
- integrate Verilog, C and Python into a complete project.

The central project of this guide is an Arithmetic Logic Unit (ALU). 

The ALU is a great educational project because it lets you study:

- arithmetic operations;
- logic operations;
- flags;
- code organization;
- automated testbench;
- reference model in C;
- automation with Python;
- simple FSM;
- advanced FSM;
- integration between software and hardware.

In this guide, we will use:

- **Verilog** to describe the ALU hardware;
- **C** to create a fast and accurate reference model;
- **Python** to automate tests, generate vectors, and compare results;
- **Icarus Verilog** to compile and simulate Verilog;
- **GTKWave** to visualize signals as waveforms;
- **VSCode** to edit, compile, and debug C and Python.

---

## How to study this guide

Do not read this material just copying the code.

The best way to study is:

1. Read the topic explanation.
2. Copy the code manually.
3. Compile and run.
4. Modify some detail.
5. Run again.
6. Observe the error.
7. Fix it.
8. Only then move on.

Programming and digital hardware are learned through practice, experimentation, and repetition.

Throughout this guide, we will use three types of code:

- **Production code** — implements the functionality.
- **Test code** — verifies whether the implementation is correct.
- **Automation code** — compiles, executes, and compares the results.

From now on, whenever we create something important, we will also create a test.

---

## Table of Contents

### [Part 1 — Fundamentals](vol1_files/vol1_part_1.md)

1. Environment setup.
2. What each language does in the project.
3. Essential concepts of digital systems.

### [Part 2 — C](vol1_files/vol1_part_2.md)

4. Basic C with a focus on hardware models.
5. Code organization in C.
6. Unit tests in C.
7. Reference model of an ALU in C.
8. Concurrency and parallelism in C — pthread integrated with the vector generator.

### [Part 3 — Python](vol1_files/vol1_part_3.md)

9. Basic Python for automation.
10. Unit tests in Python.
11. Python generating test vectors.
12. Concurrency and parallelism in Python.

### [Part 4 — Verilog](vol1_files/vol1_part_4.md)

13. Basic Verilog.
14. Basic testbench.
15. Combinational logic.
16. Sequential logic.
17. Combinational ALU in Verilog.
18. Automated testbench for the ALU.
19. Simple FSM.
20. Advanced FSM.

### [Part 5 — Integrated project]((vol1_files/vol1_part_5.md))

21. Architecture of the integrated project.
22. C as the reference model.
23. Python as generator and verifier.
24. Verilog as the hardware implementation.
25. Complete automated flow.
26. Final checklist.
