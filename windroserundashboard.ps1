# Arguments: [http_port]

$serverProcess = "$PSScriptRoot\windrose\4129620\R5\Binaries\Win64\WindroseServer-Win64-Shipping.exe"

# Check if Windrose server starts successfully within 1 minute
# If not, exit
$serverStarted = $false
for ($i = 1; $i -le 60; $i++) {
    if (Get-WmiObject Win32_Process | Where-Object {$_.ExecutablePath -eq "$serverProcess"} -ErrorAction SilentlyContinue) {
        $serverStarted = $true
        break
    }
    Start-Sleep -Seconds 1
}
if (-not $serverStarted) { exit 0 }

# Start the Windrose+ dashboard
Set-Location "windrose\4129620"
$dashboardProcess = Start-Process powershell -ArgumentList '-NoProfile', '-ExecutionPolicy', 'Bypass', '-File', '.\windrose_plus\server\windrose_plus_server.ps1', '-Port', "$args[0]", '-GameDir', "$PSScriptRoot\windrose\4129620" -PassThru

# Exit if dashboard fails to start
Start-Sleep -Seconds 1
if (-not (Get-Process -Id $dashboardProcess.Id -ErrorAction SilentlyContinue)) {
    exit 0
}

# Monitor server process and terminate dashboard
# when server terminates
while ($true) {
    if (-not (Get-WmiObject Win32_Process | Where-Object {$_.ExecutablePath -eq "$serverProcess"} -ErrorAction SilentlyContinue)) {
        Stop-Process -Id $dashboardProcess.Id -Force
        exit 0
    }
    Start-Sleep -Seconds 1
}
