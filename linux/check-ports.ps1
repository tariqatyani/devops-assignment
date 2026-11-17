# check-ports.ps1 - run on the WINDOWS host to prove the VM firewall (Task 5).
# Usage (PowerShell, in the linux\ folder):
#   powershell -ExecutionPolicy Bypass -File .\check-ports.ps1
# Why read a banner instead of Test-NetConnection: VirtualBox NAT port forwarding can accept the
# TCP connection on the host side even if the guest firewall drops it. A real answer (MySQL
# greeting / SSH banner) can only come from the service inside the VM.
param([int[]]$Ports = @(13306, 2222))   # 13306 -> guest 3306 (MySQL), 2222 -> guest 22 (SSH)

foreach ($p in $Ports) {
  $c = New-Object System.Net.Sockets.TcpClient
  try {
    if (-not $c.ConnectAsync('127.0.0.1', $p).Wait(5000)) { throw "connect timed out" }
    $s = $c.GetStream(); $s.ReadTimeout = 8000
    $buf = New-Object byte[] 256
    $n = $s.Read($buf, 0, $buf.Length)
    if ($n -le 0) { throw "connection closed, no service answered" }
    $txt = ([Text.Encoding]::ASCII.GetString($buf, 0, $n)) -replace '[^\x20-\x7E]', '.'
    Write-Host ("127.0.0.1:{0}  OPEN     service answered: {1}" -f $p, $txt) -ForegroundColor Green
  } catch {
    $msg = if ($_.Exception.InnerException) { $_.Exception.InnerException.Message } else { $_.Exception.Message }
    Write-Host ("127.0.0.1:{0}  BLOCKED  {1}" -f $p, $msg) -ForegroundColor Red
  } finally { $c.Dispose() }
}
