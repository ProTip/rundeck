#!/bin/bah

# Breaks up git version tag into its constituent parts
# Outputs "VERSION_NUM RELEASE_TAG RELEASE_TAG_NUMBER|0"

set -ex

function tag_parts() {
    local TAG=${1:-''}

    if [[ $TAG =~ ^v(([0-9]\.?)+)-?([a-z0-9]+)?-?([0-9]+)? ]] ; then
        local RUNDECK_VERSION=${BASH_REMATCH[1]}
        local RUNDECK_RELEASE_TAG=${BASH_REMATCH[3]:-GA}
        local RUNDECK_RELEASE_TAG_NUMBER=${BASH_REMATCH[4]:-0}
        echo -n "${RUNDECK_VERSION} ${RUNDECK_RELEASE_TAG} ${RUNDECK_RELEASE_TAG_NUMBER}"
        return 0
    elif [[ -z $TAG ]] ; then
        return 0
    else
        echo "${TAG} is not a valid version tag!"
        return 1
    fi
}

if [[ "${0}" != "${BASH_SOURCE}" ]] ; then
    true
else
    case $1 in
        'tag_parts')
            shift
            tag_parts "${@}"
            ;;
        *)
            echo 'Unkown command'
            ;;
    esac
fi