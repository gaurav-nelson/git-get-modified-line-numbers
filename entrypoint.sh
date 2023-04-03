#!/bin/bash

git config --global --add safe.directory '*'

INPUT=""
if [[ $(git rev-list --count HEAD) -eq 1 ]]; then
    COMMIT=$(git rev-parse HEAD)
    INPUT=$(git show ${COMMIT} | \
grep -v -e '^[+-]' -e '^index' | \
sed 's/diff --git a.* b\//\//g; s/.*+\(.*\)@@.*/\1/g; s/^ -//g; s/,+[0-9]*//g; s/\(^[0-9]*\) +/\1-/g;')
else
    INPUT=$(git diff --unified=0 --diff-filter=M HEAD~1 HEAD | \
grep -v -e '^[+-]' -e '^index' | \
sed 's/diff --git a.* b\//\//g; s/.*+\(.*\)@@.*/\1/g; s/^ -//g; s/,+[0-9]*//g; s/\(^[0-9]*\) +/\1-/g;' | grep -v '\\')
fi

OUTPUT=""

while read CURRENT_LINE; do
    if [[ $PREVIOUS_LINE == "" ]] &&  [[ $CURRENT_LINE == /* ]]; then
        OUTPUT="${OUTPUT}${CURRENT_LINE}\n"
        PREVIOUS_LINE="filename"
    else
        if [[ $PREVIOUS_LINE == "filename" || "number" ]] &&  [[ $CURRENT_LINE =~ ^[[:digit:]] ]]; then
            START_DIGIT=""
            END_DIGIT=""
            if [[ $CURRENT_LINE =~ "," ]]; then
                START_DIGIT="${CURRENT_LINE%,*}"
                TEMP_DIGIT="${CURRENT_LINE#*,}"
                END_DIGIT=$(( START_DIGIT + TEMP_DIGIT - 1 ))
                LINE_NUMBERS=$(seq -s ' ' ${START_DIGIT} ${END_DIGIT})
                #echo "${LINE_NUMBERS}"
                OUTPUT="${OUTPUT}${LINE_NUMBERS}"
            else
                #echo "${CURRENT_LINE}"
                OUTPUT="${OUTPUT} ${CURRENT_LINE}"
            fi
            PREVIOUS_LINE="number"
        else
            if [[ $PREVIOUS_LINE == "number" ]] &&  [[ $CURRENT_LINE == /* ]]; then
                #echo "END"
                OUTPUT="${OUTPUT}\nEND\n"
                #echo "${CURRENT_LINE}"
                OUTPUT="${OUTPUT}${CURRENT_LINE}\n"
            fi
        fi
    fi
done <<< "$INPUT"

OUTPUT="${OUTPUT}\nEND"

function convert_to_json() {
    local input=$1
    input="${input//\\n/$'\n'}"
    local json="{"
    local filename=""
    while read -r line; do
        if [[ $line == "END" ]]; then
            json=${json%,}
            json+="],"
        elif [[ $line =~ ^/ ]]; then
            filename=$line
            json+="\"$filename\":["
        else
            line="${line// /,}"
            json+="$line,"
        fi
    done <<< "$input"
    json=${json%,}
    json+="}"
    echo "$json"
}

JSON_OUTPUT=$(convert_to_json "$OUTPUT")
echo $JSON_OUTPUT
