$obj = get-wmiobject win32_computersystem
if ( $obj.Model -eq "Bochs" -or $obj.Model -eq "KVM") {
    exit
}

$service = Get-Service -Name cloudbase-init 
if ( $service.Name -eq "cloudbase-init" ) {
    exit
}

ipconfig /all >> c:\nic_init.log
echo "init nics start" >> c:\nic_init.log

$IP = "169.254.68.1"
$Mask = "255.255.255.252"
$MasterIndex = -1
$SlaveIndex = -1

function Log ($msg) {
	echo "[$(GET-Date -Format 'yyyy/MM/dd HH:mm:ss')] $msg" >> c:\nic_init.log
}

Get-WmiObject -class Win32_PnPEntity | Foreach-Object {
	if ($_.PNPDeviceID -like "*PCI\VEN_14E4&DEV_D802&SUBSYS_802114E4*") {
		Log "PNPDeviceID:$($_.PNPDeviceID)"
		$Friendlyname = $_.Name
		$adapter = get-wmiobject win32_networkadapter 
        $adapter | Foreach-Object {
            if ($_.MACAddress -like "*00:FF:FF:FF:FF:FF*") {
                #filter MACAddress
                if ($_.Name -eq $Friendlyname) {
                    #filter FriendlyName
                    Log "Friendlyname:$($_.Name)"
                    Log "MACAddress: $($_.MACAddress)"
                    $SlaveIndex = $_.DeviceID
                    Log "SlaveIndex:$SlaveIndex"
                }
            } else {
                if ($_.Name -eq $Friendlyname) {
                    #filter FriendlyName
                    Log "Friendlyname:$($_.Name)"
                    Log "MACAddress: $($_.MACAddress)"
                    $MasterIndex = $_.DeviceID
                    Log "MasterIndex:$MasterIndex"
				}				
			}
        }
	}
}

$NetInterface = (Get-WmiObject Win32_NetworkAdapterConfiguration | where { $_.Index -eq $SlaveIndex })
if ($NetInterface) {
    Log "Slave SetIp:$IP,Mask:$Mask"
    $NetInterface.EnableStatic([string[]]$IP, $Mask)
}
$NetInterface = (Get-WmiObject Win32_NetworkAdapterConfiguration | where { $_.Index -eq $MasterIndex })
if ($NetInterface) {
    Log "master nic reset and set route"
    $Gateway = $NetInterface.DefaultIPGateway 
    routedelete 0.0.0.0 -p 
    route add 0.0.0.0 mask 0.0.0.0 $gateway -p
    $NetInterface.EnableStatic([string[]]"10.10.10.10", $Mask)
    $NetInterface.EnableDHCP()
    route delete 169.254.0.0 -p
    route add 169.254.0.0 mask 255.255.128.0 $Gateway -p
    route change 10.0.0.0 mask 255.0.0.0 $Gateway -p
    route change 172.16.0.0 mask 255.240.0.0 $Gateway -p
    route change 192.168.0.0 mask 255.255.0.0 $Gateway -p
}

ipconfig /all >> c:\nic_init.log
route print >> c:\nic_init.log
echo "init nics success" >> c:\nic_init.log
