## iex ((New-Object System.Net.WebClient).DownloadString('http://dreamthief.us/CoreServerSetup03.ps1'))


<#
TODO:
    Timezone check 
        Set-TimeZone -Name "Pacific Standard Time"
    Time Check
        NTP Servers
    WindowsUpdates
setup64 /c

#>

clear-host

##Banner
Write-host "#############################################################" -ForegroundColor Green
Write-host "###                  Welcome to CUSCo                     ###" -ForegroundColor Green
Write-host "###     Casteel's Ultimate Server Configuration           ###" -ForegroundColor Green
Write-host "###                  Use at your own risk!                ###" -ForegroundColor Green
Write-host "###                                                       ###" -ForegroundColor Green
Write-host "#############################################################" -ForegroundColor Green
write-host ""
write-host ""


### Ask for input
$newhost = read-host "What is the hostname for this server?" 
write-host ""
$ipaddr = read-host "What is the IP Address?"
write-host ""
$subnet = read-host "What is the Subnet? Slash format e.g. 24 or 27 or 16"

if ($subnet -eq 30)	{$mask = "255.255.255.252"}
elseif	($subnet -eq 29)	{$mask = "255.255.255.248"}	
elseif ($subnet -eq 28)	{$mask = "255.255.255.240"}
elseif	($subnet -eq 27)	{$mask = "255.255.255.224"}	
elseif	($subnet -eq 26)	{$mask = "255.255.255.192"	}
elseif	($subnet -eq 25)	{$mask = "255.255.255.128"	}
elseif	($subnet -eq 24)	{$mask = "255.255.255.0"}
elseif	($subnet -eq 23)	{$mask = "255.255.254.0"}	
elseif	($subnet -eq 22)	{$mask = "255.255.252.0"}	
elseif	($subnet -eq 21)	{$mask = "255.255.248.0"}	
elseif	($subnet -eq 20)	{$mask = "255.255.240.0"}	
elseif	($subnet -eq 19)	{$mask = "255.255.224.0"}	
elseif	($subnet -eq 18)	{$mask = "255.255.192.0"}	
elseif	($subnet -eq 17)	{$mask = "255.255.128.0"}	
elseif	($subnet -eq 16)	{$mask = "255.255.0.0"	}

write-host ""
$gateway = read-host "What is the gateway address?"
write-host ""
$dns = read-host "What is the DNS? More can be added after final config if needed"

### Write out the input
write-host ""
Write-host "The new hostname will be:    " -NoNewline -foregroundcolor yellow
write-host $newhost.ToUpper() -ForegroundColor red
Write-host "  The IP Address will be:    " -nonewline -ForegroundColor yellow
write-host $ipaddr -ForegroundColor red
Write-host " The subnet mask will be:    " -nonewline -ForegroundColor yellow
write-host $mask -ForegroundColor red
Write-host "     The gateway will be:    " -nonewline -ForegroundColor yellow
write-host $gateway -ForegroundColor red
Write-host "  The DNS Server will be:    "-nonewline -ForegroundColor yellow
write-host $dns -ForegroundColor red
write-host ""
write-host ""

##Final warnings
write-host ""
Write-host "This script will make the following changes to this machine"
write-host ""
write-host "  1. Update the network to the above details"
write-host "  2. Install Choclatey" 
write-host "  3. Allow Ping through the firewall"
write-host "  4. Enable RDP Access and allow it through the firewall"
write-host "  5. Enable PS remote access and allow ANY machine to connect" 
write-host "  6. "  
write-host "  7. "  -ForegroundColor red
write-host "  8. " 
write-host ""
write-host ""


$choice = ""
while ($choice -notmatch "[y|n]") {
    $choice = read-host "Do you want to continue? (Y/N)" 
}

if ($choice -eq "n") {
    break
}

write-host ""
write-host ""
Write-host "...and so we begin!" -ForegroundColor red
write-host ""
write-host ""
write-host ""

# import needed modules
write-host "Importing needed modules" -ForegroundColor Green
import-module netsecurity, dnsclient, NetTCPIP, netadapter
write-host "Import complete" -ForegroundColor Green
write-host ""

### Rename the server
Write-host "Renaming the computer"
rename-computer $newhost
Write-Host "Computer rename process complete" -ForegroundColor Green
write-host ""


### Install choclatey
Write-Host "Installing Chocolatey" -ForegroundColor Green
invoke-expression ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
write-host ""
write-host ""

##Set up the network
Write-Host "Setting up the network" -ForegroundColor Green
Disable-NetAdapterBinding -Name "Ethernet0" -ComponentID ms_tcpip6
New-NetIPAddress -InterfaceIndex 12 -IPAddress $ipaddr -PrefixLength $subnet -DefaultGateway $gateway
Set-DnsClientServerAddress -InterfaceIndex 12 -ServerAddresses ("$dns", "8.8.8.8")
Write-Host "Network setup complete" -ForegroundColor Green
write-host ""


###Allow ping
Write-Host "Allow ping through the firewall" -ForegroundColor Green
Enable-NetFirewallRule -DisplayGroup "File and Printer Sharing"
Write-Host "Ping now allowed" -ForegroundColor Green
Write-Host "Ping was my best friend in school" -ForegroundColor Green
write-host ""


### Allow RDP
Write-Host "Setting up RDP access" -ForegroundColor Green
set-ItemProperty -Path 'HKLM:\System\CurrentControlSet\Control\Terminal Server'-name "fDenyTSConnections" -Value 0
Enable-NetFirewallRule -DisplayGroup "Remote Desktop"
Write-Host "RDP Access complete" -ForegroundColor Green
write-host ""

shutdown /r