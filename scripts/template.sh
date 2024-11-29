#!/usr/bin/env bash
export YEAR=$1
export CHALLENGE=$2
if [[ ! "$CHALLENGE" ]]
then
    echo "USAGE: $0 YEAR CHALLENGE"
    exit 3
fi
template_dir="scripts/template"
challenge_dir="lib/bauk/advent_of_code/year_$YEAR/challenge_$CHALLENGE"
echo "Doing $YEAR/$CHALLENGE ($challenge_dir)"
if [[ -d "$challenge_dir" ]]
then
    echo "WARNING: Already exists: $challenge_dir"
    read -p "Enter 'y' to continue: " ans
    if [[ "$ans" != "y" ]]
    then
        exit 3
    fi
fi

mkdir -p "$challenge_dir"

for f in $(ls "$template_dir")
do
    cat "$template_dir/$f" | envsubst >"$challenge_dir/${f/.envsubst}"
done
echo "DONE"
