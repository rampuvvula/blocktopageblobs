#use case to verify blobs existing

$StorageAccountName = "{{srcaccountname}}" 
$StorageAccountKey = "{{srcaccountkey}}"
$Context = New-AzStorageContext -StorageAccountName $StorageAccountName -StorageAccountKey $StorageAccountKey
$ContainerName = "databasebackup-prod"
[int]$DaysOld = '30'
$UTCDate = (Get-Date).ToUniversalTime()
$RetentionDate = $UTCDate.AddDays(–$DaysOld)
$StorageContainers = Get-AzStorageContainer –Context $Context


foreach($StorageContainer in $StorageContainers){
if($StorageContainer.Name -eq $ContainerName){
Get-AzStorageBlob –Context $Context –Container $StorageContainer.Name | Where-Object {$_.lastmodified.DateTime -le $RetentionDate} `
| Remove-AzStorageBlob
}
}






