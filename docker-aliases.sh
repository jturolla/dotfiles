#!/bin/bash

function docker-ruby {
  docker run --rm \
    -ti \
    -v $PWD:/project \
    -v ruby-bundler:/vendor/bundle \
    -e AWS_ACCESS_KEY_ID \
    -e AWS_SECRET_ACCESS_KEY \
    -e NU_DEPLOY_DEBUG \
    -e PAGER='busybox cat' \
    --entrypoint /bin/bash $NU_RUBY_IMG
}
