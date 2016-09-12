#!/bin/bash

SCRIPT_ROOT=$( cd "$(dirname "$0")"; PWD -P )
# @todo: only hub and live are fixed repo names, dev can have different names
#        when used in any project. Make sure scripts are compatible for this.
#        However, here dev will be always recognized by the name: dev
repos=( "dev" "hub" "live" )
FUNC_DIR="$SCRIPT_ROOT/.gwp"
REPO_FUNC_DIR="gwp"
source "$SCRIPT_ROOT/config"

for repo in "${repos[@]}"
do
    # generate repo git config file
    generate_config "$repo"

    # copy repo gwp.conf file
    if [[ ! -d "$SCRIPT_ROOT/$repo/$REPO_FUNC_DIR" ]]; then
        $( cd "$SCRIPT_ROOT/$repo" && mkdir "$REPO_FUNC_DIR" )
        if [[ $? -ne 0 ]]; then
            echo "Error: couldn't create directory: [$REPO_FUNC_DIR] in path: [$SCRIPT_ROOT/$repo/]" 1>&2
            exit 0
        fi
    fi
    cp -af "$SCRIPT_ROOT/gwp.conf" "$SCRIPT_ROOT/$repo/$REPO_FUNC_DIR/gwp.conf"
    if [[ $? -ne 0 ]]; then
        echo "Error: couldn't copy gwp.conf file in path: [$SCRIPT_ROOT/$repo/$REPO_FUNC_DIR/gwp.conf]" 1>&2
        exit 0
    fi
done

find "${FUNC_DIR}"/* -print0 2>/dev/null | while IFS= read -r -d '' func
do
    if [[ -f "$func" ]]; then
        file_name=$( basename "$func" )

        for repo in "${repos[@]}"
        do
            cpy=""
            case "$repo" in
                "dev" )
                    cpy="true"; ;;
                "hub" )
                    cpy="true"; ;;
                "live" )
                    cpy="true"; ;;
            esac
            if [[ ! -z "$cpy" ]]; then
                cp -af "$func" "$SCRIPT_ROOT/$repo/$REPO_FUNC_DIR/$file_name"
            fi
        done
    fi
done