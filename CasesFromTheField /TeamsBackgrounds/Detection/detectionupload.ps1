# This script will be used to detect if the upload was succesfull
if (Test-Path "$env:APPDATA\Microsoft\Teams\Backgrounds\Uploads\*.jpg") {
    Write-Host "The Teams Background Files are detected"
}