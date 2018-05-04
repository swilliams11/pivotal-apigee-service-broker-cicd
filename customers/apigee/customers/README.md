# Customers proxy

This proxy should not be deployed from here.  The apigee-bind-org command will create this proxy in Apigee Edge.  **However, you do need to modify the JavaScript files as shown in this proxy.**

This proxy uses proxy chaining to call the security-check proxy.  

**Be sure to update the proxy basepath to the path of your domain.**
```
<BasePath>/customers-nodeapp.apps.YOURDOMAIN.com</BasePath>
```
