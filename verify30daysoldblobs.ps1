

# Gets all the 30 days old blobs from Main account and put them in $Blobs


$StorageAccountName = "{{srcaccountname}}" 
$StorageAccountKey = "{{srcaccountkey}}"
$Context = New-AzStorageContext -StorageAccountName $StorageAccountName -StorageAccountKey $StorageAccountKey
$ContainerName = "database-backup-test"
[int]$DaysOld = '0'
$UTCDate = (Get-Date).ToUniversalTime()
$RetentionDate = $UTCDate.AddDays(–$DaysOld)
$StorageContainers = Get-AzStorageContainer –Context $Context

$Blobs = @()
foreach($StorageContainer in $StorageContainers){
if($StorageContainer.Name -eq $ContainerName){
$Blobs += Get-AzStorageBlob –Context $Context –Container $StorageContainer.Name | Where-Object {$_.lastmodified.DateTime -le $RetentionDate} `
| Select-Object -Property Name,Length
}
}

#Write-Output $Blobs

# Gets all the bolbs in cool storage account and put them in $CoolBlobs

$CoolStorageAccountName = "{{acctname}}" 
$CoolStorageAccountKey = "{{acctkey}}"
$CoolContext = New-AzStorageContext -StorageAccountName $CoolStorageAccountName -StorageAccountKey $CoolStorageAccountKey
$CoolContainerName = "database-backup-test"
$CoolStorageContainers = Get-AzStorageContainer –Context $CoolContext

$CoolBlobs = @()
foreach($CoolStorageContainer in $CoolStorageContainers){
if($CoolStorageContainer.Name -eq $CoolContainerName){
$CoolBlobs += Get-AzStorageBlob –Context $CoolContext –Container $CoolStorageContainer.Name | Select-Object -Property Name,Length
}
}

#Write-Output $CoolBlobs

#Compare-Object -IncludeEqual -ExcludeDifferent $Blobs $Blobs1


$MaxLen=[Math]::Max($Blobs.Length, $CoolBlobs.Length)

$AllBlobs=@()

for ($i = 0; $i -lt $MaxLen; $i++)
{ 
    $AllBlobs+=$Blobs[$i]
    $AllBlobs+=$CoolBlobs[$i]
}

#Write-Output $Blobs 

#Compares $Blobs and $CoolBlobs 
az login -u {{username}} -p {{password}}
[System.Environment]::SetEnvironmentVariable('SRC_ACCOUNT_KEY','{{srcaccountkey}}')
[System.Environment]::SetEnvironmentVariable('SRC_ACCOUNT_NAME','{{srcaccountname}}')
[System.Environment]::SetEnvironmentVariable('ACCOUNT_NAME','{{acctname}}')
[System.Environment]::SetEnvironmentVariable('ACCOUNT_KEY','{{acctkey}}')

#Try -NotMatch operator tomorrow for testing
foreach ($Blobs in $AllBlobs){
#Converts the Bolb which isn't found in cool storage
if($CoolBlobs -NotContains $Blobs){
Write-Output " $Blobs is not in Cool Storage , needs to convert to cool ......... converting now"
$uri="https://sta340beussqlbackupcool.blob.core.windows.net/database-backup-test"
[string]$blobURL = $uri + '/' + $Blobs.Name
.\BlobPorter.exe -f "$blobURL" -c $ContainerName -t blob-blockblob
}
}

foreach ($Blobs in $AllBlobs){
#Converts the Bolb which isn't found in cool storage
if($CoolBlobs -contains $Blobs){
if($StorageContainer.Name -eq $ContainerName){
Write-Output " Deleting ... $Blobs"
Get-AzStorageBlob –Context $Context –Container $StorageContainer.Name | Where-Object {$_.lastmodified.DateTime -le $RetentionDate} `
| Remove-AzStorageBlob
}
}
}


