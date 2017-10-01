#!/bin/bash

function docker-ruby {
  docker run --rm \
    -ti \
    -v $PWD:/project \
    -v ruby-bundler:/vendor/bundle \
    -e AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID \
    -e AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY \
    --entrypoint /bin/bash $NU_RUBY_IMG
}
