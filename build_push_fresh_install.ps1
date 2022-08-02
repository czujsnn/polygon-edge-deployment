#NOT REQUIRED, BUT IT IS ADVISED TO USE KUBECTX + KUBENS
kubectx [CLUSTER-NAME]
kubens polygon-edge
#Delete PVC for genesis + nodes
kubectl delete pvc genesis-pvc -n polygon-edge

For ($i=1; $i -le 4; $i++)
{
    kubectl delete deployment polygon-edge-node-$i -n polygon-edge
}

Start-Sleep -Seconds 30
$scriptpath = $MyInvocation.MyCommand.Path
$dir = Split-Path $scriptpath

$semver = "$dir/polygon_edge_semver.txt"
$versionparts = (get-content -Path $semver).split('.')
([int]$versionparts[-1])++
$versionparts -join('.') | set-content $semver
$updated_semver = (get-content -Path $dir/polygon_edge_semver.txt)

az acr login --name [CONTAINER-REGISTRY-PLACEHOLDER]

# Build Node image, tag it with semver tag and latest, and push to your container registry.

docker build --no-cache "$dir/" --tag [CONTAINER-REGISTRY-PLACEHOLDER]/polygon-edge-node:$updated_semver

#Tag all 4 images as "latest" to properly use in kubernetes
docker tag [CONTAINER-REGISTRY-PLACEHOLDER]/polygon-edge-node:$updated_semver [CONTAINER-REGISTRY-PLACEHOLDER]/polygon-edge-node:latest

docker push [CONTAINER-REGISTRY-PLACEHOLDER]/polygon-edge-node --all-tags

# Create local info about nodes, you need some sort of local bash shell to do so.

./init_nodes.sh
Start-Sleep -Seconds 15

#initialize empty arrays for str values
$node_public_keys = New-Object System.Collections.Generic.List[System.Object]
$node_ids = New-Object System.Collections.Generic.List[System.Object]
$multiaddr_nodes =New-Object System.Collections.Generic.List[System.Object]

For ($i=1; $i -le 4; $i++)
{
    #Fetch Public-key,node_id and create multi address string for node$i, which init_nodes.sh created
    $public_key = Get-Content ./temp/node$i/data-dir/public_key_node$i.txt -Raw
    $node_id = Get-Content ./temp/node$i/data-dir/node_id_node$i.txt -Raw
    $multi_addr = $("/ip4/172.17.0.120/tcp/1478/p2p/${node_id}").Trim()

    #add above values to proper arrays
    $node_public_keys.Add($public_key)
    $node_ids.Add($node_id)
    $multiaddr_nodes.Add($multi_addr)
}

mkdir genesis
cd genesis

#POLYGON-EDGE GENESIS creation, for bootnodes we only use first 2 addresses of nodes in multiaddr format, top up WALLET1 and WALLET2 with 1000 and 500 tokens respectively:
polygon-edge genesis --chain-id 19831608 --name polygon-edge-chain --consensus ibft --premine [METAMASK_PUBLIC_KEY_WALLET1]:0x3635C9ADC5DEA00000 --premine [METAMASK_PUBLIC_KEY_WALLET2]:0x1B1AE4D6E2EF500000 --ibft-validator=$node_public_keys[0] --ibft-validator=$node_public_keys[1] --ibft-validator=$node_public_keys[2] --ibft-validator=$node_public_keys[3] --bootnode=$multiaddr_nodes[0] --bootnode=$multiaddr_nodes[1]

cd ..

kubectl apply -f .\polygon-edge.yaml -n polygon-edge
Start-Sleep -Seconds 90
$pods = New-Object System.Collections.Generic.List[System.Object]

For ($i=1; $i -le 4; $i++)
{

    $pod = $(kubectl get pod -l app=polygon-edge-node-$i -o name --no-headers=true -n polygon-edge).split('/')[1]
    $pods.Add($pod)

}

#Commands below execute to create persistency on pvc

For ($i=1; $i -le 4; $i++)
{

    kubectl cp ./genesis polygon-edge/$pods[$i]:/ -n polygon-edge
    kubectl cp ./temp/node$i/data-dir polygon-edge/$pods[$i]:/ -n polygon-edge
}

#clean up
Remove-Item -Recurse ./temp
Remove-Item -Recurse ./genesis