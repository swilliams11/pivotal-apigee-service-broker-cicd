# security-check proxy
This proxy performs the OAuth security check with proxy chaining.  

This will also create the product, developer, and developer app in Apigee.

This will deploy the proxy with the following base path.
`/customers`

Be sure to update your curl command to use the above base path.  


## Deploy proxy

Export the following shell variables.
```
export ae_password=apigeepassword
export ae_username=apigeeusername
export ae_org=apigeeorg
```


```
cd apigee/security-check
```

Deploy Apigee proxy and create the product, developer and developer app.  
```
mvn install -Ptest -Dusername=$ae_username -Dpassword=$ae_password \
                    -Dorg=$ae_org -Dapigee.config.options=create
```

or

Update the Apigee proxy and create the config.  

```
mvn install -Ptest -Dusername=$ae_username -Dpassword=$ae_password \
                    -Dorg=$ae_org -Dapigee.config.options=create \
                    -Doptions=update
```
