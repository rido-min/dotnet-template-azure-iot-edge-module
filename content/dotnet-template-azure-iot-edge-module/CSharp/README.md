# IoT Edge Module Template for .NET 7

This project leverages the latest dotnet features to create docker images without using a `Dockerfile`. See more details in https://github.com/dotnet/sdk-container-builds

## Prerequisites

- az cli
- Docker
- dotnet (8)
- dotnet tool install --global init-iotedge-module

## Init IoT Edge Device

Set configuration variables

```
SUB_ID=
HUB_ID=
EDGE_ID=
```

```bash
az account set -s $SUB_ID
az iot hub device-identity create -n $HUB_ID -d $EDGE_ID --edge-enabled
sasKey=$(az iot hub device-identity show -n $HUB_ID -d $EDGE_ID --query authentication.symmetricKey.primaryKey -o tsv)
az iot edge set-modules -n $HUB_ID -d $EDGE_ID -k deploy.json
init-iotedge-module --hostname=$HUB_ID.azure-devices.net --edgeId=$EDGE_ID --modId=\$edgeHub --sasKey=$sasKey
edgeHubConnStr=$(az iot hub module-identity connection-string show -n $HUB_ID -d $EDGE_ID -m \$edgeHub  -o tsv)
```

```ps1
az account set -s $SUB_ID
az iot hub device-identity create -n $HUB_ID -d $EDGE_ID --edge-enabled
$sasKey=(az iot hub device-identity show -n $HUB_ID -d $EDGE_ID --query authentication.symmetricKey.primaryKey -o tsv)
az iot edge set-modules -n $HUB_ID -d $EDGE_ID -k deploy.json
init-iotedge-module --hostname=$HUB_ID.azure-devices.net --edgeId=$EDGE_ID --modId=`$edgeHub --sasKey=$sasKey
$edgeHubConnStr=(az iot hub module-identity connection-string show -n $HUB_ID -d $EDGE_ID -m `$edgeHub  -o tsv)
```

## Run edgeHub-local

```ps1
docker run -it --rm -e IotHubConnectionString="$edgeHubConnStr" -p 8883:8883 ghcr.io/ridomin/edgehub:local
wget -Uri "https://raw.githubusercontent.com/ridomin/edgeHub-local/master/certs/ca.pem" -OutFile "ca.pem"
```

```bash
docker run -it --rm -e IotHubConnectionString="$edgeHubConnStr" -p 8883:8883 ghcr.io/ridomin/edgehub:local
curl "https://raw.githubusercontent.com/ridomin/edgeHub-local/master/certs/ca.pem" -o "ca.pem"
```


## Run module locally

```ps1
init-iotedge-module --hostname=$HUB_ID.azure-devices.net --edgeId=$EDGE_ID --modId=samplemodule --sasKey=$sasKey
$modConnStr=(az iot hub module-identity connection-string show -n $HUB_ID -d $EDGE_ID -m samplemodule  -o tsv)
$env:IotHubConnectionString="$modConnStr;GatewayHostName=localhost"
$env:EdgeModuleCACertificateFile="ca.pem"
dotnet run
```

```bash
init-iotedge-module --hostname=$HUB_ID.azure-devices.net --edgeId=$EDGE_ID --modId=samplemodule --sasKey=$sasKey
modConnStr=$(az iot hub module-identity connection-string show -n $HUB_ID -d $EDGE_ID -m samplemodule  -o tsv)
export IotHubConnectionString="$modConnStr;GatewayHostName=localhost"
export EdgeModuleCACertificateFile="ca.pem"
dotnet run
```



## Deploy Container

```
dotnet publish --os linux --arch x64 -c Release /t:PublishContainer /p:ContainerRegistry=ridockers.azurecr.io /p:ContainerRepository=samplemodule
az iot edge set-modules -n $HUB_ID -d $EDGE_ID -k deploy-samplemodule.json
```





## Debug

The `Properties\launchSettings.TEMPLATE.json` shows how to add an environment variable to debug. Rename the file to remove `TEMPLATE` and update the module connection string.

## Publish to a container registry

The created image can be re-tagged to match your target container registry, or you build with the MSBuild property `ContainerRegistry` to produce the image for your registry
