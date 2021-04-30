#!/bin/bash

ASG_NAME=LSEGServiceASG
SSH_KEY_FOR_LG=/home/centos/.ssh/key.pem
SSH_USERNAME_FOR_LG=centos
REC_EMAIL=alerts.aws.assignment@gmail.com
time_stamp="$(date +"%D %T")"
test -f script12.log || touch script12.log
LG_IPs=$(aws --output text --query "Reservations[*].Instances[*].PrivateIpAddress" ec2 describe-instances --instance-ids `aws --output text --query "AutoScalingGroups[0].Instances[*].InstanceId" autoscaling describe-auto-scaling-groups --auto-scaling-group-names "LSEGServiceASG"`)
echo "EC2 Instance IPs"
echo $LG_IPs

for IP in $LG_IPs
do
	  scp -o "StrictHostKeyChecking no" -C -i $SSH_KEY_FOR_LG $SSH_USERNAME_FOR_LG@$IP:/var/www/aws_assignment/public_html/index.html "$IP"_index.html
          scp -o "StrictHostKeyChecking no" -C -i $SSH_KEY_FOR_LG $SSH_USERNAME_FOR_LG@$IP:/var/www/aws_assignment/*_`date +%m%d%y` .
          EXIT_STATUS=$?
	  if [ "$EXIT_STATUS" -eq "0" ]
	  then		   
          tar czf upload_`date +%m%d%y%H%M`.tar.gz *_`date +%m%d%y` *_index.html
	  aws s3 cp upload_`date +%m%d%y%H%M`.tar.gz s3://awsassignmentlseg/
	  EXIT_STATUS=$?
 		if [ "$EXIT_STATUS" -eq "0" ]
		then
			rm -rf /home/centos/*_`date +%m%d%y`
			rm -rf /home/centos/upload_`date +%m%d%y%H%M`.tar.gz
			echo "$time_stamp Script_2 successfully executed" >> script2.log
		else
			mail -s 'Critical Error' $REC_EMAIL <<< 'Files did not get uploaded'	
		fi      
	  else
	  mail -s 'Critical Error' $REC_EMAIL <<< 'Files did not get downloaded and uploaded'
	  echo "$time_stamp Script_2 not successfully executed" >> script2.log          
 	  fi
done
