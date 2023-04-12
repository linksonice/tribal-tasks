This README covers tasks 2 and 3, the CloudFormation task, and the ECR repo / local container build tasks respectively. 

# task 2

The basic method is this:

1 -

git clone https://github.com/linksonice/tribal-tasks.git

2 - 

cd tribal-tasks/

3 - 

aws cloudformation create-stack --stack-name tribal-task2 --template-body file://task2.yaml --parameters ParameterKey=AvailabilityZone,ParameterValue=**eu-west-2a** ParameterKey=EnvironmentType,ParameterValue=**dev** ParameterKey=KeyPairName,ParameterValue=**london-key-pair**

In the above methodology, there are only a few parameters to pass to the CF - these parameters are in **bold**:

- an existing key pair of your choice, in this case mine is called **london-key-pair**
- An environment variable, in this case **dev** is fine for everyone's purposes
- an availability zone, in this case I chose **eu-west-2a** in the London, UK region because it's closeby and saves time

EVERYTHING ELSE is FRESH i.e. the security group, and the EC2. The VPC used will be the default for your account in that region.

HOW TO TEST:

As long as you only have the above stack active, run the command:

aws cloudformation describe-stacks | grep OutputValue | awk '{ print $2 }' | awk -F"\"" '{ print $2":5000"}' | xargs curl

or just find the output IP based on aws cloudformation describe-stacks --stack-name tribal-task2, and browse it on port 5000!

FINALLY TO CLEAN UP:

aws cloudformation delete-stack --stack-name tribal-task2

# task 3

Run the build-and-test.sh script like so:

./build-and-test.sh eu-west-2a python-api tribal

to get a "tribal" tag, or run

./build-and-test.sh eu-west-2a python-api 

to get a "latest" tag. Either way the end result will be a locally running docker container [I poached the script from elsewhere, but added the health check according to the request!] that can be tested like so:

andrei@area66:~/devops/cloudformation/tribal-tasks$ curl localhost:5000
[{"id":1,"name":"Monday"},{"id":2,"name":"Tuesday"},{"id":3,"name":"Wednesday"},{"id":4,"name":"Thursday"},{"id":5,"name":"Friday"},{"id":6,"name":"Saturday"},{"id":7,"name":"Sunday"}]

The OTHER end result will of course be a private repo in ECR by the name of python-api, with an image tag either tribal or latest depending on the tag you chose. 

The pre-requisites are of course a local, VIABLE AWS-CLI config/creds set in ~/.aws, and a viable, recent aws-cli package on your OS.
 
