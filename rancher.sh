#!/bin/bash

# a rancher script for usage with ixis docker build system

# start time
date

# set the correct branch in the compose files
sed -i -e "s/CIBRANCH/$CI_BRANCH/g" rancher-compose.yml docker-compose.yml

# set the correct project name in the compose files
#sed -i -e "s/REPO/$(basename $PWD)/g" rancher-compose.yml docker-compose.yml

# set the correct organisation/repo name in the compose files with dash
sed -i -e "s/CIREPO2/$(echo $CI_REPO | sed 's/\//-/g')/g" rancher-compose.yml docker-compose.yml

# set the correct organisation/repo name in the compose files with slash (using : as delimiter as variable contains slashes)
sed -i -e "s:CIREPO:$CI_REPO:g" rancher-compose.yml docker-compose.yml

# provision the environment within Rancher
rancher-compose -p $(echo $CI_REPO | sed 's/\//-/g')-$CI_BRANCH up -u -c -d --force-upgrade

# end time
date
