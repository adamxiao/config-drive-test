@echo off

cscript /nologo %~dp0check.js clear

::wait for timeout
ping 1.1.1.1 -n 1 -w 6000 > nul

set srv=StargateSvc
for /f "skip=3 tokens=4" %%i in ('sc query %srv%') do set "zt=%%i" &goto :next

:next
if /i NOT "%zt%" == "RUNNING" (
    cscript /nologo %~dp0check.js add stargate "process not exist"
    cscript %~dp0check.js complete stargate_windows_install 1 failed
    exit /b 0
)

cscript %~dp0check.js complete stargate_windows_install 0 suc
