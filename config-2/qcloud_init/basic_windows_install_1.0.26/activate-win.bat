@echo off

ver > C:\ver.txt
findstr "6." C:\ver.txt >nul
if %ERRORLEVEL% == 0 (
    cscript /nologo %windir%/system32/slmgr.vbs -skms kms.tencentyun.com:1688
    sc query w32time | findstr RUNNING >null
    if %ERRORLEVEL% == 0 ( net start w32time )
    for /l %%i in (1,1,10) do (
      w32tm /resync | findstr successfully >null
      if %ERRORLEVEL% == 1 ( goto _break ) else ( timeout /t 1 /nobreak >null )
    )
:_break
    cscript /nologo %windir%/system32/slmgr.vbs -ato
)

del C:\ver.txt

