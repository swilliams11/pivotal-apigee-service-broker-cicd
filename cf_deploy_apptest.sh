# assumes that the CF developer has logged into CF
# assumes there is a yaml file included in the current directory
# assumes you already installed the apigee-bind-org plugin

if [ $# -lt 3 ]
  then
    echo "cf_deploy_app.sh jenkinsdomain foldername apigee_username -k"
    echo "i.e. cf_deploy_app.sh jenkins-deploy.net customers user@email.com -k"
fi

if [ $# -eq 4 ]
  then
    if [ $4 != "-k" ]
      then
        echo "You must enter -k to ignore certificate errors"
        echo "i.e. cf_deploy_app.sh jenkins-deploy.net customers user@email.com -k"
    fi
fi

# send the request to Jenkins to assign the proxy to username
echo -n Password:
read -s password

if [ $4 = "-k" ]
  then
    curl -X GET -u "$3:$password" "https://$1/job/cloud-foundry-apigee-service-broker-update-proxy-role2/buildWithParameters?token=update_apigee_proxy_role&apigee_user=$3" -k -i
  else
    curl -X GET -u "$3:$password" "https://$1/job/cloud-foundry-apigee-service-broker-update-proxy-role2/buildWithParameters?token=update_apigee_proxy_role&apigee_user=$3" -i
fi
