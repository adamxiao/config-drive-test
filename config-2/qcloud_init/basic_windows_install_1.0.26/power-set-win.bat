@echo off

echo Windows Registry Editor Version 5.00 > C:\powerset.reg
echo [HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\policies\system] >> C:\powerset.reg
if "TCE_CCB" == "%env%" (
echo "shutdownwithoutlogon"=dword:00000001 >> C:\powerset.reg
) else (
echo "shutdownwithoutlogon"=dword:00000000 >> C:\powerset.reg
)
echo [HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Reliability] >> C:\powerset.reg
echo "ShutdownReasonUI"=dword:00000000 >> C:\powerset.reg
echo "ShutdownReasonOn"=dword:00000000 >> C:\powerset.reg
echo [HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows NT\Reliability] >> C:\powerset.reg
echo "ShutdownReasonUI"=dword:00000000 >> C:\powerset.reg
echo "ShutdownReasonOn"=dword:00000000 >> C:\powerset.reg
echo [HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Windows] >> C:\powerset.reg
echo "ShutdownWarningDialogTimeout"=dword:00000001 >> C:\powerset.reg
echo [HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\ACPI\Parameters] >> C:\powerset.reg
echo "AMLIMaxCTObjs"=hex:04,00,00,00 >> C:\powerset.reg
echo "Attributes"=dword:00000070 >> C:\powerset.reg
echo [HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\ACPI\Parameters\WakeUp] >> C:\powerset.reg
echo "FixedEventMask"=hex:20,05 >> C:\powerset.reg
echo "FixedEventStatus"=hex:00,84 >> C:\powerset.reg
echo "GenericEventMask"=hex:18,50,00,10 >> C:\powerset.reg
echo "GenericEventStatus"=hex:10,00,ff,00 >> C:\powerset.reg
echo [HKEY_CURRENT_USER\Control Panel\Desktop] >> C:\powerset.reg
echo "AutoEndTasks"="1" >> C:\powerset.reg
echo Windows Registry Editor Version 5.00 >> C:\powerset.reg
regedit /s c:\powerset.reg

del c:\powerset.reg

start regedit.exe
taskkill /t /f /IM regedit.exe

ver > C:\ver.txt
findstr /r "6\. 10\." C:\ver.txt >nul
if %errorlevel% == 0 (
del C:\ver.txt
powercfg /hibernate off
powercfg -S SCHEME_MIN
rem disable usb suspend
powercfg /SETDCVALUEINDEX SCHEME_MIN 2a737441-1930-4402-8d77-b2bebba308a3 48e6b7a6-50f5-4782-a5d4-53bb8f07e226 0
powercfg /SETACVALUEINDEX SCHEME_MIN 2a737441-1930-4402-8d77-b2bebba308a3 48e6b7a6-50f5-4782-a5d4-53bb8f07e226 0
rem disable disk idle
powercfg /SETDCVALUEINDEX SCHEME_MIN SUB_DISK DISKIDLE 0
powercfg /SETACVALUEINDEX SCHEME_MIN SUB_DISK DISKIDLE 0
rem set power button shutdown
powercfg -SETACVALUEINDEX SCHEME_MIN SUB_BUTTONS PBUTTONACTION 3
powercfg -SETDCVALUEINDEX SCHEME_MIN SUB_BUTTONS PBUTTONACTION 3
IF ERRORLEVEL 0 (ECHO change ok)  else ( ECHO change fail)
powercfg -S SCHEME_MIN
IF ERRORLEVEL 0 (ECHO change ok) Else  ( ECHO change fail)
)

rem disable usb suspend
reg add "HKLM\System\CurrentControlSet\Enum\USB\VID_0627&PID_0001\42\Device Parameters" /v SelectiveSuspendOn /t REG_DWORD /d 0 /f
%~dp0\check_componet\devcon.exe disable "USB\VID_0627&PID_0001"
%~dp0\check_componet\devcon.exe enable "USB\VID_0627&PID_0001"
IF ERRORLEVEL 0 (ECHO disable usb suspend: ok) Else  ( ECHO disable usb suspend: fail)
del C:\ver.txt

