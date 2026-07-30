<#
    Intune Proactive Remediation - Detection script
    Checks for the presence of the OneDrive Photos companion app executable in
    two locations:
      1. %userprofile%\AppData\Local\Microsoft\OneDrive\OneDrive.App.exe (per user profile)
      2. C:\Program Files\Microsoft OneDrive\OneDrive.App.exe (machine-wide install)
    ...and any Start Menu shortcuts (per-user + all-users) pointing to either.
    (The Windows 11 "All apps" list is populated from these same Start Menu
    folders, so no separate location needs to be checked for that.)

    Exit 0 = compliant (nothing found) - no remediation needed
    Exit 1 = non-compliant (exe and/or shortcut found) - remediation will run

    Note: Proactive Remediations run as SYSTEM by default, so $env:USERPROFILE
    would resolve to the SYSTEM profile rather than an actual user's profile.
    This script instead enumerates all user profile folders under C:\Users.
#>

$relativeExePath = "AppData\Local\Microsoft\OneDrive\OneDrive.App.exe"
$machineWideExePath = Join-Path -Path $env:ProgramFiles -ChildPath "Microsoft OneDrive\OneDrive.App.exe"
$startMenuRelativePath = "AppData\Roaming\Microsoft\Windows\Start Menu\Programs"
$commonStartMenuPath = Join-Path -Path $env:ProgramData -ChildPath "Microsoft\Windows\Start Menu\Programs"
$excludedProfiles = @("Public", "Default", "Default User", "All Users")

$foundItems = @()

$userProfiles = Get-ChildItem -Path "$env:SystemDrive\Users" -Directory -ErrorAction SilentlyContinue |
    Where-Object { $excludedProfiles -notcontains $_.Name }

# Executable check - per-user location
foreach ($user in $userProfiles) {
    $targetPath = Join-Path -Path $user.FullName -ChildPath $relativeExePath
    if (Test-Path -Path $targetPath -PathType Leaf) {
        $foundItems += $targetPath
    }
}

# Executable check - machine-wide location
if (Test-Path -Path $machineWideExePath -PathType Leaf) {
    $foundItems += $machineWideExePath
}

# Shortcut check (per-user Start Menu + all-users Start Menu)
$startMenuRoots = @($commonStartMenuPath)
foreach ($user in $userProfiles) {
    $startMenuRoots += Join-Path -Path $user.FullName -ChildPath $startMenuRelativePath
}

$shell = New-Object -ComObject WScript.Shell

foreach ($root in $startMenuRoots) {
    if (-not (Test-Path -Path $root -PathType Container)) { continue }

    $shortcuts = Get-ChildItem -Path $root -Filter "*.lnk" -Recurse -ErrorAction SilentlyContinue
    foreach ($shortcut in $shortcuts) {
        try {
            $link = $shell.CreateShortcut($shortcut.FullName)
            if ($link.TargetPath -and $link.TargetPath -like "*OneDrive.App.exe") {
                $foundItems += $shortcut.FullName
            }
        }
        catch {
            # Skip shortcuts that can't be resolved
        }
    }
}

if ($foundItems.Count -gt 0) {
    Write-Output "Found: $($foundItems -join '; ')"
    exit 1
}
else {
    Write-Output "Not found."
    exit 0
}
