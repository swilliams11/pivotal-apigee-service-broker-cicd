#!/bin/bash

JENKINS_DOMAIN=$1
APIGEE_USER=$2
SSL_INSECURE=$3

if [ $# -lt 2 ]
  then
    echo "jenkins_build.sh jenkinsdomain apigee_username -k"
    echo "i.e. jenkins_build.sh jenkins-deploy.net user@email.com -k"
    exit 1
fi

if [ $# -eq  3 ]
  then
    if [ "$SSL_INSECURE" != "-k" ] && [ "$SSL_INSECURE" != "" ]
      then
        echo "You must enter -k to ignore certificate errors"
        echo "i.e. jenkins_build.sh jenkins-deploy.net user@email.com -k"
        exit 1
    fi
fi

# send the request to Jenkins to assign the proxy to username
echo "Enter your Jenkins password:"
read -s password


#Update the JENKINS_JOB name job/JENKINS_JOB_NAME
if [ "$SSL_INSECURE" = "-k" ]
  then
    curl -X GET -u "$APIGEE_USER:$password" "https://$JENKINS_DOMAIN/job/cloud-foundry-apigee-service-broker-update-proxy-role2/buildWithParameters?token=update_apigee_proxy_role&apigee_user=$APIGEE_USER" -k -i
  else
    curl -X GET -u "$APIGEE_USER:$password" "https://$JENKINS_DOMAIN/job/cloud-foundry-apigee-service-broker-update-proxy-role2/buildWithParameters?token=update_apigee_proxy_role&apigee_user=$APIGEE_USER" -i
fi
