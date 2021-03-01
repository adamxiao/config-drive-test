function Log ($msg)
{
	echo "[$(GET-Date -Format 'yyyy/MM/dd HH:mm:ss')] $msg"
}

$DirName=$MyInvocation.MyCommand.Name
$DirName=$DirName.Substring(0,$DirName.length-4)
$dst="C:\$DirName"
if(!$PSScriptRoot){ $PSScriptRoot = Split-Path $MyInvocation.MyCommand.Path -Parent }
$KV = Get-Content "$PSScriptRoot\instance_id" | Out-String | ConvertFrom-StringData
$instance=$KV.instance_id
$lable="config-2"
mkdir "C:\Program Files\QCloud\Logs"
$cloud_init_log = "C:\Program Files\QCloud\Logs\tencent-cloud-init.$(GET-Date -Format 'yyyyMMddHHmmss').log"
Start-Transcript $cloud_init_log -Append -Force
Log "$DirName $instance $PSScriptRoot"
Get-ChildItem $PSScriptRoot -recurse | where {$_.extension -eq ".conf"}| where { -Not( $_.name -eq "os.conf") }|%    {
       Log "begion loop"
       $KV = Get-Content $_.FullName | Out-String | ConvertFrom-StringData
       $last_timestamp=$KV.timestamp
       $name=$KV.action
       $reg_timestamp =(Get-Itemproperty "hklm:SOFTWARE\Cloudbase Solutions\Cloudbase-Init\$instance\Plugins").$name
       If ($reg_timestamp -ne $last_timestamp){
            Log "match $PSScriptRoot and $dst"
            if ($PSScriptRoot -ne $dst){
                Log "copy files and start powershell..."
                mkdir $dst
                cp -r -Force $PSScriptRoot\* $dst
                start powershell  "$dst\$DirName.ps1"
                exit 0
            }

            Log "run $name"
            if ($name -eq "init"){
                $cvm_init_log = "C:\Program Files\QCloud\Logs\tencent-cvm-init.$(GET-Date -Format 'yyyyMMddHHmmss').log"
                cmd /c "$dst\cvm_init.bat" >> $cvm_init_log 2>&1
            }
            if ($name -eq "config_set_passwords"){
                net user $KV.username $KV.password
            }
            if ($name -eq "config_network_static"){
                $gateway=$KV.gateway
                route delete 0.0.0.0
                route add 0.0.0.0 mask 0.0.0.0 $gateway -p
                route delete 169.254.0.0
                route add 169.254.0.0 mask 255.255.128.0 $gateway -p
                route change 10.0.0.0 mask 255.0.0.0 $gateway -p
                route change 172.16.0.0 mask 255.240.0.0 $gateway -p
                route change 192.168.0.0 mask 255.255.0.0 $gateway -p
                $key=$KV.mac_addr
                $wmi=get-wmiobject -class win32_networkadapterconfiguration -filter "MACAddress=""$key"""
                Log $wmi
                $ret=$wmi.EnableStatic($KV.ip_addr,$KV.netmask)
                Log $ret
                $ret=$wmi.SetGateways($KV.gateway)
                Log $ret
                $ret=$wmi.SetDNSServerSearchOrder($KV.dns.Split(","))
                Log $ret
                $computerName = Get-WmiObject Win32_ComputerSystem
                $computername.Rename($KV.hostname)
            }
            if ($name -eq "config_network_dhcp"){
                $gateway=$KV.gateway
                route delete 0.0.0.0
                route add 0.0.0.0 mask 0.0.0.0 $gateway -p
                route delete 169.254.0.0
                route add 169.254.0.0 mask 255.255.128.0 $gateway -p
                route change 10.0.0.0 mask 255.0.0.0 $gateway -p
                route change 172.16.0.0 mask 255.240.0.0 $gateway -p
                route change 192.168.0.0 mask 255.255.0.0 $gateway -p
                $key=$KV.mac_addr
                $wmi=get-wmiobject -class win32_networkadapterconfiguration -filter "MACAddress=""$key"""
                Log $wmi
                $ret=$wmi.EnableDHCP()
                Log $ret
                $ret=$wmi.SetDNSServerSearchOrder()
                Log $ret
                $computerName = Get-WmiObject Win32_ComputerSystem
                $computername.Rename($KV.hostname)
            }
            Set-ItemProperty -Path "hklm:SOFTWARE\Cloudbase Solutions\Cloudbase-Init\$instance\Plugins" -Name $name -Value $last_timestamp
       }
}

if ($PSScriptRoot -eq $dst){
    Remove-Item $PSScriptRoot/ -Recurse -Force
}
Log "end"
Stop-Transcript
