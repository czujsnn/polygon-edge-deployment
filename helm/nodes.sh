#!/bin/bash
ID=$(cat /etc/podinfo/labels |awk -F"=" '{split($2,a," ");gsub(/"/, "", a[1]);print a[1]}' | head -n 1)
if compgen -G "/public-node/*${ID}.txt" > /dev/null; then
   echo "Already exists."
else
    polygon-edge secrets init --data-dir /data-dir > ./output.txt
    cat output.txt | grep Public | awk '{ printf "%s", $5}' > /public-node/public_key_node-$ID.txt
    cat output.txt | grep Node | awk '{ printf "%s", $4}' > /public-node/node_id_node-$ID.txt

    rm ./output.txt 
fi




# sleep 45

# cd ./genesis

# polygon-edge genesis --chain-id 19831608 --name moschain --consensus ibft --premine 0x710E74EcBa975e1103A6862bd5Eb24364d9c36D9:0x3635C9ADC5DEA00000 --premine 0x2Af099E8ac70e249FAd823fB7478753526fef5ff:0x1B1AE4D6E2EF500000 --ibft-validator=${node1_public_key} --ibft-validator=${node2_public_key} --ibft-validator=${node3_public_key} --ibft-validator=${node4_public_key} --bootnode=$multiaddr_node1 --bootnode=$multiaddr_node2

