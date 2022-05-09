jmap -dump:live,format=b,file=/dumps/jmap-dump-$(hostname).bin $(ps aux | grep java | grep -v grep | awk '{print $2}')
