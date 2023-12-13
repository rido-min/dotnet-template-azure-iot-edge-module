$sasKey=(az iot hub device-identity show -n $HUB_ID -d $EDGE_ID --query authentication.symmetricKey.primaryKey -o tsv)
init-iotedge-module --hostname=$HUB_ID.azure-devices.net --edgeId=$EDGE_ID --modId=samplemodule --sasKey=$sasKey
$modConnStr=(az iot hub module-identity connection-string show -n $HUB_ID -d $EDGE_ID -m samplemodule  -o tsv)
$env:IotHubConnectionString="$modConnStr;GatewayHostName=localhost"
$env:EdgeModuleCACertificateFile="ca.pem"
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/ridomin/edgeHub-local/master/certs/ca.pem" -OutFile "ca.pem"
dotnet run