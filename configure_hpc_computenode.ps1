.  "C:\ProgramData\WriteToLog.ps1"

$DefaultNodeTemplate = "Default ComputeNode Template"

LogWrite "Configuring Compute Node"
Add-PSSnapin Microsoft.HPC

LogWrite "Get-HpcNode Unapproved"
$node = Get-HpcNode -HealthState Unapproved -Name $env:COMPUTERNAME
LogWrite "Assign-HpcNodeTemplate"
Assign-HpcNodeTemplate -Name $DefaultNodeTemplate -Node $node -PassThru -Confirm:$false -ErrorAction SilentlyContinue -WarningAction SilentlyContinue -ErrorVariable Err
LogWrite "Get-HpcNode Offline"
   
$node = Get-HpcNode -HealthState OK -State Offline -Name $env:COMPUTERNAME
LogWrite "Set-HpcNode Unapproved"
Set-HpcNodeState -Name $env:COMPUTERNAME -State Online -ErrorAction Stop

if ($MapToTemplates) {
    foreach ($item in $MapToTemplates) {
        Add-HpcGroup -Name "$($item)Nodes" -NodeName $env:COMPUTERNAME -ErrorVariable Err -ErrorAction Stop -WarningAction Stop
    }
}