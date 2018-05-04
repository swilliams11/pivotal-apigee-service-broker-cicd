# Apigee Proxies
The example proxies for this are shown in the `apigee` directory.

* The proxy that is created from the `apigee-bind-org` command should be modified as shown in the `customers` proxy located in the `apigee/customers` directory.
* The `security-check` proxy should be deployed to Apigee and is located in the `apigee/security-check` directory.

### Curl commands to test

```
curl https://customers-nodeapp.apps.YOURDOMAIN.com/customers -i

curl https://customers-nodeapp.apps.YOURDOMAIN.com/customers/1 -v

curl https://customers-nodeapp.apps.YOURDOMAIN.com/customers/2 -v

curl https://customers-nodeapp.apps.YOURDOMAIN.com/customers/12 -v

```
