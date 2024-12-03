#!/bin/bash

if [ "$#" -ne 1 ]; then
    echo "Usage: $0 new_job_name"
    exit 1
fi

new_job_name="$1"

sed -i.bak "s/job \"[^\"]*\"/job \"$new_job_name\"/" example.nomad

echo "Job name hase been changed"
