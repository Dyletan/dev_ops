#!/bin/bash

path="/home/linux/Task1/duplicate_files"

# Hash pictures and store them in hash.txt
find $path -exec md5sum $path > hash.txt {} \;

# Sort hash.txt and rewrite it
sort hash.txt -o hash.txt
file="${PWD}/hash.txt"

# Initialize arrays to store hashes and paths separately
hashes=()
paths=()

# Read from hash.txt hashes and path and store them in arrays
while read -r hash pathToPic
do
    hashes+=("$hash")
    paths+=("$pathToPic")
done < "$file"

# Compare hashes and remove pictures if they are identical
for (( i=0; i<${#hashes[@]}-1; i++)); do
    if [[ ${hashes[i]} == ${hashes[i+1]} ]];
    then
        rm ${paths[i+1]}
    fi
done
