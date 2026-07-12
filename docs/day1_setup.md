# Day 1 Setup Notes

Date: 2026-07-11

## Objectives

1. Create a local learning repository.
2. Install and verify the basic digital IC toolchain.
3. Understand the role of MSYS2 UCRT64 on Windows.
4. Configure Windows PATH so the tools can also be called from PowerShell.
5. Prepare the project structure for Week 1.

## Final Tool Status

The following tools were installed and verified:

```text
Git             OK
Python          OK, available through py
GCC             OK
Icarus Verilog  OK
GTKWave         OK
Yosys           OK
Verilator       skipped for now
```

Verilator is not required for Week 1. The initial RTL exercises can be completed with Icarus Verilog, GTKWave, and Yosys.

## MSYS2 UCRT64

MSYS2 is a Unix-like development toolbox for Windows. It provides a terminal environment, the `pacman` package manager, and access to many open-source engineering tools.

UCRT64 means:

```text
UCRT  = Universal C Runtime
64    = 64-bit Windows environment
```

For this project, MSYS2 UCRT64 is the main toolchain environment. The tools are installed under:

```text
D:\msys64\ucrt64\bin
D:\msys64\usr\bin
```

These directories were added to Windows PATH so that PowerShell and VS Code terminals can find the tools directly.

## Installed Packages

The core packages were installed with:

```bash
pacman -S --needed git mingw-w64-ucrt-x86_64-python mingw-w64-ucrt-x86_64-gcc
pacman -S --needed mingw-w64-ucrt-x86_64-iverilog mingw-w64-ucrt-x86_64-gtkwave mingw-w64-ucrt-x86_64-yosys
```

## Verification Commands

In PowerShell, the main checks are:

```powershell
git --version
py --version
gcc --version
iverilog -V
gtkwave --version
yosys -V
```

The repository also includes a helper script:

```powershell
cd <repo-root>
powershell -ExecutionPolicy Bypass -File .\scripts\check_tools.ps1
```

## Repository

The local repository is:

```text
digital-ic-journey
```

The repository uses the `main` branch. The initial files are:

```text
README.md
docs/day1_setup.md
scripts/check_tools.ps1
rtl/
tb/
sim/
.gitignore
```

## GitHub Remote

After the local commit, the next optional step is to publish the repository to GitHub.

Recommended repository name:

```text
digital-ic-journey
```

If using GitHub Desktop:

1. Add the local repository.
2. Confirm the branch is `main`.
3. Commit any remaining local changes.
4. Click `Publish repository`.
5. Choose whether the repository should be public or private.

## Day 1 Result

Day 1 established the basic engineering workflow:

```text
write RTL
simulate with Icarus Verilog
inspect waveforms with GTKWave
analyze hardware with Yosys
use Python for automation and golden models
track progress with Git
```

This is the foundation for the Week 1 digital logic exercises.
