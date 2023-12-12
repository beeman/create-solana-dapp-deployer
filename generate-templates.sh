#!/bin/bash

# Define workspace and base variables
WORKSPACE_ROOT="${WORKSPACE_ROOT:-$(pwd)/workspace}"
BASE_PREFIX="solana-dapp-"
BASE_REPO="git@github.com:beeman/"
BASE_COMMAND="npx --yes create-solana-dapp@next"

# Function to get template ID
get_template_id() {
    local preset=$1
    local ui=$2
    local id="${BASE_PREFIX}${preset}"
    if [[ "$ui" != "none" ]]; then
        id="${id}-${ui}"
    fi
    echo "$id"
}

# Array of templates
declare -a presets=("next" "react")
declare -a uis=("tailwind" "none")

# Create workspace directory if it doesn't exist
if [[ ! -d "$WORKSPACE_ROOT" ]]; then
    echo "Creating workspace directory... $WORKSPACE_ROOT"
    mkdir -p "$WORKSPACE_ROOT"
fi

# Iterate over templates
for preset in "${presets[@]}"; do
    for ui in "${uis[@]}"; do
        id=$(get_template_id "$preset" "$ui")
        repo="${BASE_REPO}${id}.git"
        target_dir="${WORKSPACE_ROOT}/${id}"
        command="${BASE_COMMAND} ${id} --preset ${preset} --ui ${ui} --anchor counter --yarn"

        # Check if target directory exists
        if [[ ! -d "$target_dir" ]]; then
            echo "Generating template... $id in $WORKSPACE_ROOT, command:"
            echo "    $command"
            echo "    Target: $target_dir"
            (cd "$WORKSPACE_ROOT" && eval "$command")

            # Add, push, and remove git remote
            echo "Adding remote... $repo $target_dir"
            (cd "$target_dir" && git remote add origin "$repo")

            echo "Pushing template... $id to $repo"
            (cd "$target_dir" && git push -u origin main --force)

            if [[ $? -ne 0 ]]; then
                echo "Failed to push template... $id to $repo"
                exit 1
            fi
        else
            echo "Skipping template... $id, already exists in $WORKSPACE_ROOT"
        fi
    done
done

echo "Done!"
