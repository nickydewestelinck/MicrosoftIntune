<#
    Intune Proactive Remediation - Remediation script
    Deletes, for every local user profile:
    %userprofile%\AppData\Local\Microsoft\OneDrive\OneDrive.App.exe

    Exit 0 = remediation succeeded (file removed / already absent everywhere)
    Exit 1 = remediation failed (file could not be removed from at least one profile)

    Note: Proactive Remediations run as SYSTEM by default, so $env:USERPROFILE
    would resolve to the SYSTEM profile rather than an actual user's profile.
    This script instead enumerates all user profile folders under C:\Users.
#>

$relativePath = "AppData\Local\Microsoft\OneDrive\OneDrive.App.exe"
$excludedProfiles = @("Public", "Default", "Default User", "All Users")

$hadFailure = $false

$userProfiles = Get-ChildItem -Path "$env:SystemDrive\Users" -Directory -ErrorAction SilentlyContinue |
    Where-Object { $excludedProfiles -notcontains $_.Name }

foreach ($profile in $userProfiles) {
    $targetPath = Join-Path -Path $profile.FullName -ChildPath $relativePath
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

if ($hadFailure) {
    exit 1
}
else {
    exit 0
}
