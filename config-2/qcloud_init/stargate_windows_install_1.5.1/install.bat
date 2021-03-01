@echo off
set root_dir=C:\Program Files\QCloud
set agent_path=%root_dir%\Stargate\sgagent.exe
set service_name=StargateSvc
set base_dir=%~dp0

if not exist "%root_dir%" (
    mkdir "%root_dir%"
)

sc query %service_name% > nul
if %errorlevel% == 0 (
:: 服务已安装
    sc stop %service_name% > nul
    sc delete %service_name% > nul
)

::wait for timeout
ping 1.1.1.1 -n 1 -w 5000 > nul
DEL /F /Q "%agent_path%"

pushd %base_dir%
unzip -o stargate.zip -d "%root_dir%"
popd

"%agent_path%" install
"%agent_path%" reset
"%agent_path%" start
exit /b %errorlevel%