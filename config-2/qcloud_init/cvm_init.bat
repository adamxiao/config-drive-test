route delete 0.0.0.0
echo %date:~0,10% %time:~0,8%
route add 0.0.0.0 mask 0.0.0.0 172.16.16.1 -p
echo %date:~0,10% %time:~0,8%
route delete 169.254.0.0
echo %date:~0,10% %time:~0,8%
route add 169.254.0.0 mask 255.255.128.0 172.16.16.1 -p
echo %date:~0,10% %time:~0,8%
route change 10.0.0.0 mask 255.0.0.0 172.16.16.1 -p
echo %date:~0,10% %time:~0,8%
route change 172.16.0.0 mask 255.240.0.0 172.16.16.1 -p
echo %date:~0,10% %time:~0,8%
route change 192.168.0.0 mask 255.255.0.0 172.16.16.1 -p
echo %date:~0,10% %time:~0,8%
PowerShell -Command "$uuidFile = dir -name C:/WINDOWS/system32/drivers/etc/ | where {$_-match '[a-z0-9A-Z]{8}-[a-z0-9A-Z]{4}-[a-z0-9A-Z]{4}-[a-z0-9A-Z]{4}-[a-z0-9A-Z]{12}$'};if($uuidFile) {rm C:/WINDOWS/system32/drivers/etc/$uuidFile}"
echo %date:~0,10% %time:~0,8%
echo uuid = 73589e8e-90ff-4f90-88bd-57bbef3bc3db > C:/WINDOWS/system32/drivers/etc/73589e8e-90ff-4f90-88bd-57bbef3bc3db
echo %date:~0,10% %time:~0,8%
cd C:\
echo %date:~0,10% %time:~0,8%
cmd /c C:\qcloud_init\stargate_windows_install_1.5.1\install.bat gzvpc
echo %date:~0,10% %time:~0,8%
cmd /c C:\qcloud_init\basic_windows_install_1.0.26\install.bat gzvpc public localtime
echo %date:~0,10% %time:~0,8%
cmd /c C:\qcloud_init\ydeyes_windows_install_2018530\install.bat gzvpc
echo %date:~0,10% %time:~0,8%
cmd /c C:\qcloud_init\agenttools_windows_uninstall\.\uninstall.bat gzvpc
echo %date:~0,10% %time:~0,8%
cscript %windir%/system32/slmgr.vbs -skms kms.tencentyun.com
echo %date:~0,10% %time:~0,8%
cscript %windir%/system32/slmgr.vbs -ato
echo %date:~0,10% %time:~0,8%
dir C:\qcloud_init\ >> C:\cvm_init.log
echo %date:~0,10% %time:~0,8%
rd /s/q C:\qcloud_init
echo %date:~0,10% %time:~0,8%
del C:\cvm_init.bat
echo %date:~0,10% %time:~0,8%

echo %date:~0,10% %time:~0,8%
