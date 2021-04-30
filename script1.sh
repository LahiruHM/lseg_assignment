#!/bin/bash

ASG_NAME=LSEGServiceASG
SSH_KEY_FOR_LG=/home/centos/.ssh/key.pem
SSH_USERNAME_FOR_LG=centos
DB_END_POINT=lseg-rds.crdxxeqjw7mf.us-east-1.rds.amazonaws.com
DB_NAME=web_page_status
REC_EMAIL=alerts.aws.assignment@gmail.com
test -f script1.log || touch script1.log
LG_IPs=$(aws --output text --query "Reservations[*].Instances[*].PrivateIpAddress" ec2 describe-instances --instance-ids `aws --output text --query "AutoScalingGroups[0].Instances[*].InstanceId" autoscaling describe-auto-scaling-groups --auto-scaling-group-names "LSEGServiceASG"`)
mysql -h lseg-rds.crdxxeqjw7mf.us-east-1.rds.amazonaws.com -P 3306 -u admin -e "CREATE DATABASE IF NOT EXISTS web_page_status;"
mysql -h lseg-rds.crdxxeqjw7mf.us-east-1.rds.amazonaws.com -P 3306 -u admin -D web_page_status -e "CREATE TABLE IF NOT EXISTS status_log ( status varchar(100), timestamp varchar(100) );"
for IP in $LG_IPs
do
	  out=$(ssh -q -tt -o  "StrictHostKeyChecking no" -i $SSH_KEY_FOR_LG $SSH_USERNAME_FOR_LG@$IP 'curl -sI http://startmyin-loadbala-641fppoj4jun-781586019.us-east-1.elb.amazonaws.com | head -n 1' 2>&1)
	  res_code=$(echo $out | cut -d " " -f2)
          time_stamp="$(date +"%D %T")" 
	  if [ $res_code -eq 200 ]
          then
		echo "$time_stamp Web service is up" >> script1.log
		mysql -h $DB_END_POINT -P 3306 -u admin -D $DB_NAME -e "INSERT INTO status_log(status,timestamp) VALUES ('success','$time_stamp');"
                mail -s 'Web_page_loading' $REC_EMAIL <<< 'Web page loading'
	  else
		echo "$time_stamp Web service is down" >> script1.log
		mysql -h $DB_END_POINT -P 3306 -u admin -D $DB_NAME -e "INSERT INTO status_log(status,timestamp) VALUES ('error','$time_stamp');"

		mail -s 'Critical Error' $REC_EMAIL <<< 'Web page not loading'
	  fi
		echo "$time_stamp Script_1 successfully executed" >> script1.log
done

