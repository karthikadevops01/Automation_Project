#!/bin/bash
sudo apt update -y
echo "--APT UPDATE COMPLETED--"
echo
echo "--APACHE2 PACKAGE INSTALLATION--"
pkg=apache2
status="$(dpkg-query -W --showformat='${db:Status-Status}' "$pkg" 2>&1)"
if [ ! $? = 0 ] || [ ! "$status" = installed ]; then
  sudo apt install $pkg -y
  echo "--APACHE INSTALLED--"
fi
if [ $? = 0 ]||[ "$status" = installed ];
then
  echo "--APACHE ALREADY INSTALLED--"
fi
echo
sudo ufw app list
sudo systemctl status apache2
echo "--APACHE STATUS CHECKED--"
echo
echo "Archiving Apache log files in temp folder"
sudo tar -cvf /tmp/karthika-httpd-logs-$(date '+%d%m%Y-%H%M%S').tar /var/log/apache2/
echo "--ARCHIVING COMPLETED--"
echo
echo "Backing up in S3 Bucket"
aws s3 cp /tmp/karthika-httpd-logs-$(date '+%d%m%Y-%H%M%S').tar s3://upgrad-karthika/karthika-httpd-logs-$(date '+%d%m%Y-%H%M%S').tar
echo "--BACK UP COMPLETED--"
echo

