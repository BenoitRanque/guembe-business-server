# guembe-business-server
Guembe Business Server


## Building and transfering an image in production

### 1. Build & Save the production docker image

```sh
# build image for production
docker-compose -f docker-compose.yml build
# find image id
docker images
# save image
docker save <IMAGE_ID> --output dist/<image.tag>.tar
```

### 2. Load and tag Image in production environment

```sh
sudo docker load --input path/to/<image.tag>.tar
# find image id
sudo docker images
# tag image
sudo docker tag <IMAGE_ID> <image:tag>
```

### useful note:

This powershell script will read multiple files and output them as one. Usefull for hasura migrations

```
Get-ChildItem ./input/folder -include *.yaml -rec | ForEach-Object {gc $_; ""} | out-file ./output/file.txt
```