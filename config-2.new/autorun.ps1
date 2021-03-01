$lable="config-2"
if(!$PSScriptRoot){
    $PSScriptRoot = Split-Path $MyInvocation.MyCommand.Path -Parent
}

powershell "$PSScriptRoot/qcloud_action/qcloud_action.ps1"
powershell "$PSScriptRoot/qcloud_init/qcloud_init.ps1"


$Eject = New-Object -ComObject "Shell.Application"

$Eject.Namespace(17).Items()| Where-Object { $_.Name.contains($label) } | 
    foreach {
        echo $_
        $_.InvokeVerb("Eject")
    }