# Creating head style
$Style = @"
      
    <style>
      body {
        font-family: "Arial";
        font-size: 9pt;
        color: #4C607B;
        }
      th, td { 
        border: 1px solid #6f87a6;
        border-collapse: collapse;
        padding: 5px;
        }
      th {
        font-size: 1.2em;
        text-align: left;
        background-color: #003366;
        color: #ffffff;
        }
      td {
        color: #000000;
        }
      .even { background-color: #ffffff; }
      .odd { background-color: #bfbfbf; }
    </style>
      
"@
# Creating head style and header title
$output = $null
$output = @()
$output += '<html><head></head><body>'
$output +=
 
 #Import hmtl style file
$Style

# Variables
$date = Get-Date -Format MM/dd/yy
$MailFrom = 'user@domain.com'
$MailTo = 'user@domain.com'
$MailServer = 'server.mail.protection.outlook.com'

# Get replication status in HTML format
$status = Get-VMReplication -ComputerName HV01,HV02 | Select-Object Name, State, Health, Mode, FrequencySec, PrimaryServer, ReplicaServer, ReplicaPort | Sort-Object -property Name,Mode | ConvertTo-Html
$status2 = Measure-VMReplication -ComputerName HV01,HV02 | Select-Object VMName, State, Health, LReplTime, PReplSize, AvgLatency | Sort-Object -property VMName,Mode | ConvertTo-Html

#Replace status values with color in form
    $status = $status -replace 'Critical','<span style="color:red">Critical</span>'
    $status = $status -replace 'Warning','<span style="color:orange">Warning</span>'
    $status = $status -replace 'Normal','<span style="color:green">Normal</span>'

    $status2 = $status2 -replace 'Critical','<span style="color:red">Critical</span>'
    $status2 = $status2 -replace 'Warning','<span style="color:orange">Warning</span>'
    $status2 = $status2 -replace 'Normal','<span style="color:green">Normal</span>'

### Critical ###
if ((Get-VMReplication -ComputerName HV01,HV02 | select-string -inputobject {$_.Health} -pattern “Critical”) -like “Critical”)
{
    $output += '<strong><font color="red">CRITICAL Status: </font></strong>'
    $output += "Please review Hyper-V Replication Health.</br>"
    $output += '</br>'
    $output += '<hr>'
    $output += '<p>'
    $output += '<p>'
    $output += '</p>'
    $output += '</body></html>'
    $output =  $output | Out-String
    $MailSubject = "Hyper-V Replica Report $date !!!!!!!CRITICAL!!!!!!!"
    Send-MailMessage -From $MailFrom -To $MailTo -Subject $MailSubject -BodyAsHtml -Body "$output $status <br/> <br/> $status2" -SmtpServer $MailServer 
}

### Warning ###
elseif ((Get-VMReplication -ComputerName HV01,HV02 | select-string -inputobject {$_.Health} -pattern “Warning”) -like “Warning”)
{
    $output += '<strong><font color="orange">WARNING Status: </font></strong>'
    $output += "Please review Hyper-V Replication Health.</br>"
    $output += '</br>'
    $output += '<hr>'
    $output += '<p>'
    $output += '<p>'
    $output += '</p>'
    $output += '</body></html>'
    $output =  $output | Out-String
    $MailSubject = "Hyper-V Replica Report $date !!!!!!!WARNING!!!!!!!!"
    Send-MailMessage -From $MailFrom -To $MailTo -Subject $MailSubject -BodyAsHtml -Body "$output $status <br/> <br/> $status2" -SmtpServer $MailServer
}



### Healthy ###
else
{
    $output += '<strong><font color="green">Healthy Status: </font></strong>'
    $output += "Hyper-V Replication is Healthy.</br>"
    $output += '</br>'
    $output += '<hr>'
    $output += '<p>'
    $output += '<p>'
    $output += '</p>'
    $output += '</body></html>'
    $output =  $output | Out-String
    $MailSubject = "Hyper-V Replica Report $date Healthy"
    Send-MailMessage -From $MailFrom -To $MailTo -Subject $MailSubject -BodyAsHtml -Body "$output $status <br/> <br/> $status2" -SmtpServer $MailServer
}

