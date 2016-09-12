#!/bin/bash

## @todo: fix, update script doesn't work!!!!!

# @usage:
# 1. Install:
#    $ git init --template=[GWP_Template_REPO_Dir]
#    or
#    $ git clone [REPO] --template=[GWP_Template_REPO_Dir]
# 2. Update
#    $ git gwpu [OPTIONS]
#    OPTIONS are same as options for cp command


# ---- Global variables
PROG_NAME=$(basename $0)
UPDATE_BASE_PATH=$( cd "$(dirname "$0")"; PWD -P )
TEMPLATE_PATH=$(git config --get init.templateDir)
TEMPLATE_NAME=$(git config gwp.name)
REPO_FUNC_DIR="gwp"
FUNC_DIR=".${REPO_FUNC_DIR}"
UPDATE_OPTIONS="$@"


# ---- Template dir / name check
if [[ ! -f "${TEMPLATE_PATH}/../update.sh" ]]; then
    TEMPLATE_PATH="${UPDATE_BASE_PATH}/${TEMPLATE_NAME}"
    if [[ ! -f "${TEMPLATE_PATH}/../update.sh" ]]; then
        echo " " 1>&2
        echo "Failed to recognize template directory. Please set init.templateDir as follows:" 1>&2
        echo " " 1>&2
        echo "$ git config init.templateDir ABSOLUTE_GIT_TEMPLATE_DIRECTORY" 1>&2
        echo " " 1>&2
        echo " " 1>&2
        echo "Then run the update script from git root directory using the command:" 1>&2
        echo "$ git updateGitWP" 1>&2
        echo " " 1>&2
        echo " " 1>&2
        echo "OR, set gwp.name and run this script again:" 1>&2
        echo " " 1>&2
        echo "$ git config gwp.name Git_WP_TEMPLATE_NAME" 1>&2
        echo " " 1>&2
        echo " " 1>&2
        echo "Aborting ${PROG_NAME} program." 1>&2
        echo " " 1>&2
        exit 1
    fi
fi


# ---- @todo Update the template repo with -u option: $ git gwpu -u
# $( cd "$UPDATE_BASE_PATH" && git pull 2>/dev/null )


# ---- Run the build script
$( cd "$UPDATE_BASE_PATH" && ./build.sh )


# ---- include necessary functions
. "${UPDATE_BASE_PATH}/$FUNC_DIR/error_exit" &&
. "${UPDATE_BASE_PATH}/$FUNC_DIR/warn" &&
. "${UPDATE_BASE_PATH}/$FUNC_DIR/response" &&
. "${UPDATE_BASE_PATH}/.update/update_files"
if [[ $? -ne 0 ]]; then
    echo " " 1>&2
    echo "Failed to include necessary files! Aborting ${PROG_NAME} program." 1>&2
    echo " " 1>&2
    exit 1
fi


# ---- main function
main()
{

    # @todo check if it works even if git directory is customized outside of root dir
    # or renamed to something other than .git
    local git_dir=$( git rev-parse --git-dir )
    git_dir=$( realpath "$git_dir" )

    
    if [ ! -d "$git_dir" ]
    then
        error_exit "$LINENO: Run this script from the root of a git repository you want to update."
    fi

    echo " "
    echo "Updating git Template files ..."
    echo "------------------------------------------"
    echo "Source: [${TEMPLATE_PATH}]"
    echo "Destination: [${git_dir}]"
    echo "Options: [${UPDATE_OPTIONS}]"
    echo "------------------------------------------"
    echo " "
    cnt=$( response "Continue?" )
    if [[ "false" == "$cnt" ]]; then
        echo " "
        echo "You choose not to continue!"
        echo "Nothing is done this time. Program ${PROG_NAME} aborted."
        exit 0
    fi

    echo " "

    # create hooks dir
    if [[ ! -d "$git_dir/hooks" ]]; then
        $( cd "$git_dir" && mkdir "hooks" )
        if [[ $? -ne 0 ]]; then
            error_exit "$LINENO: Failed to create hooks directory in [$git_dir]."
        fi
    fi
    # copy hook files from src_dir to dest_dir and make them executable
    update_files "$TEMPLATE_PATH/hooks" "$git_dir/hooks"

    # create gwp dir
    if [[ ! -d "$git_dir/$REPO_FUNC_DIR" ]]; then
        $( cd "$git_dir" && mkdir "$REPO_FUNC_DIR" )
        if [[ $? -ne 0 ]]; then
            error_exit "$LINENO: Failed to create $REPO_FUNC_DIR directory in [$git_dir]."
        fi
    fi
    # copy gwp script files from src_dir to dest_dir and make them executable
    update_files "$TEMPLATE_PATH/$REPO_FUNC_DIR" "$git_dir/$REPO_FUNC_DIR"    
}


main
exit 0