# pivotal-apigee-service-broker-cicd

* [What is Pivotal Cloud Foundry (PCF)?](http://pivotal.io/)
* [What is Cloud Foundry (CF)?](https://www.cloudfoundry.org/why-cloud-foundry/)
* [What is the Apigee Service Broker?](https://docs.apigee.com/api-platform/integrations/cloud-foundry/edge-integration-pivotal-cloud-foundry)

# What is the purpose of this repository?
This repo demonstrates the workflow for the CF App Developer that uses the Apigee Edge Service Broker.  The typical workflow is shown below:
* A CF app developer creates a CF app
* push the app to CF
* execute the `cf apigee-bind-org` command to create an Apigee proxy and bind it to the CF app
* login to the Apigee Edge UI and add additional policies to the proxy
* save and deploy the proxy to Apigee Edge

However, this process works when the CF App developer is also an Apigee Org Admin.  If the app developer is not an Org Admin, then they will not be able to access the Apigee proxy that was created by the `apigee-bind-org` comamnd.  A developer that creates and deploys an Apigee proxy should be able to login to the UI and view/edit it.  

This is the reason for this repository.  Keep in mind that is the workflow for a developer within their dev environment.  Pushing code from dev to test is a different workflow, which is on my TODO list.

# Apigee Role Based Access Control and PCF
If you have implemented Apigee RBAC to restrict an Apigee API developer's access to the Edge UI, then when a developer executes the cf `apigee-bind-org` `proxy bind` command it will create and deploy the proxy, but the developer will not have access to the it from the UI.  

The reason is that the Apigee Service Broker will create the proxy, but it will not associate the developer's role to it.  So when the developer logs into Apigee Edge to access the proxy it will display an error stating that the developer does not have the rights to view/edit it.  

However, if you create and deploy the proxy inside of Apigee Edge directly the Apigee developer's role is associated to the proxy and the developer is able to access it immediately.

This repository enables the workflow stated above for companies that have configured Apigee custom roles.

# What's included in this repo?

In order to support the above workflow, you have to create a Jenkins job as described in the Jenkins section below. The Jenkins job will assign the proxy to the developers role.  

The CF app developer will execute the `cf_deploy_app.sh` script which executes `cf push`, `cf apigee-bind-org` and then calls the Jenkins job to add the proxy to the developer's role.

The `customers` folder includes a sample CF application and an `apigee` folder that includes a sample proxy.  

## Prereqs
* [cf command line](https://docs.cloudfoundry.org/cf-cli/)
* [Apigee service broker plugin](https://plugins.cloudfoundry.org/) - scroll down until you see the Apigee broker plugin
* Jenkins
* CF app developer should have access to Jenkins; required so that the script can send a curl command to start the build.
* Apigee Edge free/paid org


## Shell scripts
You only need to execute the `cf_deploy_app.sh` script the first time you create the app and the Apigee proxy.  There is no need to execute this script after the binding.  
The `cf_deploy_app.sh` will execute the following items:
1. cf push
2. cf apigee-bing-org "proxy bind" (create the proxy in Apigee and bind to CF app)
3. issue a curl command to Jenkins to associate the proxy to the developer's role


The `jenkins_build.sh` sends a curl command to Jenkins to start the build that will assign the proxy the developer role that created the proxy.

The `cf_cleanup.sh` will unbind the CF app from the Apigee proxy and then delete the CF app.  Make sure to delete the proxy from Apigee Edge.

### cf_deploy_app.sh script arguments
1. jenkinsdomain - domain name
2. foldername - folder name that contains the PCF/CF manifest.yaml
3. apigee_username - Apigee Edge username
4. -k  to ignore self-signed cert errors

```
cf_deploy_app.sh jenkins-deploy.net customers user@email.com -k"
```

* The `cf apigee-bind-org` will ask you to enter your Apigee Edge password first.
* Then the script will ask for your Jenkins password.  

### jenkins_build.sh script arguments
This script is called by the `cf_deploy_app.sh` script.  You can execute this script directly by including the following arguments.  

1. jenkinsdomain - domain name
2. apigee_username - Apigee Edge username
3. -k to ignore self-signed cert errors

```
jenkins_build.sh jenkins-deploy.net user@email.com -k"
```

### cf_cleanup.sh script arguments
This script removes unbinds the CF app from the Apigee proxy and deletes the CF app.  The command arguments are:
1. Cloud Foundry app name

```
./cf_cleanup.sh appname
```

## Jenkins Job
The Jenkins job is a freestyle project with a build trigger.

### Parameters
Make sure to select "This project is parameterized." I have the following parameters configured for this project.  
* proxy_name - name of the proxy that needs to be associated with the Apigee role. This should be fetched from the audit history instead.  
* apigee_env
* apigee_org
* apigee_domain - domain name of where management API requests should be sent
* apigee_role - role of the user which should be update.  This should be removed in a prod Jenkins setup.  The role is extracted from the Apigee Audit record.  

### Build trigger
Enable a build trigger in the Jenkins job by selecting "Trigger builds remotely" and then enter an authentication token.

### Invoke Jenkins Job via curl
The shell script is supposed to invoke the Jenkins Job via curl as shown below.  This curl command will send the authentication token with the proxy name. However, a production Jenkins job should fetch the proxy name from the audit history instead.  This will prevent users from triggering the Jenkins job with a proxy name to gain access to a proxy to which they should not have access.

You can pass additional parameters to the Jenkins build by including them as a query parameters.  

```
curl -X GET https://IP_or_DOMAIN/job/cloud-foundry-apigee-service-broker-update-proxy-role/buildWithParameters?token=update_apigee_proxy_role&proxy_name=PROXY_NAME
```

The final request is shown below.  The password is extracted from a command prompt before the request is sent to the Jenkins server.
```
curl -X GET -u "apigee_username:apigee_password" https://IP_or_DOMAIN/job/cloud-foundry-apigee-service-broker-update-proxy-role/buildWithParameters?token=update_apigee_proxy_role&apigee_user=apigee_username
```

### Bindings
You should have a username and password binding.  This username and password is the Apigee org admin username and password that will send the Apigee management API requests to assign the proxy to a role.

### Build
The build script is shown below.  Anything that starts with `$` is an environment variable that is defined as a parameter for the Jenkins job.

The build script:
* fetches the audit history for the past 4 hours
* extracts the username included in the request
* searches the audit history for the proxy that was created by the above user
* obtains the users role
* updates the role with the appropriate permissions to access the proxy

```py
#!/usr/bin/env python

import  json,sys,requests,os,time

#set the environment variables
#print(os.environ["apigee_username"]);
#proxy_name = os.environ["proxy_name"];
apigee_env = os.environ["apigee_env"]
apigee_org = os.environ["apigee_org"]
apigee_domain = os.environ["apigee_domain"]
apigee_role = os.environ["apigee_role"]
apigee_user = os.environ["apigee_user"].strip() #api developer with custom role
#apigee_user = os.environ["BUILD_USER_EMAIL"]

# find the proxy name from the uri
def getProxyName(uri):
    print "The uri is " + uri
    uri_frags = uri.split("/")
    return uri_frags[5]

# find the proxy the user created from the audit history
def findProxyUserCreated(payload, apigee_user):
    for record in payload["auditRecord"]:
        if apigee_user.find(record["user"]) >= 0 and record["operation"] == "CREATE" and record["responseCode"] == "201" and "action=import" in record["requestUri"]:
            print record["user"]
            print record
            return getProxyName(record["requestUri"])

    print "Error - no audit history found for user for today."
    sys.exit(1)


# check if the user belongs to the role
def isUserInRole(apigee_user, role):
    r = requests.get("https://" + apigee_domain + "/v1/organizations/" + apigee_org + "/userroles/" + role + "/users/" + apigee_user, auth=(os.environ["apigee_username"], os.environ["apigee_password"]))
    print "GET /o/" + apigee_org + "/userroles/" + role + "/users/" + apigee_user + " -> response is " + str(r.status_code)
    if r.status_code == 200:
        print "user is in role " + role
        return True
    else:
        print "user is NOT in role " + role
        return False


# check all the roles in the organization
def whatIsUsersRole(payload, apigee_user):
    for role in payload:
        print role
        if isUserInRole(apigee_user, role):
            return role
    return None

# check if the proxy name is not valid
# return true if invalid, false otherwise
def isProxyNameInvalid(proxy_name):
    if proxy_name == None or proxy_name == "":
        return True
    else:
        return False

# fetch the audit history of the user
# this is only available for private cloud customers
# https://api.enterprise.apigee.com/v1/audits/users/USERNAME

# calculate the start and end time.
end_time = int(time.time() * 1000)
start_time = end_time - (60 * 60 * 4 * 1000) #sec * mins * hours * milliseconds

# fetch the audit history of org.
headers = {"content-type": "application/octet-stream"}
params = {"startTime": str(start_time), "endTime": str(end_time), "expand": "true" }
#"?startTime=" +  + "&endTime=" + str(end_time) + "&expand=true"
r = requests.get("https://" + apigee_domain + "/v1/audits/organizations/" + apigee_org, auth=(os.environ["apigee_username"], os.environ["apigee_password"]), headers=headers)
print(r.status_code)
res = r.json()
print(res)

proxy_name = findProxyUserCreated(res, apigee_user)
print "The proxy name is " + proxy_name
if isProxyNameInvalid(proxy_name):
    print "Error - The proxy name is not valid."
    sys.exit(1)


# fetch all the org roles
r = requests.get("https://" + apigee_domain + "/v1/organizations/" + apigee_org + "/userroles", auth=(os.environ["apigee_username"], os.environ["apigee_password"]))
print "GET all roles for organization -> " + str(r.status_code)
res = r.json()
print(res)

# verify user is in role
role = whatIsUsersRole(res, apigee_user)
if role == None:
    print "Error - Could not find a role for the user."
    sys.exit(1)

# update the user role to include the proxy from the audit history
headers = {"content-type": "application/json"}
payload = json.dumps({
 "resourcePermission" : [
   {
    "path" : "/applications/" + proxy_name,
    "permissions" : [ "get","put","delete" ]
   },
   {
    "path" : "/environments/" + apigee_env + "/applications/" + proxy_name + "/revisions/*/deployments",
    "permissions" : [ "get","put","delete" ]
   },
   {
    "path" : "/environments/" + apigee_env + "/applications/" + proxy_name + "/revisions/*/debugsessions",
    "permissions" : [ "get","put","delete"]
   }

  ]
})

r = requests.post("https://" + apigee_domain + "/v1/organizations/" + apigee_org + "/userroles/" + role + "/resourcepermissions", data=payload, headers=headers, auth=(os.environ["apigee_username"], os.environ["apigee_password"]))
print(r.status_code)
print(r.json())
```

# Apigee Edge Curl Commands
These commands could be used in the Jenkins build pipeline.

## Get a User
This curl command is not available for free trial orgs.
```
curl -X GET -u "username:password" https://api.enterprise.apigee.com/v1/users/user@email.com
```

This does not display the users role.
```
{
  "emailId" : "sw@email.com",
  "firstName" : "admin",
  "lastName" : "admin"
}
```

## Get a role for a user
What we need is an API to get the role for a particular user.  
The API above does not return the role name.  

The process to fetch a role for a user is
1. Get all roles for the organization
```
curl -X GET -u "username:password" https://api.enterprise.apigee.com/v1/organizations/ORGNAME/userroles
```

```
Content-Type: application/json
[
  "orgadmin",
  "readonlyadmin",
  "opsadmin",
  "devadmin",
  "businessuser",
  "user",
  "Team1",
  "Team2"
]
```

2. verify user membership in the role
```
curl -X GET -u "username:password" "https://api.enterprise.apigee.com/v1/organizations/ORGNAME/userroles/ROLE/users/USERNAME"
```

If user belongs to the role.
```
200 OK
{
  "emailId": "sw@email.com",
  "firstName": "S",
  "lastName": "W"
}
```

If the user does not belong to the role.
```
404 Not Found
{
  "code": "usersandroles.UserDoesNotExistInRole",
  "message": "User sw@email.com does not exist in role Team2",
  "contexts": []
}
```


# TODOS
* Modify Jenkins build script to pull the audit history of the user only (this is only available in private orgs)
* Modify the Jenkins build to pull the apigee_user from the user that triggered the build.
  Last time I checked it showed "remote user" as opposed to the actual user.
* demonstrate the CI process for a developer moving code from their dev env to a test env.
* update the shell script to deploy an Apigee proxy from the customers directory.
