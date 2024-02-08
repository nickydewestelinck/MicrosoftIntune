# This step will set a variable to the local folder where the custom Teams Backgrounds are stored
$BackgroundUploadFolder="$env:APPDATA\Microsoft\Teams\Backgrounds\Uploads"
 
# This will create the folder if not exists, this is only when the user never added a custom background manually
if(!(Test-Path -path $BackgroundUploadFolder)) 
{ 
 New-Item -ItemType directory -Path $BackgroundUploadFolder
 Write-Host "The Teams Background Upload Folder has been created successfully"
 }
else
{
Write-Host "The Teams Background Upload Folder already exists";
}
 
#This will copy all images files to the Teams Upload folder locally
Copy-Item -path '.\backgrounds' -Filter *.* -Destination $BackgroundUploadFolder -Recurse -Container:$false