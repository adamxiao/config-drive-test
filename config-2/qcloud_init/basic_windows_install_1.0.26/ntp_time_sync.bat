rem if "%1"=="hide" goto CmdBegin
rem start mshta vbscript:createobject("wscript.shell").run("""%~0"" hide",0)(window.close)&&exit
rem :CmdBegin

@echo off
net start w32time
:loop
echo %date% %time%:ͬ���� > c:/basic_ntp_log.txt
w32tm /resync | findstr /r "successfully �ɹ�" >nul
if %errorlevel% neq 0 goto :loop

echo %date% %time%:ͬ���ɹ� > c:/basic_ntp_log.txt

exit