$outputFile = "system_info.txt"

# Header
"System Information Report - $(Get-Date)" | Out-File $outputFile
"=" * 50 | Out-File $outputFile -Append

# OS
$os = Get-CimInstance Win32_OperatingSystem
"Operating System   : $($os.Caption) ($($os.OSArchitecture))" | Out-File $outputFile -Append
"Version / Build    : $($os.Version) / $($os.BuildNumber)" | Out-File $outputFile -Append

# CPU
$cpu = Get-CimInstance Win32_Processor | Select-Object -First 1
"Processor          : $($cpu.Name.Trim())" | Out-File $outputFile -Append
"   Cores (Logical) : $($cpu.NumberOfCores) ($($cpu.NumberOfLogicalProcessors))" | Out-File $outputFile -Append
"   Max Clock Speed : $($cpu.MaxClockSpeed) MHz" | Out-File $outputFile -Append

# Memory
$ramMB = [math]::Round($os.TotalVisibleMemorySize / 1KB, 0)
"Total Physical RAM : $ramMB MB" | Out-File $outputFile -Append

# GPU
$graphics = Get-CimInstance Win32_VideoController
"Graphics Devices   :" | Out-File $outputFile -Append
foreach ($gpu in $graphics) {
    $ramGPU = if ($gpu.AdapterRAM) { [math]::Round($gpu.AdapterRAM / 1MB, 0) } else { "N/A" }
    "   - $($gpu.Name.Trim())  |  VRAM: $ramGPU MB  |  Driver: $($gpu.DriverVersion)" | Out-File $outputFile -Append
}

# Disk drives (fixed local)
"Disk Drives (fixed):" | Out-File $outputFile -Append
Get-CimInstance Win32_LogicalDisk -Filter "DriveType=3" | ForEach-Object {
    $total = [math]::Round($_.Size / 1GB, 2)
    $free  = [math]::Round($_.FreeSpace / 1GB, 2)
    "   - $($_.DeviceID)  Total: ${total}GB  Free: ${free}GB" | Out-File $outputFile -Append
}

# Network adapters (enabled)
"Network Adapters   :" | Out-File $outputFile -Append
Get-CimInstance Win32_NetworkAdapter | Where-Object { $_.NetEnabled -eq $true } | ForEach-Object {
    "   - $($_.Name)  ($($_.MACAddress))" | Out-File $outputFile -Append
}

# DirectX version (from registry)
$dxKey = Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\DirectX" -Name "Version" -ErrorAction SilentlyContinue
if ($dxKey) {
    "DirectX Version    : $($dxKey.Version)" | Out-File $outputFile -Append
} else {
    "DirectX Version    : Registry key not found" | Out-File $outputFile -Append
}

# Output Report
"=" * 50 | Out-File $outputFile -Append
"Report saved to: $((Get-Location).Path)\$outputFile" | Out-File $outputFile -Append
