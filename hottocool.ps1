az login -u {{username}} -p {{password}}

[System.Environment]::SetEnvironmentVariable('SRC_ACCOUNT_KEY','{{srcaccountkey}}')
[System.Environment]::SetEnvironmentVariable('SRC_ACCOUNT_NAME','{{srcaccountname}}')
[System.Environment]::SetEnvironmentVariable('ACCOUNT_NAME','{{acctname}}')
[System.Environment]::SetEnvironmentVariable('ACCOUNT_KEY','{{acctkey}}')



$StorageAccountName = "{{srcaccountname}}" 
$StorageAccountKey = "{{srcaccountkey}}"
$Context = New-AzStorageContext -StorageAccountName $StorageAccountName -StorageAccountKey $StorageAccountKey
$ContainerName = "databasebackup-prod"
[int]$DaysOld = '310'
$UTCDate = (Get-Date).ToUniversalTime()
$RetentionDate = $UTCDate.AddDays(–$DaysOld)
$StorageContainers = Get-AzStorageContainer –Context $Context

$Blobs = @()
foreach($StorageContainer in $StorageContainers){
if($StorageContainer.Name -eq $ContainerName){
$Blobs += Get-AzStorageBlob –Context $Context –Container $StorageContainer.Name | Where-Object {$_.lastmodified.DateTime -le $RetentionDate} `
| Select-Object -Property Name
}
}
$uri="https://sta340beussqlbackup.blob.core.windows.net/databasebackup-prod"
#foreach($i in 1..100){
#  .\BlobPorter.exe -f "$uri/string[$Blobs[$i]]" -c $ContainerName -t blob-blockblob
#}

$i=1
for(;$i -le 100;$i++)
{
  #  [string]$blobURL = "$uri/$Blobs[$i]"
  [string]$blobURL = $uri + '/' + $Blobs[$i].Name
   # .\BlobPorter.exe -f $blobURL -c $ContainerName -t blob-blockblob
    .\BlobPorter.exe -f "$blobURL" -c $ContainerName -t blob-blockblob
}




