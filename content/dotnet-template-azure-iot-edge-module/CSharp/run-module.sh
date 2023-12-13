sasKey=$(az iot hub device-identity show -n $HUB_ID -d $EDGE_ID --query authentication.symmetricKey.primaryKey -o tsv)
init-iotedge-module --hostname=$HUB_ID.azure-devices.net --edgeId=$EDGE_ID --modId=samplemodule --sasKey=$sasKey
modConnStr=$(az iot hub module-identity connection-string show -n $HUB_ID -d $EDGE_ID -m samplemodule  -o tsv)
export IotHubConnectionString="$modConnStr;GatewayHostName=localhost"
export EdgeModuleCACertificateFile="ca.pem"
curl "https://raw.githubusercontent.com/ridomin/edgeHub-local/master/certs/ca.pem" -o "ca.pem"
dotnet run