<#
    .SYNOPSIS
        Connects to a given list of servers and retrieve the current power plan and changes it on demand.
    .DESCRIPTION
        Connects to a given list of servers and retrieve the current power plan and changes it on demand.
    .PARAMETERS
        $serverList -> List of servers to look at
        $force -> it will not prompt and will change to high performance

    .EXAMPLE
#>

Clear-Host;
$serverList = "server1", "server2";
$force = 0;

foreach ($s in $serverList){
    Write-Host "Processing server $($s):";
    Invoke-Command -ComputerName $s -ScriptBlock{
        
        $current = (powercfg /l | Where-Object { $_.Contains(') *')});
        Write-Output $current;
        
        if ($current -notlike "*High*"){
            if ($force -eq $true){
                $response = "y";
            }
            else{
                $response = Read-Host -Prompt 'Do you want to set it to High Performance? (y/n)';
            }

            if ($response -eq "y"){
                $GUID = (powercfg /l | Where-Object { $_.Contains('High') -and $_.Contains('GUID')}).Split()[3];
                powercfg /setactive $GUID;
                Write-Host "Changed to High Performance" -ForegroundColor Green;
            }
        }
    }
}
