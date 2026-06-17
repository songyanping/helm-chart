param(
    [string]$BaseUrl = "http://jenkins-ecomm-hk.intranet.local/"
)

$ErrorActionPreference = "Stop"

$uri = [Uri]$BaseUrl
$hostName = $uri.Host
$port = if ($uri.Port -gt 0) { $uri.Port } elseif ($uri.Scheme -eq "https") { 443 } else { 80 }

Write-Host "Checking Jenkins HK: $BaseUrl"

try {
    $dns = Resolve-DnsName -Name $hostName -ErrorAction Stop
    $addresses = $dns | Where-Object { $_.IPAddress } | Select-Object -ExpandProperty IPAddress -Unique
    if ($addresses) {
        Write-Host "DNS: OK ($($addresses -join ', '))"
    } else {
        Write-Host "DNS: OK (no IPAddress field returned)"
    }
} catch {
    Write-Host "DNS: FAILED - $($_.Exception.Message)"
}

try {
    $tcp = Test-NetConnection -ComputerName $hostName -Port $port -WarningAction SilentlyContinue
    Write-Host "TCP ${port}: $($tcp.TcpTestSucceeded)"
    if ($tcp.RemoteAddress) {
        Write-Host "RemoteAddress: $($tcp.RemoteAddress)"
    }
} catch {
    Write-Host "TCP ${port}: FAILED - $($_.Exception.Message)"
}

try {
    $response = Invoke-WebRequest -Uri $BaseUrl -Method Head -UseBasicParsing -TimeoutSec 15
    Write-Host "HTTP: $([int]$response.StatusCode) $($response.StatusDescription)"
} catch {
    $statusCode = $_.Exception.Response.StatusCode.value__
    $statusDescription = $_.Exception.Response.StatusDescription
    if ($statusCode) {
        Write-Host "HTTP: $statusCode $statusDescription"
    } else {
        Write-Host "HTTP: FAILED - $($_.Exception.Message)"
    }
}
