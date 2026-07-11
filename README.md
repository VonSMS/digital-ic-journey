# Digital IC Learning Journey

这是我的数字 IC / AI hardware 入门仓库。

## 目标

入学前完成一个可以展示给导师的小型 RTL 工程，逐步覆盖：

- 数字逻辑基础
- Verilog/SystemVerilog
- 自动化 testbench
- waveform debug
- Python golden model
- 简单综合报告

## 第一周计划

| Day | 任务 | 验收标准 |
| --- | --- | --- |
| Day 1 | 配置 Git、Python、Icarus/Verilator、GTKWave，建立仓库 | 能运行工具检查脚本，仓库结构清楚 |
| Day 2 | 学习二进制、补码、Boolean algebra | 完成笔记和逻辑门练习 |
| Day 3 | half adder、full adder、parameterised adder | RTL + testbench + waveform |
| Day 4 | multiplexer 和简单 ALU | 自动测试覆盖基本操作 |
| Day 5 | flip-flop、register、counter | 能解释时序逻辑和波形 |
| Day 6 | ALU 自检查 testbench | 正常和边界情况 pass/fail |
| Day 7 | README、diagram、测试结果、本周总结 | 别人可以读懂并运行项目 |

## 仓库结构

```text
.
├── docs/          # 学习笔记、周总结、截图说明
├── rtl/           # SystemVerilog/Verilog 设计代码
├── tb/            # testbench
├── scripts/       # 工具检查和运行脚本
├── sim/           # 仿真输出，通常不提交
└── README.md
```

## Day 1 工具检查

在 PowerShell 里运行：

```powershell
.\scripts\check_tools.ps1
```

目标是逐步让下面这些工具都显示版本号：

- Git
- Python
- GCC
- Icarus Verilog 或 Verilator
- GTKWave
- Yosys

