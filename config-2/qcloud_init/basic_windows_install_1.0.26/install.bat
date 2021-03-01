@echo off
setlocal enabledelayedexpansion
echo "-- basic_windows_install enter.."
set SUPPORTED_TIME_STANDARD=utc localtime

if "%1"=="" (set defined_idc=gz) else (set defined_idc=%1)
if "%3"=="" (set defined_time_standard=localtime) else (set defined_time_standard=%3)
echo "defined_time_standard=%defined_time_standard%"

rem Verify that time_standard is supported and valid
set FOUND_MATCH=
for %%N in (%SUPPORTED_TIME_STANDARD%) do (
    if /I "%%N"=="%defined_time_standard%" set FOUND_MATCH=1
)
if "!FOUND_MATCH!"=="" (
    echo [error] invalid time standard: %defined_time_standard%
    set defined_time_standard=localtime
)

echo %defined_idc% > C:\Windows\qcloudzone


powershell.exe -File %~dp0\nic_init.ps1
REM echo "-- reset winmgmt file"
REM net /y stop winmgmt
REM del /q /f /s C:\windows\system32\wbem\Repository\FS\*
REM net start winmgmt

if exist %~dp0..\basic_conf.ini (
    call %~dp0readconfig.bat platform env
    call %~dp0readconfig.bat tce_ntp ntp_list
)
echo "env=%env%"
echo "ntp_list=%ntp_list%"

REM power settting MUST not be remove for old mirrors
REM some windows set powercfg to support virsh shutdown
echo "-- set powercfg"
call %~dp0\power-set-win.bat

pushd %~dp0
cd C:\Windows
for /f "delims=" %%i in ('findstr ip= ipconfig_xen_vm.ini') do (set var=%%i)
popd

set ip=%var:~3%
set is_tce=F
if "%env%" == "TCE" set is_tce=T
if "%env%" == "TCE_CCB" set is_tce=T
if "%is_tce%" == "T" (
    echo "reset computername enter.."
    wmic computersystem where "name='%COMPUTERNAME%'" call rename %ip:.=_%
    echo "reset computername leave.."

    net start w32time
    w32tm /config /manualpeerlist:"%ntp_list:,= %" /syncfromflags:manual /reliable:yes /update
) else (
    net start w32time
    Reg add "HKLM\SYSTEM\ControlSet001\Services\W32Time\Config" /v "MinPollInterval" /t REG_DWORD /d 6 /f
    Reg add "HKLM\SYSTEM\ControlSet001\Services\W32Time\Config" /v "MaxPollInterval" /t REG_DWORD /d 10 /f
    Reg add "HKLM\SYSTEM\ControlSet001\Services\W32Time\TimeProviders\NtpClient" /v "SpecialPollInterval" /t REG_DWORD /d 300 /f
    Reg add "HKLM\SYSTEM\ControlSet002\Services\W32Time\Config" /v "MinPollInterval" /t REG_DWORD /d 6 /f
    Reg add "HKLM\SYSTEM\ControlSet002\Services\W32Time\Config" /v "MaxPollInterval" /t REG_DWORD /d 10 /f
    Reg add "HKLM\SYSTEM\ControlSet002\Services\W32Time\TimeProviders\NtpClient" /v "SpecialPollInterval" /t REG_DWORD /d 300 /f
    w32tm /config /update
    w32tm /config /manualpeerlist:"time1.tencentyun.com time2.tencentyun.com time3.tencentyun.com time4.tencentyun.com time5.tencentyun.com" /syncfromflags:manual /reliable:yes /update
)

goto case_%defined_time_standard%
:case_utc
    echo case_utc
    Reg query HKLM\SYSTEM\CurrentControlSet\Control\TimeZoneInformation /v RealTimeIsUniversal
    IF %ERRORLEVEL% equ 0 (
        echo utc is setting
        for /f "tokens=3" %%i in ('Reg query HKLM\SYSTEM\CurrentControlSet\Control\TimeZoneInformation /v RealTimeIsUniversal ^| find /i "RealTimeIsUniversal" ') do set utc_value=%%i
        if !utc_value! neq 1 (Reg add HKLM\SYSTEM\CurrentControlSet\Control\TimeZoneInformation /v RealTimeIsUniversal /t REG_QWORD /d 1 /f)
    ) else (
        Reg add HKLM\SYSTEM\CurrentControlSet\Control\TimeZoneInformation /v RealTimeIsUniversal /t REG_QWORD /d 1
    )
    goto case_end
:case_localtime
    echo case_localtime
    Reg query HKLM\SYSTEM\CurrentControlSet\Control\TimeZoneInformation /v RealTimeIsUniversal
    IF %ERRORLEVEL% equ 0 (
        echo need to delete RealTimeIsUniversal
        Reg delete HKLM\SYSTEM\CurrentControlSet\Control\TimeZoneInformation /v RealTimeIsUniversal /f
    )
    goto case_end
:case_end

rem keep ntp time sync util sucess
start /b %~dp0\ntp_time_sync.bat

