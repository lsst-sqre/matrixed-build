ARG input=scratch

FROM $input
USER 0:0
ARG input
ARG image
ARG supplementary
ARG tag
ARG version


RUN mkdir -p /tmp/build
WORKDIR /tmp/build

COPY scripts/functions.sh /tmp/build
COPY scripts/save-arguments /tmp/build

RUN /tmp/build/save-arguments

COPY scripts/cleanup-files /tmp/build
RUN /tmp/build/cleanup-files

# Run by default as an unprivileged user.
USER 65534:65534
WORKDIR /tmp

CMD ["cat", "/etc/build-args"]

ENV  DESCRIPTION="Multi-platform test container"
ENV  SUMMARY="Multi-platform test container"

LABEL description="Multi-platform test container: $version" \
       name="multi-test:$version" \
       version="$version"
