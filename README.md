# Kubernetes kubenv

kubenv is a tool to set multiple port-forwards for a given kubernetes configuration


Usage:

```
./kubenv.sh  <PATH_TO_K8S_CONFIG> <POD_PREFIX>:<LOCAL_PORT> <POD_PREFIX>:<LOCAL_PORT> ...  <POD_PREFIX>:<LOCAL_PORT>
```

For each POD_PREFIX:LOCAL_PORT, takes the first pod matching the prefix and make a port-forward of its exposed port to the given port

For each pod config, it can be used 2 optional parameters to override the exposed port (for ratpack services where there are exposed 8080 and 5050, 
but by default the script gets the first one, and you need to set to 5050) and the kubeconfig file (in cases like solr where it is located in infrastructure kubeconfig).

```
./kubenv.sh ... <POD_PREFIX>:<LOCAL_PORT>:<EXPOSED_PORT>:<PATH_TO_K8S_CONFIG>
```

Example

```
./kubenv.sh  /home/victor.porcar/Descargas/k8s-izzi-int-sdp-conf sdp-service-search-service-nlu:10611  sdp-hollow-metadata-publisher:10401  sdp-streamlocators:10066 sdp-managetv:8081
```


In this example the tool "knows" the exposed port of the  pod  sdp-service-search-service-nlu is 10610 in the cluster, so it port forwards to the given port 10611, which means that this pod can be reached using localhost:10611


## preconfigured environments

There are some preconfigured environments, see env folder, just execute the sh file on the environment folder

## shortcut on the Desktop

It is is possible to create an icon (shortcut) in the Desktop, so it allow to execute all the portforwards for a given environment in one click

Please follow the following steps to create the shortcut
 

-  copy file *.dekstop in the environment folder to your desktop
-  edit the file and set properly paths using your actual home route
-  on permission tab, check allow to execute as a program. In Ubuntu 20.0 it may be required to set allow to launch in the icon menu
-  click on the icon and click trust the execution
-  a popup terminal will appear
