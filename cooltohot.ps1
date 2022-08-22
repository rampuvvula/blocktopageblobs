az login -u {{username}} -p {{password}}

#create 3rd container to copy cool to hot  - Storgae temp
[System.Environment]::SetEnvironmentVariable('SRC_ACCOUNT_KEY','{{acctkey}}')
[System.Environment]::SetEnvironmentVariable('SRC_ACCOUNT_NAME','{{acctname}}')
[System.Environment]::SetEnvironmentVariable('ACCOUNT_NAME','{{srcaccountname}}')
[System.Environment]::SetEnvironmentVariable('ACCOUNT_KEY','{{srcaccountkey}}')


$blobURL = '{{blockbloburl}}'
$ContainerName = $blobURL.Split('/')[3]


.\BlobPorter.exe -f "$blobURL" -c $ContainerName -t blob-pageblob
