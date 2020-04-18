#!/bin/bash

# make brew work on
1. create all users
2. create administrators group
3. add all users to administrator group
4. run:

sudo chgrp -R brew $(brew --prefix)/*
sudo chmod -R g+w $(brew --prefix)/*
