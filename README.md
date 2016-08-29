#This Repository contain mysql template and bash script that fetch data from mysql.
#Fill the credentials of mysql in script mysql_monitoring.sh on line 22 and 23
#make the entry of hostname according to your need, the script take the value from zabbix_agentd.conf "Hostname" flag
#Give permission to script
#Install zabbix sender on your machine that will send data to server
#Import the template "Bbox_Mysql.xml" on zabbix server
#Update the cron entry that will  run your script to send data
#Thats It.
