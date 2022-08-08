#kubectx and kubens aren't necessary but they enforce creating deployments in proper namespace / cluster. This part can be commented out
kubectx [CLUSTER_NAME]
kubens polygon-edge

$scriptpath = $MyInvocation.MyCommand.Path
$dir = Split-Path $scriptpath

$semver = "$dir/polygon_edge_semver.txt"
$versionparts = (get-content -Path $semver).split('.')
([int]$versionparts[-1])++
$versionparts -join('.') | set-content $semver
$updated_semver = (get-content -Path $dir/polygon_edge_semver.txt)

az acr login --name [CONTAINER-REGISTRY-ADDRESS]

# Build all 4 node images

docker build --no-cache "$dir/" --tag [CONTAINER-REGISTRY-ADDRESS]/polygon-edge-node:$updated_semver

#Tag all 4 images as "latest" to properly use in kubernetes
docker tag [CONTAINER-REGISTRY-ADDRESS]/polygon-edge-node:$updated_semver [CONTAINER-REGISTRY-ADDRESS]/polygon-edge-node:latest

docker push [CONTAINER-REGISTRY-ADDRESS]/polygon-edge-node --all-tags

# Create local info about nodes, you need some sort of local bash shell to do so.

./init_nodes.sh
Start-Sleep -Seconds 15


$node1_public_key = Get-Content ./temp/node1/data-dir/public_key_node1.txt -Raw
$node2_public_key = Get-Content ./temp/node2/data-dir/public_key_node2.txt -Raw
$node3_public_key = Get-Content ./temp/node3/data-dir/public_key_node3.txt -Raw
$node4_public_key = Get-Content ./temp/node4/data-dir/public_key_node4.txt -Raw

$node1_node_id = Get-Content ./temp/node1/data-dir/node_id_node1.txt -Raw
$node2_node_id = Get-Content ./temp/node2/data-dir/node_id_node2.txt -Raw
$node3_node_id = Get-Content ./temp/node3/data-dir/node_id_node3.txt -Raw
$node4_node_id = Get-Content ./temp/node4/data-dir/node_id_node4.txt -Raw

#Generate Multiaddress strings for each node
$multiaddr_node1 = $("/ip4/172.17.0.120/tcp/1478/p2p/${node1_node_id}").Trim()
$multiaddr_node2 = $("/ip4/172.17.0.121/tcp/1478/p2p/${node2_node_id}").Trim()
$multiaddr_node3 = $("/ip4/172.17.0.122/tcp/1478/p2p/${node3_node_id}").Trim()
$multiaddr_node4 = $("/ip4/172.17.0.123/tcp/1478/p2p/${node4_node_id}").Trim()

echo $multiaddr_node1
echo $multiaddr_node2
echo $multiaddr_node3
echo $multiaddr_node4

echo $node1_public_key
echo $node2_public_key
echo $node3_public_key
echo $node4_public_key

mkdir genesis
cd genesis

# Create genesis file, and top up 2 wallets with 1000 and 500 
polygon-edge genesis --chain-id 19831608 --name polygon-edge-chain --consensus ibft --premine [METAMASK_ADDRESS_1]:0x3635C9ADC5DEA00000 --premine [METAMASK_ADDRESS_2]:0x1B1AE4D6E2EF500000 --ibft-validator=${node1_public_key} --ibft-validator=${node2_public_key} --ibft-validator=${node3_public_key} --ibft-validator=${node4_public_key} --bootnode=$multiaddr_node1 --bootnode=$multiaddr_node2


cd ..

kubectl apply -f .\polygon-edge.yaml -n polygon-edge
Start-Sleep -Seconds 90
$pod1 = $(kubectl get pod -l app=polygon-edge-node-1 -o name --no-headers=true -n polygon-edge).split('/')[1]
$pod2 = $(kubectl get pod -l app=polygon-edge-node-2 -o name --no-headers=true -n polygon-edge).split('/')[1]
$pod3 = $(kubectl get pod -l app=polygon-edge-node-3 -o name --no-headers=true -n polygon-edge).split('/')[1]
$pod4 = $(kubectl get pod -l app=polygon-edge-node-4 -o name --no-headers=true -n polygon-edge).split('/')[1]


#BELOW COMMANDS EXECUTE ONLY FIRST TIME TO CREATE PERSISTENCY, IF YOU WANT TO CREATE 
kubectl cp ./genesis polygon-edge/${pod1}:/ -n polygon-edge
kubectl cp ./genesis polygon-edge/${pod2}:/ -n polygon-edge
kubectl cp ./genesis polygon-edge/${pod3}:/ -n polygon-edge
kubectl cp ./genesis polygon-edge/${pod4}:/ -n polygon-edge


kubectl cp ./temp/node1/data-dir polygon-edge/${pod1}:/ -n polygon-edge
kubectl cp ./temp/node2/data-dir polygon-edge/${pod2}:/ -n polygon-edge
kubectl cp ./temp/node3/data-dir polygon-edge/${pod3}:/ -n polygon-edge
kubectl cp ./temp/node4/data-dir polygon-edge/${pod4}:/ -n polygon-edge

Remove-Item -Recurse ./temp
Remove-Item -Recurse ./genesis