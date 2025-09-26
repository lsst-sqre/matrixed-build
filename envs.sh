platform=$(arch)
if [ "${platform}" = "x86_64" ]; then
    platform="amd64"
fi
input="docker.io/library/alpine"
image="us-central1-docker.pkg.dev/rubin-shared-services-71ec/sciplat/multi-test,ghcr.io/lsst-sqre/multi-test,docker.io/lsstsqre/multi-test"
tag="w_2025_39"
supplementary="multi"
version=$( scripts/tag-to-version )

export platform input image tag supplementary version

