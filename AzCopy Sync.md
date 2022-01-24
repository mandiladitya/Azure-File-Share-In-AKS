#### 1: Create Storage Account & Fileshare
#### 2: Create SAAS token = Storage Account > Single Access Token
- Upload Spacewalk Folder
```
azcopy copy './Spacewalk' 'https://primaryaditya.file.core.windows.net/primary?sv=2020-08-04&ss=f&srt=sco&sp=rwdlc&se=2022-01-25T14:48:28Z&st=2022-01-24T06:48:28Z&spr=https&sig=cFThhAPEsYfRERx2carF91Dnw0yUbWXfwXnSS0IaS1w%3D'
```
- Download All from fileshare
```
azcopy copy 'https://primaryaditya.file.core.windows.net/primary/*?sv=2020-08-04&ss=f&srt=sco&sp=rwdlc&se=2022-01-25T14:48:28Z&st=2022-01-24T06:48:28Z&spr=https&sig=cFThhAPEsYfRERx2carF91Dnw0yUbWXfwXnSS0IaS1w%3D' '.' --recursive
```
- Sync b/w fileshare Complete Data
```
azcopy sync 'https://primaryaditya.file.core.windows.net/primary/?sv=2020-08-04&ss=f&srt=sco&sp=rwdlc&se=2022-01-25T14:48:28Z&st=2022-01-24T06:48:28Z&spr=https&sig=cFThhAPEsYfRERx2carF91Dnw0yUbWXfwXnSS0IaS1w%3D' 'https://draditya.file.core.windows.net/drfileshare/?sv=2020-08-04&ss=f&srt=sco&sp=rwdlc&se=2022-01-24T16:00:34Z&st=2022-01-24T08:00:34Z&spr=https&sig=8y3N9MVSQ6kMrcZjQv2%2FO5J3ZjgNhgdz%2Fv6Rvz5BzKE%3D'
```
- Sync folder b/w fileshare
```
azcopy sync 'https://primaryaditya.file.core.windows.net/primary/folder?sv=2020-08-04&ss=f&srt=sco&sp=rwdlc&se=2022-01-25T14:48:28Z&st=2022-01-24T06:48:28Z&spr=https&sig=cFThhAPEsYfRERx2carF91Dnw0yUbWXfwXnSS0IaS1w%3D' 'https://draditya.file.core.windows.net/drfileshare/folder?sv=2020-08-04&ss=f&srt=sco&sp=rwdlc&se=2022-01-24T16:00:34Z&st=2022-01-24T08:00:34Z&spr=https&sig=8y3N9MVSQ6kMrcZjQv2%2FO5J3ZjgNhgdz%2Fv6Rvz5BzKE%3D'
```
#### References :
- https://docs.microsoft.com/en-us/azure/storage/common/storage-use-azcopy-files
