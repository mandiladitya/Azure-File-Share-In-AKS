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
#### References :
- https://docs.microsoft.com/en-us/azure/storage/common/storage-use-azcopy-files
