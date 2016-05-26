#!/bin/bash

##
# a rancher script for usage with ixis docker build system
##

### start time ###
date

### set the correct branch in the compose files ###
sed -i -e "s/CIBRANCH/$CI_BRANCH/g" rancher-compose.yml docker-compose.yml

### set the correct organisation name in the compose files ###
sed -i -e "s/CIORG/$(echo $CI_REPO |cut -d'/' -f1)/g" rancher-compose.yml docker-compose.yml

### set the correct repository name in the compose files ###
sed -i -e "s/CIREPO/$(echo $CI_REPO |cut -d'/' -f2)/g" rancher-compose.yml docker-compose.yml

### provision the environment within Rancher (branch-repo-organisation)###
rancher-compose -p $CI_BRANCH-$(echo $CI_REPO |cut -d'/' -f2)-$(echo $CI_REPO |cut -d'/' -f1) up -u -c -d --force-upgrade

### end time ###
date
