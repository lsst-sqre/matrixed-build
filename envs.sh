. scripts/functions.sh
platform=$(determine_platform)
input="docker.io/library/alpine"
image="us-central1-docker.pkg.dev/rubin-shared-services-71ec/sciplat/multi-test,ghcr.io/lsst-sqre/multi-test,docker.io/lsstsqre/multi-test"
tag="w_2025_39"
supplementary="multi"
version=$(tag_to_version)

export platform input image tag supplementary version

