#!/bin/bash

# a rancher script for usage with ixis docker build system

# start time
date

# set the correct branch in the compose files
sed -i -e "s/CIBRANCH/$CI_BRANCH/g" rancher-compose.yml docker-compose.yml

# set the correct project name in the compose files
sed -i -e "s/REPO/$(basename $PWD)/g" rancher-compose.yml docker-compose.yml

# set the correct AWS region in the compose files
sed -i -e "s/AWSREGION/$AWS_REGION/g" rancher-compose.yml docker-compose.yml

# set the correct S3 URL in the compose files
sed -i -e "s/S3URL/$S3_URL/g" rancher-compose.yml docker-compose.yml

# provision the environment within Rancher
rancher-compose -p $(basename $PWD)-$CI_BRANCH up -u -c -d --force-upgrade

# end time
date
