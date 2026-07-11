# Day 1 Setup Notes

日期：2026-07-11

## 今日目标

1. 建立本地学习仓库。
2. 检查 Git、Python、GCC、Icarus/Verilator、GTKWave、Yosys 是否可用。
3. 明确缺失工具的安装路线。
4. 形成第一周项目目录。

## 当前检查结果

Codex 检查到：系统 PATH 中暂时找不到 `git`、`python`、`gcc`、`iverilog`、`verilator`、`gtkwave`、`yosys`、`gh`。

Codex 自带运行环境中可用：

- Git 2.53.0
- Python 3.12.13

这说明今天可以先完成仓库搭建；系统级工具需要继续安装并加入 PATH。

## 推荐安装路线

Windows 上最稳的路线是安装 MSYS2，然后用它安装硬件工具链：

1. 安装 MSYS2：https://www.msys2.org/
2. 打开 "MSYS2 UCRT64" 终端。
3. 更新包管理器：

```bash
pacman -Syu
```

4. 关闭窗口后重新打开 "MSYS2 UCRT64"，继续：

```bash
pacman -S --needed git mingw-w64-ucrt-x86_64-python mingw-w64-ucrt-x86_64-gcc mingw-w64-ucrt-x86_64-iverilog mingw-w64-ucrt-x86_64-gtkwave mingw-w64-ucrt-x86_64-yosys
```

5. 把 MSYS2 UCRT64 的 bin 目录加入 Windows PATH，通常是：

```text
C:\msys64\ucrt64\bin
C:\msys64\usr\bin
```

6. 重新打开 PowerShell，运行：

```powershell
.\scripts\check_tools.ps1
```

## GitHub 仓库

本地仓库建好后，再创建 GitHub 远程仓库。推荐仓库名：

```text
digital-ic-journey
```

如果暂时没有 GitHub CLI，可以先在 GitHub 网页新建空仓库，然后在本地运行：

```powershell
git remote add origin https://github.com/<your-username>/digital-ic-journey.git
git branch -M main
git push -u origin main
```

