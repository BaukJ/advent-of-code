#!/usr/bin/env bash
export YEAR=$1
export CHALLENGE=$2
if [[ ! "$CHALLENGE" ]]
then
    exit 3
fi
template_dir="scripts/template"
challenge_dir="lib/bauk/advent_of_code/year_$YEAR/challenge_$CHALLENGE"
echo "Doing $YEAR/$CHALLENGE ($challenge_dir)"
echo "Enter to continue..."
read

mkdir -p "$challenge_dir"

for f in $(ls "$template_dir")
do
    cat "$template_dir/$f" | envsubst >"$challenge_dir/${f/.envsubst}"
done
