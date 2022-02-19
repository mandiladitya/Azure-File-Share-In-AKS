<#
.NOTES
Filename : SyncBetweenTwoFileShares
Author1  : Aditya Mandil
Version  : 2.0
Date     : 08-February-2022
Updated  : 08-February-2022
#>

Param (
    [Parameter(Mandatory = $true)][ValidateNotNullOrEmpty()]
    [String] $sourceAzureSubscriptionId,
    [Parameter(Mandatory = $true)][ValidateNotNullOrEmpty()]
    [String] $sourceStorageAccountRG,
    [Parameter(Mandatory = $true)][ValidateNotNullOrEmpty()]
    [String] $targetStorageAccountRG,
    [Parameter(Mandatory = $true)][ValidateNotNullOrEmpty()]
    [String] $sourceStorageAccountName,
    [Parameter(Mandatory = $true)][ValidateNotNullOrEmpty()]
    [String] $targetStorageAccountName,
    [Parameter(Mandatory = $true)][ValidateNotNullOrEmpty()]
    [String] $sourceStorageFileShareName,
    [Parameter(Mandatory = $true)][ValidateNotNullOrEmpty()]
    [String] $targetStorageFileShareName,
	[Parameter(Mandatory = $true)][ValidateNotNullOrEmpty()]
    [String] $location
)

# Azure File Share maximum snapshot support limit by the Azure platform is 200
[Int]$maxSnapshots = 200

$connectionName = "AzureRunAsConnection"

Try {
    #! Get the connection "AzureRunAsConnection "
    $servicePrincipalConnection = Get-AutomationConnection -Name $connectionName
    Write-Output "Logging in to Azure..."
    Connect-AzAccount -ServicePrincipal `
        -TenantId $servicePrincipalConnection.TenantId `
        -ApplicationId $servicePrincipalConnection.ApplicationId `
        -CertificateThumbprint $servicePrincipalConnection.CertificateThumbprint
}
Catch {
    If (!$servicePrincipalConnection) {
        $ErrorMessage = "Connection $connectionName not found..."
        throw $ErrorMessage
    }
    Else {
        Write-Error -Message $_.Exception
        throw $_.Exception
    }
}


#! Source Storage Account in the primary region
# Get Source Storage Account Key
$sourceStorageAccountKey = (Get-AzStorageAccountKey -ResourceGroupName $sourceStorageAccountRG -Name $sourceStorageAccountName).Value[0]

# Set Azure Storage Context
$sourceContext = New-AzStorageContext -StorageAccountKey $sourceStorageAccountKey -StorageAccountName $sourceStorageAccountName

# List the current snapshots on the source share
$snapshots = Get-AzStorageShare `
    -Context $sourceContext.Context | `
Where-Object { $_.Name -eq $sourceStorageFileShareName -and $_.IsSnapshot -eq $true}

If ((($snapshots.count)+20) -ge $maxSnapshots) {
    $manualSnapshots = $snapshots | where-object {$_.ShareProperties.Metadata.Keys -eq "AzureBackupProtected"}
    Remove-AzStorageShare -Share $manualSnapshots[0].CloudFileShare -Force
}


$sourceShare = Get-AzStorageShare -Context $sourceContext.Context -Name $sourceStorageFileShareName
$sourceSnapshot = $sourceShare.CloudFileShare.Snapshot()

# Generate source file share SAS URI
$sourceShareSASURI = New-AzStorageShareSASToken -Context $sourceContext `
  -ExpiryTime(get-date).AddDays(1) -FullUri -ShareName $sourceStorageFileShareName -Permission rl
# Set source file share snapshot SAS URI
$sourceSnapSASURI = $sourceSnapshot.SnapshotQualifiedUri.AbsoluteUri + "&" + $sourceShareSASURI.Split('?')[-1]

#! TARGET Storage Account in a different region
# Get Target Storage Account Key
$targetStorageAccountKey = (Get-AzStorageAccountKey -ResourceGroupName $targetStorageAccountRG -Name $targetStorageAccountName).Value[0]

# Set Target Azure Storage Context
$destinationContext = New-AzStorageContext -StorageAccountKey $targetStorageAccountKey -StorageAccountName $targetStorageAccountName

# Generate target SAS URI
$targetShareSASURI = New-AzStorageShareSASToken -Context $destinationContext `
    -ExpiryTime(get-date).AddDays(1) -FullUri -ShareName $targetStorageFileShareName -Permission rwl

# Check if target file share contains data
$targetFileShare = Get-AzStorageFile -Sharename $targetStorageFileShareName -Context $destinationContext.Context

if ($targetFileShare) {
     $command = "azcopy","sync",$sourceSnapSASURI,$targetShareSASURI,"--preserve-smb-info","--preserve-smb-permissions","--recursive"
}
Else {
     $command = "azcopy","copy",$sourceSnapSASURI,$targetShareSASURI,"--preserve-smb-info","--preserve-smb-permissions","--recursive"
}

# ------------------------------
#$location = "eastus"
$containerGroupName = "syncafsdrjob"

# Set the AZCOPY_BUFFER_GB value at 2 GB which would prevent the container from crashing.
$envVars = New-AzContainerInstanceEnvironmentVariableObject -Name "AZCOPY_BUFFER_GB" -Value "2"

# Create Azure Container Instance Object
$container = New-AzContainerInstanceObject `
-Name $containerGroupName `
-Image "peterdavehello/azcopy:latest" `
-RequestCpu 2 -RequestMemoryInGb 4 `
-Command $command -EnvironmentVariable $envVars

# Create Azure Container Group and run the AzCopy job
$containerGroup = New-AzContainerGroup -ResourceGroupName $sourceStorageAccountRG -Name $containerGroupName `
-Container $container -OsType Linux -Location $location -RestartPolicy never

# List the current snapshots on the target share
$snapshots = Get-AzStorageShare `
    -Context $destinationContext.Context | `
Where-Object { $_.Name -eq $targetStorageFileShareName -and $_.IsSnapshot -eq $true}

# Delete the oldest (1) manual snapshot in the target share if have 190 or more snapshots (Azure Files snapshot limit is 200)
If ((($snapshots.count)+10) -ge $maxSnapshots) {
    $manualSnapshots = $snapshots | where-object {$_.ShareProperties.Metadata.Keys -eq "AzureBackupProtected"}
    Remove-AzStorageShare -Share $manualSnapshots[0].CloudFileShare -Force
}

$targetShare = Get-AzStorageShare -Context $destinationContext.Context -Name $targetStorageFileShareName
$targetShareSnapshot = $targetShare.CloudFileShare.Snapshot()

Write-Output ("Completed ... !")
