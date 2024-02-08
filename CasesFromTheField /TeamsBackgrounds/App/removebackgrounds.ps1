# This step will set a variable to the local folder where the custom Teams Backgrounds are stored
$BackgroundUploadFolder="$env:APPDATA\Microsoft\Teams\Backgrounds\Uploads"
# This will delete all JPG files in the Teams Uploads folder locally
Remove-Item -Path $BackgroundUploadFolder\*.jpg -Force