ver > C:\ver.txt
set activateip=10.225.30.226:40433
if "TCE_CCB" == "%env%" (
    findstr "6." C:\ver.txt >nul
    if %errorlevel% == 0 (
        echo "-- activate windows license"
        cscript /nologo %windir%/system32/slmgr.vbs -skms %activateip%
        sc query w32time | findstr RUNNING >nul
        if %errorlevel% neq 0 ( net start w32time )
        for /l %%i in (1,1,30) do (
            w32tm /resync >null
            if %errorlevel% equ 0 (goto act)
        )
:act
        cscript /nologo %windir%/system32/slmgr.vbs -ato
    )
    goto end
) else (
    findstr "6\." C:\ver.txt >nul
    if %ERRORLEVEL% neq 1 ( set kmsaddr=kms.tencentyun.com:1688 & goto _kms)
    findstr "10\." C:\ver.txt >nul
    if %ERRORLEVEL% neq 1 ( set kmsaddr=kms.tencentyun.com:1688 & goto _kms)
:_kms
    cscript /nologo %windir%/system32/slmgr.vbs -skms %kmsaddr%
    net start w32time
    for /l %%i in (1,1,10) do (
        w32tm /resync | findstr /r "successfully 成功" >nul
        if !ERRORLEVEL! neq 1 ( goto _break ) else ( timeout /t 1 /nobreak >nul )
    )
:_break
    cscript /nologo %windir%/system32/slmgr.vbs -ato
)
:end
del C:\ver.txt

%~dp0\check_componet\curl.exe metadata.tencentyun.com/meta-data/instance/os-name 
if %errorlevel% == 0 (
    for /f "delims=" %%a in ('%~dp0\check_componet\curl.exe metadata.tencentyun.com/meta-data/instance/os-name') do set osname=%%a
    echo "!osname!" | findstr safe
    if !errorlevel! == 0 (
        call C:\cygwinroot\tmp\after\install_service.bat
        echo "call C:\cygwinroot\tmp\after\install_service.bat"

        for /f "tokens=2 delims=:" %%i in ('" Systeminfo | find "System Model" "') do set model=%%i
        echo !model! | findstr "KVM Bochs"
        if !errorlevel! == 0 (
            REM CVM
            for /f "tokens=2 delims= " %%i in ('"netsh int ipv4 show in |find /i "connected"|findstr /n "connected"|find "2:""') do set idx1=%%i
        ) else (
            REM BM
            for /f "tokens=2 delims= " %%i in ('"netsh int ipv4 show in |find /i "connected"|findstr /n "connected"|find "3:""') do set idx1=%%i
        )

        REM BM and CVM compatible
        set dhcpserver=DHCP Server
        set defaultgw=Default Gateway
        ver|find "版本" >nul&& set language=chinese|| set language=english
        if "!language!" == "chinese" (
        set dhcpserver=DHCP 服务器
        set defaultgw=默认网关
        ) 
        for /f "delims=: tokens=2" %%i in ('"ipconfig /all | find /i "!dhcpserver!" | findstr /r "[0-9][0-9]*\.[0-9][0-9]*\.[0-9][0-9]*\.[0-9][0-9]*" "') do set gwip=%%i
        for /f "tokens=*" %%i in ("!gwip!") do set "gwip=%%i"

        if "!gwip!"=="" (
        for /f "delims=: tokens=2" %%i in ('"ipconfig /all | find /i "!defaultgw!" | findstr /r "[0-9][0-9]*\.[0-9][0-9]*\.[0-9][0-9]*\.[0-9][0-9]*" "') do set gwip=%%i
        for /f "tokens=*" %%i in ("!gwip!") do set "gwip=%%i"
        )
        echo "change route !gwip! IF !idx1!"

        route delete 10.0.0.0 mask 255.0.0.0
        route add 10.0.0.0 mask 255.0.0.0 !gwip! IF !idx1! -p
	
	    route delete 172.16.0.0 mask 255.240.0.0
        route add 172.16.0.0 mask 255.240.0.0 !gwip! IF !idx1! -p

	    route delete 192.168.0.0 mask 255.255.0.0
        route add 192.168.0.0 mask 255.255.0.0 !gwip! IF !idx1! -p

	    route delete 100.64.0.0 mask 255.192.0.0
        route add 100.64.0.0 mask 255.192.0.0 !gwip! IF !idx1! -p

	    route delete 9.0.0.0 mask 255.0.0.0
        route add 9.0.0.0 mask 255.0.0.0 !gwip! IF !idx1! -p

	    route delete 11.0.0.0 mask 255.0.0.0
        route add 11.0.0.0 mask 255.0.0.0 !gwip! IF !idx1! -p

	    route delete 30.0.0.0 mask 255.0.0.0
        route add 30.0.0.0 mask 255.0.0.0 !gwip! IF !idx1! -p

        route delete 0.0.0.0 mask 0.0.0.0
        route add 0.0.0.0 mask 0.0.0.0 !gwip! -p
    )
)
rd /q /s C:\$recycle.bin
echo "-- basic_windows_install ~leave"

