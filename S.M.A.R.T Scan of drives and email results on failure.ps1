# Source for smartmontools (smartctl.exe):  https://www.smartmontools.org/wiki/Download
# This script can be run with PDQ (pdq.com) Inventory Powershell Scan Profile (or other means of remote powershell execution)

$results = $null
\\UNC-Path\PDQ_Repo_2\SmartCTL\smartctl --scan | Out-File disks.csv
$disktest = get-content .\disks.csv

foreach ($item in $disktest){
$results += \\UNC-Path\PDQ_Repo_2\SmartCTL\smartctl -a (($item.Split(" "))[0]) #
}

$results | Select-string 'Product','Device Model','Health Status','overall-health'

###########################################################################
# This section forces email to mail-server to go over VPN connection and out to cloud (emailing from home public IP addresses is not possible)
if ($results -like '*failure*') { 

    Add-Type -AssemblyName PresentationFramework

    #resolve dns servers for outlook
    $outlookdns = Resolve-DnsName -name server.mail.protection.outlook.com 
    #Add route for outlook to email from company IP over VPN (useful for split tunnel VPN)
    foreach ($value in $outlookdns)
    {
    route ADD @($value.IPAddress) MASK 255.255.255.255 192.168.75.1
    }
    start-sleep (3)
###########################################################################
# Variable creation and email IT Group
    $results | Out-File .\results.txt # Need to export to txt for line breaks to be included in email
    $resultshtml = Get-Content .\results.txt | Out-String
    $myhostname = [System.Net.Dns]::GetHostName()  #retrieve hostname of machine scan was run on
    $MailFrom = 'system@domain.com'
    $MailTo = 'it@domain.com'
    $MailServer = 'server.mail.protection.outlook.com'
    $MailSubject = "Hard drive failure on host $myhostname"
    $MailBody = "Computer with Hard Drive issues: `n $myhostname `n `n ======================================================================== `n ***Results of Scan*** `n $resultshtml"
    remove-item results.txt -Force # File Cleanup
    Send-MailMessage -From $MailFrom -To $MailTo -Subject $MailSubject -Body ($MailBody | Out-String) -SmtpServer $MailServer
}
remove-item disks.csv -Force # File cleanup
