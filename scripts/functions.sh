#!/bin/sh

tag_to_version() {
    if [ "${tag}" = "" ]; then
	echo "tag cannot be empty" >&2
	exit 1
    fi
    version=${tag}
    first=$(echo "${version}" | cut -c 1)
    if [ "${first}" = "v" ]; then
	version="r$(echo ${version} | cut -c 2-)"
    fi
    first=$(echo "${version}" | cut -c 1)
    if [ "${first}" = "r" ]; then
	build_number=${GITHUB_RUN_NUMBER}
	if [ "${build_number}" == "" ]; then
	    build_number=0
	fi
	version="${version}_rsp${build_number}"    
    fi
    echo "${version}"
}

determine_platform() {
    platform="$(arch)"
    if [ "${platform}" = "x86_64" ]; then
	platform="amd64"
    elif [ "${platform}" = "aarch64" ]; then
	platform="arm64"
    fi
    echo "${platform}"
}

calculate_tags_usage_err() {
    echo "required variables: tag, platform, image" 1>&2
    exit 1
}

calculate_tags() {
    if [ -z "${tag}" ] || [ -z "${platform}" ] || [ -z "${image}" ]; then
	calculate_tags_usage_err
    fi
    if [ "${platform}" != "amd64" ] && [ "${platform}" != "arm64" ]; then
	echo "platform must be 'amd64' or 'arm64'"
	exit 1
    fi

    branch=$(git rev-parse --abbrev-ref HEAD)
    if [ -n "${OVERRIDE_BRANCH}" ]; then
	branch="${OVERRIDE_BRANCH}"
    fi
    release_branch="main"
    if [ -z "${branch}" ]; then
	echo "cannot determine git branch" 1>&2
	branch="NOGIT"
    fi

    version=$(tag_to_version)
    if [ "${branch}" != "${release_branch}" ]; then
	if [ "${supplementary}" = "" ]; then
	    supplementary=$(echo ${branch} | tr -c -d \[A-z\]\[0-9\])
	fi
    fi
    if [ -n "${supplementary}" ]; then
	version="exp_${version}_${supplementary}"
    fi
    tag_type=$(echo ${version} | cut -c 1)

    ltype=""
    latest=""
    case ${tag_type} in
	"w")
	    ltype="latest_weekly"
	    latest="latest"
	    ;;
	"r")
	    ltype="latest_release"
	    latest="latest"
	    ;;
	"d")
	    ltype="latest_daily"
	    ;;
	*)
	    ;;
    esac

    img=$(echo ${image} | cut -d ',' -f 1)
    more=$(echo ${image} | cut -d ',' -f 2- | tr ',' ' ')
    if [ "${img}" = "${more}" ]; then
	more=""
    fi

    tagset="${img}:${version}-${platform}"
    for m in ${more}; do
	tagset="${tagset},${m}:${version}-${platform}"
    done
    if [ -n "${ltype}" ]; then
	tagset="${tagset},${img}:${ltype}-${platform}"
	for m in ${more}; do
	    tagset="${tagset},${m}:${ltype}-${platform}"
	done
    fi
    if [ -n "${latest}" ]; then
	tagset="${tagset},${img}:${latest}-${platform}"
	for m in ${more}; do
	    tagset="${tagset},${m}:${latest}-${platform}"
	done
    fi
    echo ${tagset}
}
