# WhoAteMyRAM
A Powershell module for memory usage statistics.

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

#### `-Unit <Unit>`

_Unit of memory size._

- Not mandatory
- Accept `KB`, `MB` and `GB`


#### `-Name <ProcessName>`

_Filter for process name._

- Not mandatory
- Do not input executable file extension

#### `-Export <FileName>`

_Export to a csv file._

- Not mandatory
- Only support csv in current version
- File extension can be omitted

Example:
```Powershell
ListMemoryUsage -Unit GB -Name chrome -Export aaa
```

### `WhoAteMyRAM` 

_Find out who is the RAM eater, just run it!_

Example:
```Powershell
WhoAteMyRAM

It's chrome, who ate 19.19 GB of RAM!
```
