$ModDirFormat = $args[0]

# Change directory to the mod directory
Set-Location -Path ".\dayz\1042420"

# Define the workshop directory
$workshopDir = ".\steamapps\workshop\content\221100"

# Check if the workshop directory exists
if (Test-Path $workshopDir) {
    if ($ModDirFormat -eq "false") {
        # Remove symlinks corresponding to the mod directories
        Get-ChildItem -Path $workshopDir -Directory | ForEach-Object {
            $modDir = $_.FullName
            # Capture mod name from meta.cpp file
            $modName = (Select-String -Path "$modDir\meta.cpp" -Pattern '^\s*name\s*=\s*"(.*)"' -AllMatches).Matches.Groups[1].Value
            if ($modName) {
                $symlinkName = "@$modName"
                if (Test-Path $symlinkName) {
                    Remove-Item -Path $symlinkName -Force -Recurse
                }
            }
        }
        # Create traditional symlinks for numbered directories
        Get-ChildItem -Path $workshopDir -Directory | ForEach-Object {
            Write-Host "Creating junction link: $($_.Name) -> $($_.FullName)"
            if (Test-Path $_.Name) {
                Remove-Item -Path $_.Name -Force -Recurse
            }
            New-Item -ItemType Junction -Name $_.Name -Target $_.FullName -Force | Out-Null
        }
    }
    else {
        # Remove numbered symlinks corresponding to the mod directories
        Get-ChildItem -Path $workshopDir -Directory | ForEach-Object {
            if (Test-Path $_.Name) {
                Remove-Item -Path $_.Name -Force -Recurse
            }
        }
        # Create @name symlinks for directories based on meta.cpp
        Get-ChildItem -Path $workshopDir -Directory | ForEach-Object {
            $modDir = $_.FullName
            # Capture mod name from meta.cpp file
            $modName = (Select-String -Path "$modDir\meta.cpp" -Pattern '^\s*name\s*=\s*"(.*)"' -AllMatches).Matches.Groups[1].Value
            if ($modName) {
                $symlinkName = "@$modName"
                if (Test-Path $symlinkName) {
                    Remove-Item -Path $symlinkName -Force -Recurse
                }
                New-Item -ItemType Junction -Name $symlinkName -Target $modDir -Force | Out-Null
            }
        }
    }
}
