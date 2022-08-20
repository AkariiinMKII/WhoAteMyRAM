function ListMemoryUsage {
    <#
    .SYNOPSIS
        List memory used by process.

    .PARAMETER Unit
        Unit of memory size.

    .PARAMETER Name
        Filter for process name.

    .PARAMETER Export
        Export to a csv file.
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $false, Position = 0)]
        [string] $Unit = "mb",
        [Parameter(Mandatory = $false, Position = 1)]
        [string] $Name,
        [Parameter(Mandatory = $false, Position = 2)]
        [string] $Export
    )

    $Unit = $Unit.ToUpper()
    if (($Unit -eq "KB") -or ($Unit -eq "MB")) {
        $DPlace = 0
    } elseif ($Unit -eq "GB") {
        $DPlace = 2
    } else {
        Write-Host "Error: Invalid unit, please use KB, MB or GB." -ForegroundColor Red
        Return
    }

    $ProcessGroup = Get-Process | Group-Object -Property ProcessName
    if ($Name) {
        if ($Name -match '\S+\.exe$') {
            $Name = $Name -Replace '\.exe$', ''
        }
        $ProcessGroup = $ProcessGroup | Where-Object {$_.Name -match "$Name"}
    }

    $MemoryUsage = foreach ($Process in $ProcessGroup) {
        $PUse = [math]::Round(($Process.Group | Measure-Object WorkingSet -Sum).Sum / "1$Unit",$DPlace)
        $PInfo = New-Object psobject
        $PInfo | Add-Member -MemberType NoteProperty -Name "Process Name" -Value $Process.Name
        $PInfo | Add-Member -MemberType NoteProperty -Name "Count" -Value $Process.Count
        $PInfo | Add-Member -MemberType NoteProperty -Name "Memory Usage`($Unit`)" -Value $PUse
        $PInfo
    }
    
    if ($Export) {
        if (-not($Export -match '\S+\.csv$')) {
            $Export = $Export + ".csv"
        }
        $MemoryUsage | Export-Csv -Path "$Export" -Delimiter "," -NoTypeInformation
    } else {
        $MemoryUsage
    }
}

function WhoAteMyRAM {
    <#
    .SYNOPSIS
        Find the RAM eater.
    #>

    $ProcessGroup = Get-Process | Group-Object -Property ProcessName
    $MaxRAMEat = 0
    foreach ($Process in $ProcessGroup) {
        $PUse = [math]::Round(($Process.Group | Measure-Object WorkingSet -Sum).Sum / "1GB",2)
        if ($PUse -gt $MaxRAMEat) {
            $MaxRAMEat = $PUse
            $Eater = $Process.Name
        }
    }
    Write-Host "`nIt's $Eater, who ate $MaxRAMEat GB of RAM!`n"
}

Export-ModuleMember -Function ListMemoryUsage, WhoAteMyRAM
