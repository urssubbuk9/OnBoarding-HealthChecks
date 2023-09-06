<#
    .SYNOPSIS
        Connects to a given list of servers and retrieve AD group membership of the accounts that run SQL Server services
    .DESCRIPTION
        Connects to a given list of servers and retrieve AD group membership of the accounts that run SQL Server services
    .NOTES
        Tags: SQL Server Accounts
              Website: https://www.SQLDoubleG.com
        Copyright: (c) 2019 by SQLDoubleG, licensed under MIT
        License: MIT https://opensource.org/licenses/MIT
#>
#install the powershell module
import-module ActiveDirectory

$servers = @("server1" `
            , "server2" `
            , "server3" );

$AccGroups = @();

foreach ($server in $servers){
    Write-host "Processing Server $server" -ForegroundColor Green

    $SQLServices = Get-WmiObject win32_service -computer $server | 
    Where-Object {$_.name -match "^*SQL*"} | select SystemName, Name, StartName, PathName 

    foreach ($service in $SQLServices){
    $Acc = $service.StartName
    Write-host "Processing Account $Acc" -ForegroundColor Green

        if($Acc -like "NT*"){
            continue;
        }

        $p = $Acc.LastIndexOf("`\");
    
        if ($p -gt -1){ 
        # Only for domain accounts
            $Acc = $Acc.Substring($p + 1, $Acc.Length - $p -1 );
            #Write-Output $Acc;
            $GroupName = Get-ADPrincipalGroupMembership "$Acc" -ErrorAction Ignore  | Select-Object Name;
        
            $AccGroup = New-Object -TypeName psobject;
            $AccGroup | Add-Member -MemberType NoteProperty -Name ServerName -Value "$server";
            $AccGroup | Add-Member -MemberType NoteProperty -Name ServiceName -Value "$($service.Name)";
            $AccGroup | Add-Member -MemberType NoteProperty -Name AccountName -Value "$Acc";
            $AccGroup | Add-Member -MemberType NoteProperty -Name ADGroupName -Value "$GroupName";
            $AccGroups += $AccGroup;
        }   
    }
}

$AccGroups| Select-Object *;
            
            
            
