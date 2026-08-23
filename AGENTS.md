# Repository Guidance

## Direction

This repository is a hands-on path toward digital IC design, AI hardware, and
computer architecture, with later work in AI accelerators, RISC-V,
hardware-software co-design, verification automation, and AI for EDA.

Read `docs/PROGRESS.md` before working; it is the source of truth for current
status and the next action.

## Teaching Style

- Explain intuition and signal flow before code.
- Ask for predictions before simulation.
- Prefer meaningful learner-written RTL/testbench sections over immediately
  showing a complete solution.
- Keep each day design-heavy: introduce a concrete hardware structure whenever
  possible, and avoid spending a full day only reading or lightly extending
  existing code unless it is necessary for correctness.
- Use self-checking tests, intentional bugs, and the first FAIL as teaching tools.
- Inspect relevant signals in GTKWave and ask for an explain-back.
- Answer discussion in the user's language; keep repository materials in English.

## Engineering Rules

- Use Verilog compatible with Icarus Verilog and MSYS2 UCRT64 commands.
- Use blocking `=` for combinational procedural logic and non-blocking `<=` for
  clocked logic.
- Make arithmetic widths explicit and avoid incomplete combinational assignments.
- Test normal, boundary, reset, enable, wraparound, carry/borrow, and overflow
  behavior as applicable.
- For clocked tests, check shortly after the edge, not exactly at `posedge`.
- Compile with `-Wall`, generate VCD files, and never claim PASS without running.
- Preserve user changes. Do not commit or push unless explicitly requested.

## Session Rule

Before changes: read progress, inspect `git status`, and run the relevant baseline.
After changes: rerun the test and update `docs/PROGRESS.md` with the result, known
issue, and one exact next action.

Each learning day must have one unified Markdown file under `docs/` that contains
that day's teaching notes, prediction prompts, hands-on tasks, debug exercise,
commands, waveform inspection checklist, explain-back prompt, and completion
criteria. Use that file as the teaching script and lab record for the day.

For a new conversation, use: "Read AGENTS.md, docs/PROGRESS.md, git status, and
the relevant RTL/testbench, then follow the unified Markdown file named by the
Exact Next Action. Continue from the Exact Next Action and preserve user changes."
