#!/bin/bash

###
# a build/deployment script for usage with ixis docker build system
###

### Drupal build process ###

echo "Drupal build process started at $(date)"

### if makefile detected proceed with drush make ###
if [ -f make.yml ];
then
  echo "Found a makefile, proceeding with drush make ..."
  drush make make.yml webapp -y
else
  echo "No makefile found, proceeding with standard build ..."
fi

### copy drupal settings.php file into place ###
cp settings.php webapp/sites/default/

### copy project .project.yml file into place ###
cp .container.yml webapp/

### archive project code ready for deploy ###
tar -czf webapp.tar.gz webapp

### deploy the archive to S3 ###
aws s3 cp webapp.tar.gz s3://$AWS_S3_BUCKET_NAME/$CI_BRANCH-$(echo $CI_REPO |cut -d'/' -f2)-$(echo $CI_REPO |cut -d'/' -f1)-latest.tar.gz --acl public-read --region $AWS_REGION

echo "Drupal build process completed at $(date)"

### Rancher deploy process ###

echo "Rancher deploy process started at $(date)"

### clone compose files ###
git clone git@$GOGS_URL:$CI_REPO-compose.git compose-files && cd compose-files

### set the correct branch in the compose files ###
sed -i -e "s/CIBRANCH/$CI_BRANCH/g" rancher-compose.yml docker-compose.yml

### set the correct organisation name in the compose files ###
sed -i -e "s/CIORG/$(echo $CI_REPO |cut -d'/' -f1)/g" rancher-compose.yml docker-compose.yml

### set the correct repository name in the compose files ###
sed -i -e "s/CIREPO/$(echo $CI_REPO |cut -d'/' -f2)/g" rancher-compose.yml docker-compose.yml

### provision the environment within Rancher (branch-repo-organisation)###
rancher-compose -p $CI_BRANCH-$(echo $CI_REPO |cut -d'/' -f2)-$(echo $CI_REPO |cut -d'/' -f1) up -u -c -d --force-upgrade

echo "Rancher deploy process completed at $(date)"
