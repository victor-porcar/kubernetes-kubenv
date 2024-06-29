#!/bin/bash

# Read environment aliases
# Allows for a file to contain a set of aliases for each path
# Example line: izzi-int=env/izzi-int/izzi-int-sdp-conf
declare -A kubeconfmap
if [ -f config.properties ]; then
 readarray -t lines < "config.properties"
 for line in "${lines[@]}"; do
    key=${line%%=*}
    value=${line#*=}
    kubeconfmap[$key]=$value
 done
fi

kill_child_processes() {
    isTopmost=$1
    curPid=$2
    childPids=`ps -o pid --no-headers --ppid ${curPid}`
    for childPid in $childPids
    do
        kill_child_processes 0 $childPid
    done
    if [ $isTopmost -eq 0 ]; then
        kill -9 $curPid 2> /dev/null
    fi
}

# Ctrl-C trap. Catches INT signal
trap "kill_child_processes 1 $$; exit 0" INT

path_to_kubeconfig=$1

# If the kubeconfig name is an alias, get the value from the map
if [[ ! -z "${kubeconfmap[$1]}" ]]; then
  path_to_kubeconfig="${kubeconfmap[$1]}"
fi

echo $path_to_kubeconfig
export KUBECONFIG=$path_to_kubeconfig


usedNamespace=$(kubectl config view | grep namespace:)

echo ""
echo   "USING $usedNamespace"

echo ""
echo "====================  BEGIN PORTFORWARDS ============================"


# Iterate the string variable using for loop
for val in "${@:2}"; do
  while IFS=: read podPrefix desiredPort port kconfig; do

  # Override KUBECONFIG with 4th parameter (kconfig) if it set. (useful for using infra-config for solr)
  if [[ ! -z $kconfig ]]; then
   path_to_kubeconfig=$kconfig
   # If set in kubeconfmap, interpret as alias and use the value from map as the path
   if [[ ! -z "${kubeconfmap[$kconfig]}" ]]; then
     path_to_kubeconfig="${kubeconfmap[$kconfig]}"
   fi
  fi

  pod=$(KUBECONFIG=$path_to_kubeconfig kubectl get pods | grep $podPrefix  | head -n 1 | awk '{print $1}')

  if [ -z "${port}" ]
  then
   port=$(KUBECONFIG=$path_to_kubeconfig kubectl get pod $pod --template='{{(index (index .spec.containers 0).ports 0).containerPort}}{{"\n"}}')
  fi

  # kills any process listening to desiredPort

  processOnPort=$(lsof -t -i:$desiredPort)
  if [[ ! -z $processOnPort ]]
  then
     echo "As first step killing  existing process $processOnPort listening on $desiredPort"      
     kill $processOnPort
  fi

  echo "====> POD $pod  listening on $desiredPort  (launched command: kubectl port-forward $pod $desiredPort:$port)"

  KUBECONFIG=$path_to_kubeconfig kubectl port-forward $pod $desiredPort:$port &
  done <<< "$val"
done
echo ""
echo "==================== END PORTFORWARDS ============================"
sleep infinity
