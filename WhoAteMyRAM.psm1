function ListMemoryUsage {
    <#
    .SYNOPSIS
        Print or export memory usage statistics.

    .PARAMETER Name
        A filter for processes to show.

    .PARAMETER Unit
        Specify the unit of memory size.

    .PARAMETER Accuracy
        Specify decimal places to show.

    .PARAMETER Sort
        Sort processes by memory usage.

    .PARAMETER NoSum
        Sum info won't be generated with this parameter.

    .PARAMETER Export
        Export results to a csv file.
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $false, Position = 0)]
        [string] $Name,
        [Parameter(Mandatory = $false, Position = 1)]
        [string] $Unit = "MB",
        [Parameter(Mandatory = $false, Position = 2)]
        [int32] $Accuracy,
        [Parameter(Mandatory = $false, Position = 3)]
        [string] $Sort,
        [Parameter(Mandatory = $false, Position = 4)]
        [switch] $NoSum,
        [Parameter(Mandatory = $false, Position = 5)]
        [string] $Export
    )

    $Unit = $Unit.ToUpper()

    switch ($Unit) {
        "K" {$Unit = "KB"; Break}
        "M" {$Unit = "MB"; Break}
        "G" {$Unit = "GB"; Break}
        "T" {$Unit = "TB"; Break}
    }

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
        $Accuracy = switch ($Unit) {
            "KB" {0; Break}
            "MB" {0; Break}
            "GB" {2; Break}
            "TB" {2; Break}
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
    
    if ($Sort) {
        $SupportedSort = @("+", "-", "Ascending", "Descending")
        if ($SupportedSort -notcontains $Sort) {
            $SupportedSorttoString = $SupportedSort -join ", "
            Write-Host "`nError: Invalid sort, please use $SupportedSorttoString.`n" -ForegroundColor Red
            Return
        }
        $MemoryUsage = switch ($Sort) {
            {@("+", "Ascending") -contains $_} {
                $MemoryUsage | Sort-Object -Property "Memory Usage(*)"
            }
            {@("-", "Descending") -contains $_} {
                $MemoryUsage | Sort-Object -Property "Memory Usage(*)" -Descending
            }
        }
    }

    if (-not($NoSum)) {
        $DivideLine = New-Object PsObject -Property @{
            "Process Name" = "------------";
            "Count" = "-----";
            "Memory Usage`($Unit`)" = "----------------"
        }

        $CountSum = ($MemoryUsage | Measure-Object Count -Sum).Sum
        $MemoryUsageSum = ($MemoryUsage | Measure-Object "Memory Usage*" -Sum).Sum

        $SumInfo = New-Object PsObject -Property @{
            "Process Name" = "Sum";
            "Count" = $CountSum;
            "Memory Usage`($Unit`)" = $MemoryUsageSum
        }

        $MemoryUsage += $DivideLine
        $MemoryUsage += $SumInfo
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

    $RAMEaterInfo = (ListMemoryUsage -Unit GB -Sort Descending -NoSum)[0]
    $RAMEater = $RAMEaterInfo.'Process Name'
    $RAMAte = $RAMEaterInfo.'Memory Usage(GB)'

    Write-Host "`nIt's $RAMEater, who ate $RAMAte GB of RAM!`n"
}
