#!/bin/bash

LOG_FILE="esxi-cfg.log"
HOST_SRC="esxi-hosts"
BACKUP_DIR="/backup/esxi-cfg"
DATE=$(date +"%d-%m-%y")
RECIPIENT=""

while read ehost; do
	/usr/sbin/fping -q $ehost
	if [[ $? -eq  0 ]]; then
           source_host=$(/usr/bin/ssh -n root@$ehost 'vim-cmd hostsvc/firmware/backup_config')
	   /usr/bin/wget -a $LOG_FILE -O $BACKUP_DIR/$ehost-$DATE.tgz $(echo $source_host | /usr/bin/awk '{ print $NF }' | /bin/sed "s/\*/$ehost/") --no-check-certificate
	  if [[ $? -eq 0 ]]; then
	      echo "Backup config job $ehost was completed succsesfully" | /bin/mail -s "Backup config job $ehost was completed succsesfully" $RECIPIENT
	  else
	      echo "Backup config job $ehost wasn't completed succsesfully" | /bin/mail -s "Backup config job $ehost wasn't completed succsesfully" $RECIPIENT
          fi
        fi  
done < $HOST_SRC



