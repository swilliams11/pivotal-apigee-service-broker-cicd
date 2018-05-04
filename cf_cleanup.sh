#!/bin/bash

APP_NAME=$1

echo "This script will unbind the the CF App from the Apigee proxy and then delete the CF app."
echo

#Update the JENKINS_JOB name job/JENKINS_JOB_NAME

if [ "$APP_NAME" == "" ] || [ $# -lt 1  ]
  then
    echo "Please enter the cf app name."
    echo "i.e. ./cf_cleanup.sh cfappname"
    exit 1
fi

cf apigee-unbind-org --app $APP_NAME

cf delete $APP_NAME
