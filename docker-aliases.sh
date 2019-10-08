#!/bin/bash

function docker-ruby {
  echo $*;
  docker run --rm \
    -ti \
    -v $PWD:/project \
    -v ruby-bundler:/vendor/bundle \
    -e AWS_ACCESS_KEY_ID \
    -e AWS_SECRET_ACCESS_KEY \
    -e NU_DEPLOY_DEBUG \
    -e NU_AUTH_TOKEN \
    -e NU_GOCD_JSESSIONID \
    -e PAGER='busybox cat' \
    $* \
    --entrypoint /bin/bash quay.io/nubank/nudev-ruby:cc2289b
}
