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
file=/tmp/karthika-httpd-logs-$(date '+%d%m%Y-%H%M%S').tar
aws s3 cp /tmp/karthika-httpd-logs-$(date '+%d%m%Y-%H%M%S').tar s3://upgrad-karthika/karthika-httpd-logs-$(date '+%d%m%Y-%H%M%S').tar
echo "--BACK UP COMPLETED--"
echo
echo "Check if inventory file exists, if not create it with header"
if [[ ! -f /var/www/html/inventory.html ]]; then
  echo "Log Type        Date Created            Type    Size" > /var/www/html/inventory.html
fi
echo "Get log file size and append data to inventory file"
size=$(sudo stat -c '%s' $file)
filename=$(basename -- "$file")
f="${filename%%.*}"
time="${f:17}"
echo "httpd-logs        $time        tar     $size" >> /var/www/html/inventory.html
echo
echo "Check if cronjob is created, if not create it"
if [[ ! -f /etc/cron.d/automation ]]; then
  echo "0 8 * * * bash /root/Automation_Project/Automation_Project/automation.sh" > /etc/cron.d/automation
fi
if [[ -f /etc/cron.d/automation ]]; then
  echo "/etc/cron.d/automation already exists"
fi


