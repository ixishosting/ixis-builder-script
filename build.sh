#!/bin/bash

# a build script for usage with ixis docker build system

# start time
date

# if makefile detected proceed with drush make
if [ -f make.yml ];
then
  echo -e "Found a makefile, proceeding with drush make ..."
  drush make make.yml webapp -y
else
  echo "No makefile found, proceeding with standard build ..."
fi

# copy drupal settings.php file into place
cp settings.php webapp/sites/default/

# archive project code ready for deploy
tar -czf webapp.tar.gz webapp

# deploy the archive to S3 (variables defined from .drone.yml using drone secrets)
aws s3 cp webapp.tar.gz s3://$AWS_S3_BUCKET_NAME/$(echo $CI_REPO | sed 's/\//-/g')-$CI_BRANCH-latest.tar.gz --acl public-read --region $AWS_REGION

# end time
date
