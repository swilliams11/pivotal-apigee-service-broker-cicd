#!/bin/bash

echo "This script will ask you to enter two passwords: 1st) Apigee Edge and 2nd) Jenkins"
echo

JENKINS_DOMAIN=$1
CF_FOLDER=$2
APIGEE_USER=$3
SSL_INSECURE=$4

# make sure the user entered the required 3 parameters
if [ $# -lt 3 ]
  then
    echo "cf_deploy_app.sh jenkinsdomain foldername apigee_username -k ignorecerterrors"
    echo "i.e. cf_deploy_app.sh jenkins-deploy.net customers user@email.com -k"
    exit 1
fi

# if the user entered the optional 4th param the confirm it is -k
if [ $# -eq 4 ]
  then
    if [ "$SSL_INSECURE" != "-k" ]
      then
        echo "You must enter -k to ignore certificate errors"
        echo "i.e. cf_deploy_app.sh jenkins-deploy.net customers user@email.com -k"
        exit 1
    fi
fi

# this will deploy the CF app to cloud Foundry
cd $CF_FOLDER
cf push

# issue the cf apigee-bind-org command here
cf apigee-bind-org --user $APIGEE_USER

cd ..
. jenkins_build.sh "$JENKINS_DOMAIN" "$APIGEE_USER" "$SSL_INSECURE"
