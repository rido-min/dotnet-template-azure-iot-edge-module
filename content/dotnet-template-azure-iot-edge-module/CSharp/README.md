# IoT Edge Module Template for .NET 8

This project leverages the latest dotnet features to create docker images without using a `Dockerfile`. See more details in https://github.com/dotnet/sdk-container-builds

## Prerequisites

- az cli
- Docker
- dotnet (8)
- dotnet tool install --global init-iotedge-module

## Init IoT Edge Device

Set configuration variables

```ps1
$SUB_ID="<azure_sub>"
$HUB_ID="<hubname>"
$EDGE_ID="<edge_device>"
```

```bash
export SUB_ID=<azure_sub>
export HUB_ID=<hubname>
export EDGE_ID=<edge_device>
```


```bash
az account set -s $SUB_ID
az iot hub device-identity create -n $HUB_ID -d $EDGE_ID --edge-enabled
az iot edge set-modules -n $HUB_ID -d $EDGE_ID -k deploy.json

sasKey=$(az iot hub device-identity show -n $HUB_ID -d $EDGE_ID --query authentication.symmetricKey.primaryKey -o tsv)
init-iotedge-module --hostname=$HUB_ID.azure-devices.net --edgeId=$EDGE_ID --modId=\$edgeHub --sasKey=$sasKey
edgeHubConnStr=$(az iot hub module-identity connection-string show -n $HUB_ID -d $EDGE_ID -m \$edgeHub  -o tsv)
```

```ps1
az account set -s $SUB_ID
az iot hub device-identity create -n $HUB_ID -d $EDGE_ID --edge-enabled
az iot edge set-modules -n $HUB_ID -d $EDGE_ID -k deploy.json

$sasKey=(az iot hub device-identity show -n $HUB_ID -d $EDGE_ID --query authentication.symmetricKey.primaryKey -o tsv)
init-iotedge-module --hostname=$HUB_ID.azure-devices.net --edgeId=$EDGE_ID --modId=`$edgeHub --sasKey=$sasKey
$edgeHubConnStr=(az iot hub module-identity connection-string show -n $HUB_ID -d $EDGE_ID -m `$edgeHub  -o tsv)
```

## Run edgeHub-local

```ps1
wget -Uri "https://raw.githubusercontent.com/ridomin/edgeHub-local/master/certs/ca.pem" -OutFile "ca.pem"
docker run -it --rm -e IotHubConnectionString="$edgeHubConnStr" -p 8883:8883 ghcr.io/ridomin/edgehub:local
```

```bash
curl "https://raw.githubusercontent.com/ridomin/edgeHub-local/master/certs/ca.pem" -o "ca.pem"
docker run -it --rm -e IotHubConnectionString="$edgeHubConnStr" -p 8883:8883 ghcr.io/ridomin/edgehub:local
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
