#!/bin/bash

###
# a build script for usage with ixis docker build system
###

### start time ###
echo "Build process started at $(date)"

### if makefile detected proceed with drush make ###
if [ -f make.yml ];
then
  echo -e "Found a makefile, proceeding with drush make ..."
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

### end time ###
echo "Build process completed at $(date)"
