# WhoAteMyRAM
A Powershell module for memory usage statistics.

## Installation

- ### by [Scoop](https://github.com/ScoopInstaller/Scoop)

```Powershell
# Add scoop bucket
scoop bucket add Scoop4kariiin https://github.com/AkariiinMKII/Scoop4kariiin

# Install 
scoop install WhoAteMyRAM
```

- ### by git clone

#### Step 1. Go to `Modules` directory in Powershell path

Run following command to check path

```Powershell
$env:PSModulePath -Split ";"
```

It is recommended to use defaule `$PROFILE` directory, you need to create one if not exists

```Powershell
$UsePath = (Split-Path $PROFILE | Join-Path -ChildPath Modules); if(!(Test-Path $UsePath)) {New-Item $UsePath -Type Directory -Force | Out-Null}; Set-Location $UsePath
```

#### Step 2. Clone this repository

Git command is available with [git for windows](https://gitforwindows.org/), or just use [WSL](https://docs.microsoft.com/en-us/windows/wsl/install-win10).

```bash
git clone https://github.com/AkariiinMKII/WhoAteMyRAM
```

#### Step 3. Set as Import-Module

Ensure your Powershell profile

```Powershell
if (!(Test-Path $PROFILE)) {New-Item $PROFILE -Type File -Force | Out-Null}
```

Append Import-Module config to `$PROFILE`

```Powershell
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
