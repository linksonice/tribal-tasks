# tribal-tasks

This README covers task 2, because that is the CloudFormation task. 

The basic method is this:

1 -

git clone https://github.com/linksonice/tribal-tasks.git

2 - 

cd tribal-tasks/

3 - 

aws cloudformation create-stack --stack-name tribal-task2 --template-body file://task2.yaml --parameters ParameterKey=AvailabilityZone,ParameterValue=**eu-west-2a** ParameterKey=EnvironmentType,ParameterValue=**dev** ParameterKey=KeyPairName,ParameterValue=**london-key-pair**

In the above methodology, there are only a few parameters to pass to the CF - these parameters are in **bold**:

- an existing key of your choice, in this case mine is called **london-key-pair**
- An environment variable, in this case **dev** is fine for everyone's purposes
- an availability zone, in this case I chose **eu-west-2a** in the London, UK region

EVERYTHING ELSE is FRESH i.e. the security group, the EC2 and what it's hosting.

HOW TO TEST:

As long as you only have the above stack active, run the command:

aws cloudformation describe-stacks | grep OutputValue | awk '{ print $2 }' | awk -F"\"" '{ print $2":5000"}' | xargs curl

or just find the output IP based on aws cloudformation describe-stacks --stack-name tribal-task2, and browse it on port 5000!

FINALLY TO CLEAN UP:

aws cloudformation delete-stack --stack-name tribal-task2

Thanks.
