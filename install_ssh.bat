@echo off
cls
setlocal

echo [ + ] Installing OpenSSH-Server on windows ...

for /F "skip=1 delims=" %%a in ('C:\Windows\System32\wbem\WMIC.exe os get version') do (set "ver=%%a"&goto break)
:break
if /i %ver:~0,1%==1 (
"C:\Windows\System32\msiexec.exe" /i "%~dp0OpenSSH-Win64-v9.5.0.0.msi" /quiet

echo [ + ] Replacing sshd_config ...

copy \\[DC FQDN/IP]\SSH_GPO\sshd_config "C:\ProgramData\ssh" /y

echo [ + ] Make powershell default ...

%SYSTEMROOT%\System32\WindowsPowerShell\v1.0\powershell.exe -Command New-ItemProperty -Path "HKLM:\SOFTWARE\OpenSSH" -Name DefaultShell -Value "C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe" -PropertyType String -Force

echo [ + ] Configuring firewall settings ...

%SYSTEMROOT%\System32\WindowsPowerShell\v1.0\powershell.exe -Command netsh advfirewall firewall add rule name='SSH' dir=in action=allow protocol=TCP localport=22 profile=Domain remoteip=[10.0.0.0/24] enable=yes

echo [ + ] Restart SSH service ...
net stop sshd
net start sshd

)else (
echo "Windows version is wrong!!!"
)
endlocal 