function ListMemoryUsage {
    <#
    .SYNOPSIS
        Print or export memory usage statistics.

    .PARAMETER Name
        A filter for process name.

    .PARAMETER Unit
        Specify the unit of memory size.

    .PARAMETER Accuracy
        Specify decimal places to show.

    .PARAMETER Export
        Export results to a csv file.
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $false, Position = 0)]
        [string] $Name,
        [Parameter(Mandatory = $false, Position = 1)]
        [string] $Unit = "mb",
        [Parameter(Mandatory = $false, Position = 2)]
        [int32] $Accuracy,
        [Parameter(Mandatory = $false, Position = 3)]
        [string] $Export
    )

    $Unit = $Unit.ToUpper()
    $SupportedUnit = @("KB", "MB", "GB", "TB")
    if ($SupportedUnit -notcontains $Unit) {
        $SupportedUnittoString = $SupportedUnit -join ", "
        Write-Host "`nError: Invalid unit, please use $SupportedUnittoString.`n" -ForegroundColor Red
        Return
    }

    if ($Accuracy) {
        if (($Accuracy -lt 0) -or ($Accuracy -gt 15)){
            Write-Host "`nError: Only support accuracy from 0 to 15.`n" -ForegroundColor Red
            Return
        }
    }
    else {
        switch ($Unit) {
            {($Unit -eq "KB") -or ($Unit -eq "MB")} {$Accuracy = 0; Break}
            {($Unit -eq "GB") -or ($Unit -eq "TB")} {$Accuracy = 2; Break}
        }
    }

    $ProcessList = Get-Process | Group-Object -Property ProcessName
    if ($Name) {
        if ($Name -match '\S+\.exe$') {
            $Name = $Name -Replace '\.exe$', ''
        }
        $ProcessList = $ProcessList | Where-Object {$_.Name -match "$Name"}
    }

    $MemoryUsage = foreach ($Process in $ProcessList) {
        $ProcUse = [math]::Round(($Process.Group | Measure-Object WorkingSet -Sum).Sum / "1$Unit",$Accuracy)
        $ProcInfo = New-Object psobject
        $ProcInfo | Add-Member -MemberType NoteProperty -Name "Process Name" -Value $Process.Name
        $ProcInfo | Add-Member -MemberType NoteProperty -Name "Count" -Value $Process.Count
        $ProcInfo | Add-Member -MemberType NoteProperty -Name "Memory Usage`($Unit`)" -Value $ProcUse
        $ProcInfo
    }
    
    if ($Export) {
        if (-not($Export -match '\S+\.csv$')) {
            $Export = $Export + ".csv"
        }
        $MemoryUsage | Export-Csv -Path "$Export" -Delimiter "," -NoTypeInformation
    } 
    else {
        $MemoryUsage
    }
}

function WhoAteMyRAM {
    <#
    .SYNOPSIS
        Find the RAM eater.
    #>

    $MaxRAMEat = 0
    $ListMemoryUsage = ListMemoryUsage -Unit GB -Accuracy 2
    $ListMemoryUsage | ForEach-Object {
        $ProcUse = $_.'Memory Usage(GB)'
        if ($ProcUse -gt $MaxRAMEat) {
            $MaxRAMEat = $ProcUse
            $RAMEater = $_.'Process Name'
        }
    }

    Write-Host "`nIt's $RAMEater, who ate $MaxRAMEat GB of RAM!`n"
}
