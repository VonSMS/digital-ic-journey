# Conversation Handoff

Repository files and Git are the shared source of truth; do not rely on another
conversation automatically knowing prior discussion.

## Start

Use this prompt:

```text
Read AGENTS.md, docs/PROGRESS.md, git status, and the relevant RTL/testbench.
Continue from the Exact Next Action and preserve user changes.
```

Then run:

```bash
cd /c/Users/14138/Documents/IC_design_project_2026/digital-ic-journey
git status --short
git log -5 --oneline
```

## Work

Use the cycle:

```text
predict -> simulate -> read first FAIL -> inspect waveform -> explain -> fix
```

Avoid editing the same RTL file in multiple conversations. Use Git commits and
merges when working on separate branches or worktrees.

## Finish

Update `docs/PROGRESS.md` with:

- implemented work
- test command and PASS/FAIL result
- remaining issue
- one exact next action

Do not commit or push unless explicitly requested.

## Common ALU Command

```bash
mkdir -p sim
iverilog -g2012 -Wall -o sim/tb_alu4.vvp rtl/alu4.v tb/tb_alu4.v
vvp sim/tb_alu4.vvp
```

