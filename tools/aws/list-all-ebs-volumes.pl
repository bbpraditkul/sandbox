#!/usr/bin/perl


open (FH, 'aws ec2 describe-volumes --query 'Volumes[].[Size,Iops,Tags[?Key==`Name`].Value]' --output text|');
