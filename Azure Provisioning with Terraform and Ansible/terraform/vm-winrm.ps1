# Crear directorio de trabajo
New-Item -Path "C:\Temp" -ItemType Directory -Force | Out-Null

# Habilitar WinRM
Enable-PSRemoting -Force

# Crear certificado autofirmado
$cert = New-SelfSignedCertificate -DnsName "localhost" `
  -CertStoreLocation Cert:\LocalMachine\My `
  -KeyLength 2048 `
  -FriendlyName "WinRM HTTPS" `
  -NotAfter (Get-Date).AddYears(2)

# Registrar listener HTTPS con ese certificado
$thumb = $cert.Thumbprint

# Eliminar listeners previos si existen
Get-ChildItem -Path WSMan:\Localhost\Listener | Where-Object { $_.Keys -like "*Transport=HTTPS*" } | Remove-Item -Recurse -Force

New-Item -Path WSMan:\Localhost\Listener `
  -Transport HTTPS `
  -Address * `
  -CertificateThumbprint $thumb `
  -Force | Out-Null

# Permitir tráfico por el puerto 5986
New-NetFirewallRule `
  -DisplayName "Allow WinRM HTTPS" `
  -Direction Inbound `
  -Action Allow `
  -Protocol TCP `
  -LocalPort 5986

# Políticas de seguridad requeridas
Set-Item -Path WSMan:\localhost\Service\AllowUnencrypted -Value $false
Set-Item -Path WSMan:\localhost\Service\Auth\Basic -Value $true

# Reiniciar servicio WinRM
Restart-Service WinRM

# Confirmar que está corriendo
Write-Output "WinRM HTTPS Listener configured successfully."
