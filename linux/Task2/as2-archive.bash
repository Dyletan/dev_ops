#!/bin/bash

loop(){
    local index=1
    local zip_base="archive_"
    local found=true
    local zip="${zip_base}$index.zip"


    unzip -q $zip -d test
    cd test 

    while $found; do
        ((index++))
        zip="${zip_base}$index.zip"

        # for txt files in test folder
        for txt_file in $(find -type f -name "*.txt"); do
        # check if txt file 
            if [[ -f "$txt_file" ]]; then
                # "Checking $txt_file for codeword..."
                if ! grep -q "not empty" "$txt_file"; then
                    found=false

                    echo "Code found in $txt_file, updating file..."
                    echo "Code was $(cat "$txt_file")"

                    echo "$(cat "$txt_file")_22B030570" > "word.txt"
                    echo "not empty" > "empty.txt"

                    zip "archive_10001.zip" "empty.txt" "word.txt"
                    for ((i=10000; i>=1; i--)); do
                        zip -q "archive_$i.zip" "empty.txt" "archive_$((i+1)).zip"
                        rm -rf "archive_$((i+1)).zip"
                    done
                    rm -rf empty.txt
                    rm -rf word.txt
                    rm -rf ../archive_1.zip
                    mv archive_1.zip ..
                    cd ../
                    rmdir test
                    echo "Done"
                    exit 0
                fi
            fi
        done
        if [[ $(file --mime-type -b "$zip") == "application/zip" ]]; then
            rm -rf empty.txt
            unzip -q $zip -d .
            rm -rf "${zip_base}$((index - 1)).zip"
        else
            echo "Not found zip: $zip"
            found=false
        fi
    done
}

loop 