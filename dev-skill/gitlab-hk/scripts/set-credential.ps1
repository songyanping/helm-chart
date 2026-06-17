param(
  [Parameter(Mandatory = $true)]
  [string] $Username,

  [Parameter(Mandatory = $true)]
  [SecureString] $Password
)

$target = "gitlab-hk.intranet.local"
$bstr = [Runtime.InteropServices.Marshal]::SecureStringToBSTR($Password)
try {
  $plain = [Runtime.InteropServices.Marshal]::PtrToStringBSTR($bstr)
  cmdkey /generic:$target /user:$Username /pass:$plain | Out-Null
  Write-Output "Stored credential for $target as $Username."
}
finally {
  if ($bstr -ne [IntPtr]::Zero) {
    [Runtime.InteropServices.Marshal]::ZeroFreeBSTR($bstr)
  }
}
