@echo off
net stop wuauserv /y
echo Windows Registry Editor Version 5.00 >> c:\sus.reg
echo [HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate] >> c:\sus.reg
echo "WUServer"="http://windowsupdate.tencentyun.com" >> c:\sus.reg
echo "WUStatusServer"="http://windowsupdate.tencentyun.com" >> c:\sus.reg
echo [HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU] >> c:\sus.reg
echo "UseWUServer"=dword:00000001 >> c:\sus.reg
echo "NoAutoUpdate"=dword:00000000 >> c:\sus.reg
echo "AUOptions"=dword:00000003 >> c:\sus.reg
echo "ScheduledInstallDay"=dword:00000000 >> c:\sus.reg
echo "ScheduledInstallTime"=dword:00000003 >> c:\sus.reg

regedit /s c:\sus.reg
del c:\sus.reg
net start wuauserv
wuauclt /resetauthorization /detectnow
wuauclt /r /reportnow
