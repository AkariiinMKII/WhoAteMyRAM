function ListMemoryUsage {
    <#
    .SYNOPSIS
        Print or export memory usage statistics.

    .PARAMETER Name
        A filter for processes to show.

    .PARAMETER Exactly
        Match process name exactly.

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

    .PARAMETER Help
        Print help info.
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $false, Position = 0)]
        [string] $Name,
        [Parameter(Mandatory = $false, Position = 1)]
        [switch] $Exactly,
        [Parameter(Mandatory = $false, Position = 2)]
        [string] $Unit = "MB",
        [Parameter(Mandatory = $false, Position = 3)]
        [int32] $Accuracy,
        [Parameter(Mandatory = $false, Position = 4)]
        [string] $Sort,
        [Parameter(Mandatory = $false, Position = 5)]
        [switch] $NoSum,
        [Parameter(Mandatory = $false, Position = 6)]
        [string] $Export,
        [Parameter(Mandatory = $false, Position = 7)]
        [switch] $Help
    )

    if ($Help) {
        $groupHelpInfo = @(
            @{ Parameter = "ListMemoryUsage               "; Description = "Print memory usage statistics." }
            @{ Parameter = "    -Name <String>"; Description = "A filter for processes to show, file extension can be omitted." }
            @{ Parameter = "    -Exactly"; Description = "Use this parameter to match process name exactly." }
            @{ Parameter = "    -Unit <String>"; Description = "Specify the unit of memory size, support KB, MB, GB, TB." }
            @{ Parameter = "    -Accuracy <Int32>"; Description = "Specify decimal places to show, support integers from 0 to 15." }
            @{ Parameter = "    -Sort <String>"; Description = "Sort processes by memory usage, support +, -, Ascending, Descending." }
            @{ Parameter = "    -NoSum"; Description = "Sum info won't be generated with this parameter." }
            @{ Parameter = "    -Export <String>"; Description = "Export results to csv file, file extension can be omitted." }
            @{ Parameter = "    -Help"; Description = "Print help info." }
            @{ Parameter = ""; Description = "" }
            @{ Parameter = "WhoAteMyRAM                   "; Description = "Find out who is the RAM eater, just run it!" }
            @{ Parameter = "    -Help"; Description = "Print help info." }
            @{ Parameter = "    -Version"; Description = "Print version info." }
        )

        $HelpInfo = ForEach ($lineHelpInfo in $groupHelpInfo) {
            New-Object PSObject | Add-Member -NotePropertyMembers $lineHelpInfo -PassThru
        }

        Return $HelpInfo | Format-Table -HideTableHeaders
    }

    $Unit = $Unit.ToUpper()

    switch ($Unit) {
        "K" { $Unit = "KB"; Break }
        "M" { $Unit = "MB"; Break }
        "G" { $Unit = "GB"; Break }
        "T" { $Unit = "TB"; Break }
    }

    $SupportedUnit = @("KB", "MB", "GB", "TB")
    if ($SupportedUnit -notcontains $Unit) {
        $SupportedUnittoString = $SupportedUnit -join(", ")
        Write-Host "Error: Invalid unit, please use $SupportedUnittoString.`nRun 'ListMemoryUsage -Help' for more help info." -ForegroundColor Red
        Return
    }

    if ($PSBoundParameters.ContainsKey('Accuracy')) {
        if (($Accuracy -lt 0) -or ($Accuracy -gt 15)){
            Write-Host "Error: Only support accuracy from 0 to 15.`nRun 'ListMemoryUsage -Help' for more help info." -ForegroundColor Red
            Return
        }
    } else {
        $Accuracy = switch ($Unit) {
            "KB" { 0; Break }
            "MB" { 0; Break }
            "GB" { 2; Break }
            "TB" { 2; Break }
        }
    }

    $ProcessList = Get-Process | Group-Object -Property ProcessName
    if ($Name) {
        $Name = $Name -replace("\.exe$", "")

        if ($Exactly) {
            $ProcessList = $ProcessList | Where-Object { "$Name" -eq $_.Name }
        } else {
            $ProcessList = $ProcessList | Where-Object { $_.Name -match "$Name" }
        }
    }

    $MemoryUsage = @()

    $MemoryUsage += foreach ($Process in $ProcessList) {
        $ProcUse = [math]::Round(($Process.Group | Measure-Object WorkingSet -Sum).Sum / "1$Unit",$Accuracy)
        $ProcInfo = New-Object PSObject
        $ProcInfo | Add-Member -MemberType NoteProperty -Name "Process Name" -Value $Process.Name
        $ProcInfo | Add-Member -MemberType NoteProperty -Name "Count" -Value $Process.Count
        $ProcInfo | Add-Member -MemberType NoteProperty -Name "Memory Usage`($Unit`)" -Value $ProcUse
        $ProcInfo
    }

    if ($MemoryUsage.Count -eq 0) {
        if ($Exactly) {
            Write-Host "Error: Cannot find process exactly matches `"$Name`"." -ForegroundColor Red
        } else {
            Write-Host "Error: Cannot find process matches `"$Name`"." -ForegroundColor Red
        }
        Write-Host "Run 'ListMemoryUsage -Help' for more help info." -ForegroundColor Red
        Return
    }

    if ($Sort) {
        $SupportedSort = @("+", "-", "Ascending", "Descending")
        if ($SupportedSort -notcontains $Sort) {
            $SupportedSorttoString = $SupportedSort -join(", ")
            Write-Host "Error: Invalid sorting method, please use $SupportedSorttoString.`nRun 'ListMemoryUsage -Help' for more help info." -ForegroundColor Red
            Return
        }
        $MemoryUsage = switch ($Sort) {
            { @("+", "Ascending") -contains $_ } {
                $MemoryUsage | Sort-Object -Property "Memory Usage(*)"
            }
            { @("-", "Descending") -contains $_ } {
                $MemoryUsage | Sort-Object -Property "Memory Usage(*)" -Descending
            }
        }
    }

    if (-not($NoSum)) {
        $DivideLine = New-Object PSObject
        $DivideLine | Add-Member -MemberType NoteProperty -Name "Process Name" -Value "------------"
        $DivideLine | Add-Member -MemberType NoteProperty -Name "Count" -Value "-----"
        $DivideLine | Add-Member -MemberType NoteProperty -Name "Memory Usage`($Unit`)" -Value "----------------"

        $CountSum = ($MemoryUsage | Measure-Object Count -Sum).Sum
        $MemoryUsageSum = [math]::Round(($MemoryUsage | Measure-Object "Memory Usage*" -Sum).Sum,$Accuracy)

        $SumInfo = New-Object PSObject
        $SumInfo | Add-Member -MemberType NoteProperty -Name "Process Name" -Value "Sum"
        $SumInfo | Add-Member -MemberType NoteProperty -Name "Count" -Value  $CountSum
        $SumInfo | Add-Member -MemberType NoteProperty -Name "Memory Usage`($Unit`)" -Value $MemoryUsageSum

        $MemoryUsage += $DivideLine
        $MemoryUsage += $SumInfo
    }

    if ($Export) {
        $ExportFile = (($Export -replace("\.csv$", "")), "csv") -join(".")
        $MemoryUsage | Export-Csv -Path "$ExportFile" -Delimiter "," -NoTypeInformation

        if($?) {
            Write-Host "Exported to `"$ExportFile`" successfully." -ForegroundColor Green
        }
    } else {
        $MemoryUsage
    }
}

function WhoAteMyRAM {
    <#
    .SYNOPSIS
        Find the RAM eater.

    .PARAMETER Help
        Print help info.

    .PARAMETER Version
        Print version info.
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $false, Position = 0)]
        [switch] $Help,
        [Parameter(Mandatory = $false, Position = 1)]
        [switch] $Version
    )

    if ($Help) {
        $HelpInfo = ListMemoryUsage -Help
        Return $HelpInfo
    }

    if ($Version) {
        $VersionInfo = (Get-Module -Name WhoAteMyRAM | Select-Object Version).Version
        Return "WhoAteMyRAM $VersionInfo"
    }

    $RAMEaterInfo = (ListMemoryUsage -Unit GB -Sort Descending -NoSum)[0]
    $RAMEater = ($RAMEaterInfo.'Process Name', ".exe") -join("")
    $RAMAte = ($RAMEaterInfo.'Memory Usage(GB)', "GB") -join("")

    Write-Host "`nIt's " -NoNewline
    Write-Host $RAMEater -ForegroundColor Green -NoNewline
    Write-Host ", who ate " -NoNewline
    Write-Host $RAMAte -ForegroundColor Green -NoNewline
    Write-Host " of RAM!`n"
}

Set-Alias LMU ListMemoryUsage
Set-Alias WAMR WhoAteMyRAM
