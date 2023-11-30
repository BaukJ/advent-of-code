#!/usr/bin/env bash

# Currently just test the libraries, so ignore any challenge folders
for lib in $(find lib -type f -name '*.rb' \! -path '*/year*')
do
    spec=${lib/lib/spec}
    if [[ -f "$spec" ]]
    then
        echo "Already created: $spec"
    else
        echo "Creating spec: $spec"
        mkdir -p "$(dirname "$spec")"
        touch $spec
    fi
done
