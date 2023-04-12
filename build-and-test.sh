#!/bin/bash

if [ $# -eq 0 ]; then
   echo "No arguments supplied"
   echo "Usage:<script name> region, repo, tag"
   exit 1
fi

declare -r Region=$1
declare -r Repo=$2
declare -r Tag="${3:-latest}"
declare -r BuildPath="./build-images/${Repo}" 

out=$(aws ecr describe-repositories --repository-names ${Repo} 2>/dev/null)
Status=$?
if [ $Status -gt 0 ]; then
   out=$(aws ecr create-repository --repository-name ${Repo}) 
   RepoURI=$(echo $out | jq -r '.repository.repositoryUri')
   aws ecr put-lifecycle-policy --repository-name ${Repo} \
       --lifecycle-policy-text file://./ecr-lifecycle-policy.json
else
   RepoURI=$(echo $out | jq -r '.repositories[0].repositoryUri')
fi

echo "The RepoURI is: $RepoURI"

if [ -z $RepoURI ]; then
   echo "Error for ${Repo}"
   exit 1
fi

Registry=$(echo $RepoURI | sed "s/\/$Repo//")
echo $Registry

aws ecr get-login-password | docker login --username AWS --password-stdin $Registry
Status=$?
if [ $Status -gt 0 ]; then
   echo "ecr login failed"
   exit 1;
fi

cd $BuildPath

docker build -t ${Repo}:${Tag} . 
Status=$?
if [ $Status -gt 0 ]; then
   echo "Build failed for ${Repo}"
   exit 1;
fi

docker tag $Repo:$Tag ${RepoURI}:${Tag}
docker push ${RepoURI}:${Tag}
Status=$?
if [ $Status -gt 0 ]; then
   echo "image push failed for ${Repo}"
   exit 1;
fi

docker run -p5000:5000 -d $RepoURI

sleep 10

# HEALTH CHECK FOLLOWS!
curl 127.0.0.1:5000/ && curl 127.0.0.1:5000/2 && curl -X POST 127.0.0.1:5000/

EXITCODE=$?
test $EXITCODE -eq 0 && echo "Healthcheck is good!" || echo "Healthcheck result is BAD!" 
exit $EXITCODE

