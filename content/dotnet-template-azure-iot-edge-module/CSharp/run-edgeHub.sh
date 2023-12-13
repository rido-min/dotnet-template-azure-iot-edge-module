az account set -s $SUB_ID
az iot hub device-identity create -n $HUB_ID -d $EDGE_ID --edge-enabled
az iot edge set-modules -n $HUB_ID -d $EDGE_ID -k deploy.json

sasKey=$(az iot hub device-identity show -n $HUB_ID -d $EDGE_ID --query authentication.symmetricKey.primaryKey -o tsv)
init-iotedge-module --hostname=$HUB_ID.azure-devices.net --edgeId=$EDGE_ID --modId=\$edgeHub --sasKey=$sasKey
edgeHubConnStr=$(az iot hub module-identity connection-string show -n $HUB_ID -d $EDGE_ID -m \$edgeHub  -o tsv)

docker run -it --rm -e IotHubConnectionString="$edgeHubConnStr" -p 8883:8883 ghcr.io/ridomin/edgehub:local