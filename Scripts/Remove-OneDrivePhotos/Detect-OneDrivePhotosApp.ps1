<#
    Intune Proactive Remediation - Detection script
    Checks all local user profiles for the presence of:
    %userprofile%\AppData\Local\Microsoft\OneDrive\OneDrive.App.exe

    Exit 0 = compliant (file not found on any profile) - no remediation needed
    Exit 1 = non-compliant (file found on at least one profile) - remediation will run

    Note: Proactive Remediations run as SYSTEM by default, so $env:USERPROFILE
    would resolve to the SYSTEM profile rather than an actual user's profile.
    This script instead enumerates all user profile folders under C:\Users.
#>

$relativePath = "AppData\Local\Microsoft\OneDrive\OneDrive.App.exe"
$excludedProfiles = @("Public", "Default", "Default User", "All Users")

$foundPaths = @()

$userProfiles = Get-ChildItem -Path "$env:SystemDrive\Users" -Directory -ErrorAction SilentlyContinue |
    Where-Object { $excludedProfiles -notcontains $_.Name }

foreach ($profile in $userProfiles) {
    $targetPath = Join-Path -Path $profile.FullName -ChildPath $relativePath
    if (Test-Path -Path $targetPath -PathType Leaf) {
        $foundPaths += $targetPath
    }
}

if ($foundPaths.Count -gt 0) {
    Write-Output "Found: $($foundPaths -join '; ')"
    exit 1
}
else {
    Write-Output "Not found on any user profile."
    exit 0
}
