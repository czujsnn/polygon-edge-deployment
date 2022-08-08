#!/bin/bash
mkdir temp
for i in {1..4}
do
    polygon-edge secrets init --data-dir temp/node$i/data-dir > output$i.txt
    cat output$i.txt | grep Public | awk '{ printf "%s", $5}' > temp/node$i/data-dir/public_key_node$i.txt
    cat output$i.txt | grep Node | awk '{ printf "%s", $4}' > temp/node$i/data-dir/node_id_node$i.txt
    rm output$i.txt
done


