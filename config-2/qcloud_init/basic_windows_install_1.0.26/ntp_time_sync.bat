rem if "%1"=="hide" goto CmdBegin
rem start mshta vbscript:createobject("wscript.shell").run("""%~0"" hide",0)(window.close)&&exit
rem :CmdBegin

@echo off
net start w32time
:loop
echo %date% %time%:同步中 > c:/basic_ntp_log.txt
w32tm /resync | findstr /r "successfully 成功" >nul
if %errorlevel% neq 0 goto :loop

echo %date% %time%:同步成功 > c:/basic_ntp_log.txt

exit