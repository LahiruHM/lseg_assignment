#!/bin/bash

cp /var/www/aws_assignment/requests.log /var/www/aws_assignment/error.log_"$HOSTNAME"_`date +%m%d%y`
echo " " > /var/www/aws_assignment/error.log
cp /var/www/aws_assignment/requests.log /var/www/aws_assignment/requests.log_"$HOSTNAME"_`date +%m%d%y`
echo " " > /var/www/aws_assignment/requests.log
