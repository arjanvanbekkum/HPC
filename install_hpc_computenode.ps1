.  "C:\ProgramData\WriteToLog.ps1"

LogWrite "Starting computenode."

LogWrite "Computer $env:computername"
LogWrite "UserName $env:username"

LogWrite "Create Self Signed Certifcate"
$tgtdir = "C:\ProgramData\HPC\2016\"
$certpath = "C:\ProgramData\HPCCertificate.pfx"

$cerFileName = "C:\ProgramData\HpcHnPublicCert.cer"
Import-Certificate -FilePath $cerFileName -CertStoreLocation Cert:\LocalMachine\Root  

$certificate_password = aws ssm get-parameter --name "/certificate/hpc/password" --query "Parameter.Value" --with-decryption --output text --region eu-central-1

$dnsname = aws ssm get-parameter --name " /Vpc/Default/PrivateDns/Name" --query "Parameter.Value" --output text --region eu-central-1
$headnode = "headnode.$dnsname"

$setupArg = "-unattend -computenode:$headnode -SSLPfxFilePath:$certpath -SSLPfxFilePassword:$certificate_password"

while($true)
{
    LogWrite "Installing HPC Pack Head Node"
    $p = Start-Process -FilePath "$tgtdir\setup.exe" -ArgumentList $setupArg -PassThru -Wait
    if($p.ExitCode -eq 0)
    {
        LogWrite "Succeed to Install HPC Pack Head Node"
        break
    }
    if($p.ExitCode -eq 3010)
    {
        LogWrite "Succeed to Install HPC Pack Head Node, a reboot is required."
        break
    }

    if($retry++ -lt $maxRetryTimes)
    {
        $retryInterval = [System.Math]::Min($maxRetryInterval, $retry * 10)
        Write-Warning "Failed to Install HPC Pack Head Node (errCode=$($p.ExitCode)), retry after $retryInterval seconds..."            
        Clear-DnsClientCache
        Start-Sleep -Seconds $retryInterval
    }
    else
    {
        if($p.ExitCode -eq 13818)
        {
            throw "Failed to Install HPC Pack Head Node (errCode=$($p.ExitCode)): the certificate doesn't meet the requirements."
        }
        else
        {
            throw "Failed to Install HPC Pack Head Node (errCode=$($p.ExitCode))"
        }
    }
}


LogWrite "Done"
