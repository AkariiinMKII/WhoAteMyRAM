# WhoAteMyRAM
A PowerShell module for memory usage statistics.

## Installation

### Step 1. Go to `Modules` directory in PowerShell path

Run following command to check path

```powershell
$env:PSModulePath -Split ";"
```

It is recommended to use defaule `$PROFILE` directory, you need to create one if not exists

```powershell
$UsePath = (Split-Path $PROFILE | Join-Path -ChildPath Modules); if(!(Test-Path $UsePath)) {New-Item $UsePath -Type Directory -Force | Out-Null}; Set-Location $UsePath
```

### Step 2. Clone this repository

Git command is available with [git for windows](https://gitforwindows.org/), or just use [WSL](https://docs.microsoft.com/en-us/windows/wsl/install-win10).

```bash
git clone https://github.com/AkariiinMKII/WhoAteMyRAM
```

### Step 3. Set as Import-Module

Ensure your PowerShell profile

```powershell
if (!(Test-Path $PROFILE)) {New-Item $PROFILE -Type File -Force | Out-Null}
```

Append Import-Module config to `$PROFILE`

```powershell
Add-Content -Path $PROFILE -Value "Import-Module WhoAteMyRAM"
```
