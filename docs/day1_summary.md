# Day 1 Summary Notes

Date: 2026.7.12

## What I did today

1. Configurate MSYS2 UCRT64 and clarified its role:
- MSYS2: a Unix like develpoment toolbox for Windows
- UCRT64: a 64-bit MSYS2 developing environment
- pacman: the package manager used to install tools
- PATH: the Windows serch map for command line programs

2. Installed, verified and understand toolchain:
- Git: version control
- Python: scripting, test automation, golden models
- GCC: C/C++ compilation
- Icarus: verilog simulation
- GTKWave: wave inspection
- Yosys: Synthesis and hardware resource analysis

3. Created a local and an online project repository
```text
C:\Users\14138\Documents\IC_design_project_2026\digital-ic-journey
```
Structure
```text
.
├── docs/          # Study notes, week summary, screenshots and demonstrations
├── rtl/           # SystemVerilog/Verilog design code
├── tb/            # testbench
├── scripts/       # Automation execution and testing scripts
├── sim/           # Simulation output, usually not submitted
└── README.md
```


## My Problems and Solutions
1. Slow download speed causing pacman download failure
2. mirror source file name error: mirrorlist.mingw
3. mirrorlist.mingw cannot be written as ucrt64 but $repo (to open in all environment)
