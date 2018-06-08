#!/usr/bin/env bash

source scripts/helpers.sh

export RUNDECK_BUILD_NUMBER="${TRAVIS_BUILD_NUMBER}"

S3_ARTIFACT_PATH="s3://rundeck-travis-artifacts/oss/${TRAVIS_BRANCH}/${RUNDECK_BUILD_NUMBER}/artifacts"

mkdir -p artifacts/packaging

export_tag_info() {
    local TAG_PARTS
    if [[ ${TAG_PARTS=$(tag_parts "${TRAVIS_TAG}")} && $? != 0 ]] ; then
        echo "Invalid tag [${TRAVIS_TAG}]"
    else
        TAG_PARTS=( $TAG_PARTS )
    fi

    echo "${TAG_PARTS[@]}"

    PREV_TAG_PARTS=( $(tag_parts `git describe --abbrev=0`) )

    export RUNDECK_RELEASE_VERSION="${TAG_PARTS[0]}"
    export RUNDECK_RELEASE_TAG="${TAG_PARTS[1]:-SNAPSHOT}"

    export RUNDECK_PREV_RELEASE_VERSION="${PREV_TAG_PARTS[0]}"
    export RUNDECK_PREV_RELEASE_TAG="${PREV_TAG_PARTS[1]:-SNAPSHOT}"
}

# Wraps bash command in code folding and timing "stamps"
script_block() {
    NAME="${1}"

    # Remove block name from arg array
    shift

    travis_fold start "${NAME}"
        travis_time_start
            eval "${@}"
            ret=$?
        travis_time_finish
    travis_fold end "${NAME}"
    return $RET
}

sync_from_s3() {
    aws s3 sync --delete "${S3_ARTIFACT_PATH}" artifacts
}

sync_to_s3() {
    aws s3 sync --delete ./artifacts $S3_ARTIFACT_PATH
}

# Helper function that syncs artifacts from s3
# and copies the most common into place.
fetch_common_artifacts() {
    sync_from_s3
    # Drop to subshell and change dir; courtesy roundup
    (
        cd artifacts
        cp -r --parents * ../
    )
}

tag_info

export -f script_block
export -f sync_to_s3
export -f sync_from_s3
export -f fetch_common_artifacts