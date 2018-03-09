#!/usr/bin/env bash
curl https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-sdk-188.0.1-darwin-x86_64.tar.gz -o /tmp/gcloud.tar.gz

mkdir -p /usr/local/opt/gcloud
tar xvf /tmp/gcloud.tar.gz -C /usr/local/opt/
