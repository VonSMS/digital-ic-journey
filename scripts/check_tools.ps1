$tools = @(
  @{ Name = "Git"; Commands = @("git --version") },
  @{ Name = "Python"; Commands = @("python --version", "py --version") },
  @{ Name = "GCC"; Commands = @("gcc --version") },
  @{ Name = "Icarus Verilog"; Commands = @("iverilog -V") },
  @{ Name = "Verilator"; Commands = @("verilator --version") },
  @{ Name = "GTKWave"; Commands = @("gtkwave --version") },
  @{ Name = "Yosys"; Commands = @("yosys -V") }
)

foreach ($tool in $tools) {
  $ok = $false
  foreach ($cmd in $tool.Commands) {
    try {
      $output = Invoke-Expression $cmd 2>$null
      if ($LASTEXITCODE -eq 0 -or $output) {
        Write-Host "[OK] $($tool.Name): $($output | Select-Object -First 1)"
        $ok = $true
        break
      }
    } catch {
      # Try the next command.
    }
  }
  if (-not $ok) {
    Write-Host "[MISSING] $($tool.Name)"
  }
}

