<#
    Intune Proactive Remediation - Remediation script
    Deletes the OneDrive Photos companion app executable from two locations:
      1. %userprofile%\AppData\Local\Microsoft\OneDrive\OneDrive.App.exe (per user profile)
      2. C:\Program Files\Microsoft OneDrive\OneDrive.App.exe (machine-wide install)
    ...and any Start Menu shortcuts (per-user + all-users) pointing to either.
    (The Windows 11 "All apps" list is populated from these same Start Menu
    folders, so removing the shortcuts here also removes the app from there.)

    Exit 0 = remediation succeeded (everything removed / already absent)
    Exit 1 = remediation failed (something could not be removed)

    Note: Proactive Remediations run as SYSTEM by default, so $env:USERPROFILE
    would resolve to the SYSTEM profile rather than an actual user's profile.
    This script instead enumerates all user profile folders under C:\Users.
#>

$relativeExePath = "AppData\Local\Microsoft\OneDrive\OneDrive.App.exe"
$machineWideExePath = Join-Path -Path $env:ProgramFiles -ChildPath "Microsoft OneDrive\OneDrive.App.exe"
$startMenuRelativePath = "AppData\Roaming\Microsoft\Windows\Start Menu\Programs"
$commonStartMenuPath = Join-Path -Path $env:ProgramData -ChildPath "Microsoft\Windows\Start Menu\Programs"
$excludedProfiles = @("Public", "Default", "Default User", "All Users")

$hadFailure = $false

$userProfiles = Get-ChildItem -Path "$env:SystemDrive\Users" -Directory -ErrorAction SilentlyContinue |
    Where-Object { $excludedProfiles -notcontains $_.Name }

# Remove the executable - per-user location
foreach ($userProfile in $userProfiles) {
    $targetPath = Join-Path -Path $userProfile.FullName -ChildPath $relativeExePath
    if (Test-Path -Path $targetPath -PathType Leaf) {
        try {
            Remove-Item -Path $targetPath -Force -ErrorAction Stop
            Write-Output "Removed: $targetPath"
        }
        catch {
            Write-Output "Failed to remove: $targetPath - $($_.Exception.Message)"
            $hadFailure = $true
        }
    }
}

# Remove the executable - machine-wide location
if (Test-Path -Path $machineWideExePath -PathType Leaf) {
    try {
        Remove-Item -Path $machineWideExePath -Force -ErrorAction Stop
        Write-Output "Removed: $machineWideExePath"
    }
    catch {
        Write-Output "Failed to remove: $machineWideExePath - $($_.Exception.Message)"
        $hadFailure = $true
    }
}

# Remove Start Menu shortcuts (per-user + all-users) pointing to the exe
$startMenuRoots = @($commonStartMenuPath)
foreach ($userProfile in $userProfiles) {
    $startMenuRoots += Join-Path -Path $userProfile.FullName -ChildPath $startMenuRelativePath
}

$shell = New-Object -ComObject WScript.Shell

foreach ($root in $startMenuRoots) {
    if (-not (Test-Path -Path $root -PathType Container)) { continue }

    $shortcuts = Get-ChildItem -Path $root -Filter "*.lnk" -Recurse -ErrorAction SilentlyContinue
    foreach ($shortcut in $shortcuts) {
        try {
            $link = $shell.CreateShortcut($shortcut.FullName)
            if ($link.TargetPath -and $link.TargetPath -like "*OneDrive.App.exe") {
                Remove-Item -Path $shortcut.FullName -Force -ErrorAction Stop
                Write-Output "Removed shortcut: $($shortcut.FullName)"
            }
        }
        catch {
            Write-Output "Failed to remove shortcut: $($shortcut.FullName) - $($_.Exception.Message)"
            $hadFailure = $true
        }
    }
}

if ($hadFailure) {
    exit 1
}
else {
    exit 0
}
