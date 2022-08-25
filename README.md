# WhoAteMyRAM
A command-line tool for memory usage statistics.

## Installation

- ### Via [Scoop](https://github.com/ScoopInstaller/Scoop)

```Powershell
# Add scoop bucket
scoop bucket add Scoop4kariiin https://github.com/AkariiinMKII/Scoop4kariiin

# Install 
scoop install WhoAteMyRAM
```

- ### Via git clone

Notice that you need to install [git for windows](https://gitforwindows.org/) in advance.

```PowerShell
# Go to modules folder
$UsePath = (Split-Path $PROFILE | Join-Path -ChildPath Modules); if(!(Test-Path $UsePath)) {New-Item $UsePath -Type Directory -Force | Out-Null}; Set-Location $UsePath

# Clone this repository
git clone https://github.com/AkariiinMKII/WhoAteMyRAM

# Modify PS profile to enable auto-import
if (!(Test-Path $PROFILE)) {New-Item $PROFILE -Type File -Force | Out-Null}
Add-Content -Path $PROFILE -Value "Import-Module WhoAteMyRAM"
```

## Functions

### `ListMemoryUsage`

_Print or export memory usage statistics._

#### Parameters:

|Parameter|Description|Mandatory|Acceptable Value|
|----|----|:----:|----|
|`-Name`|A filter for processes to show, file extension can be omitted|x|Any string|
|`-Unit`|Specify the unit of memory size|x|`KB`, `MB`, `GB`, `TB`|
|`-Accuracy`|Specify decimal places to show|x|Integers from `0` to `15`|
|`-Sort`|Sort processes by memory usage|x|`+`, `-`, `Ascending`, `Descending`|
|`-Export`|Export results to a csv file, file extension can be omitted|x|Any string|

#### Example:
```Powershell
ListMemoryUsage -Name chrome -Unit GB -Accuracy 2 -Sort + -Export abc
```

### `WhoAteMyRAM` 

_Find out who is the RAM eater, just run it!_

#### Example:

```Powershell
WhoAteMyRAM

It's chrome, who ate 19.19 GB of RAM!
```
