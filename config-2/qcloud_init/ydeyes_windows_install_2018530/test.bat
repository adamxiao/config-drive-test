@echo off

cscript /nologo %~dp0check.js clear

::wait for timeout
ping 1.1.1.1 -n 1 -w 6000 > nul

::check YDLive Service is running
for /f "skip=3 tokens=4" %%i in ('sc query YDLive') do set "zt=%%i" &goto :live_condition
:live_condition
if /i NOT "%zt%" == "RUNNING" (
    cscript /nologo %~dp0check.js add ydeyes "process not exist"
    cscript %~dp0check.js complete ydeyes_windows_install 1 failed
    exit /b 0
)

::check YDService is running
for /f "skip=3 tokens=4" %%i in ('sc query YDService') do set "zt=%%i" &goto :service_condition
:service_condition
if /i NOT "%zt%" == "RUNNING" (
    cscript /nologo %~dp0check.js add ydeyes "process not exist"
    cscript %~dp0check.js complete ydeyes_windows_install 1 failed
    exit /b 0
)

cscript %~dp0check.js complete ydeyes_windows_install 0 suc
