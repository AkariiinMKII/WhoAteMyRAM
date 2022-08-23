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

Parameters:

#### `-Name <ProcessName>`

_A filter for process name._

- Not mandatory
- Executable file extension can be omitted

#### `-Unit <Unit>`

_Specify the unit of memory size._

- Not mandatory
- Accept `KB`, `MB`, `GB` and `TB`

#### `-Accuracy <Number>`

_Specify decimal places to show._

- Not mandatory
- Accept integers from `0` to `15`


#### `-Export <FileName>`

_Export results to a csv file._

- Not mandatory
- Only support csv in current version
- File extension can be omitted

Example:
```Powershell
ListMemoryUsage -Name chrome -Unit GB -Accuracy 2 -Export abc
```

### `WhoAteMyRAM` 

_Find out who is the RAM eater, just run it!_

Example:
```Powershell
WhoAteMyRAM

It's chrome, who ate 19.19 GB of RAM!
```
