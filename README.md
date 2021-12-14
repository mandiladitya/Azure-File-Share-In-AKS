# Azure-File-Share-In-AKS
Azure File Share in AKS
```
kubectl create secret generic azure-secret --from-literal=azurestorageaccountname=$AKS_PERS_STORAGE_ACCOUNT_NAME --from-literal=azurestorageaccountkey=$STORAGE_KEY
```
```
kubectl apply -f pv-fileshare.yaml
```
```
kubectl apply -f pvc-fileshare.yaml
```
```
kubectl apply -f test-deployment.yaml
```

##### Reference 
- [Microsoft Offical Docs](https://docs.microsoft.com/en-us/azure/aks/azure-files-volume)
