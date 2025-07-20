#!/bin/bash
#Script to update motd with relevant information for openSUSE Tumbleweed Slowroll

#Define output file
motd="/etc/motd"

# Collect information
HOSTNAME=`uname -n`
KERNEL=`uname -r`
CPU=`echo "$(grep -c processor /proc/cpuinfo)" x $(awk -F '[ :][ :]+' '/^model name/ { print $2; exit; }' /proc/cpuinfo)`
ARCH=`uname -m`
# openSUSE specific: Count available updates using zypper
ZYPPER=`zypper list-updates 2>/dev/null | grep -E '^v |^  ' | wc -l`
ALLDISK=`df -hl| grep "/dev/" | sed '/shm/d' |sed '/efi/d' | xargs -L1 echo`
ROOTDISKFree=`df -hl| grep "/dev/" | sed '/shm/d' |sed '/efi/d' | grep -w '/' | xargs -L1 echo| cut -d ' ' -f 4`
ROOTDISKUsed=`df -hl| grep "/dev/" | sed '/shm/d' |sed '/efi/d' | grep -w '/' | xargs -L1 echo| cut -d ' ' -f 3`
ROOTDISKTotal=`df -hl| grep "/dev/" | sed '/shm/d' |sed '/efi/d' | grep -w '/' | xargs -L1 echo |cut -d ' ' -f 2`
ROOTDISKPercent=`df -hl| grep "/dev/" | sed '/shm/d' |sed '/efi/d' | grep -w '/' | xargs -L1 echo | cut -d ' ' -f 5`
MEMORY1=`free -t -m | grep "Mem" | awk '{print $6" MB";}'`
MEMORY2=`free -t -m | grep "Mem" | awk '{print $2" MB";}'`
MEMPERCENT=`free | awk '/Mem/{printf("%.2f% (Used) "), $3/$2*100}'`
PROCESSES=`ps -ef | wc -l`
IPv4ADDRESSES=`ip -4 ad | grep -w "inet" | cut -d ' ' -f 6 | grep -v 127.0.0.1 | tr '\n' ' '`
IPv6ADDRESSES=`ip -6 ad | grep -w "inet6" | cut -d ' ' -f 6 | grep -v ::1/128 | tr '\n' ' '`
SERVICES=`/bin/sh /etc/motd.d/Suse-MOTD-Services.sh`
SSLCERTS=`/bin/sh /etc/motd.d/Suse-MOTD-sslCerts.sh`

#Time of day
HOUR=$(date +"%H")
if [ $HOUR -lt 12  -a $HOUR -ge 0 ]
then   TIME="Morning"
elif [ $HOUR -lt 17 -a $HOUR -ge 12 ]
then   TIME="Afternoon"
else   TIME="Evening"
fi

#System uptime
uptime=`cat /proc/uptime | cut -f1 -d.`
upDays=$((uptime/60/60/24))
upHours=$((uptime/60/60%24))
upMins=$((uptime/60%60))
upSecs=$((uptime%60))

#System load
LOAD1=`cat /proc/loadavg | awk {'print $1'}`
LOAD5=`cat /proc/loadavg | awk {'print $2'}`
LOAD15=`cat /proc/loadavg | awk {'print $3'}`

#Color variables
W="\033[0m"
B="\033[01;36m"
R="\033[01;31m"
G="\033[01;32m"
N="\033[0m"

#Clear screen before motd
cat /dev/null > $motd

# Using the provided ASCII art for openSUSE
echo -e "
$G                     ...................                                                                                    
                 ...........................                                                                                
              ........                .........                                                                             
           .......                         ......                                                                           
         ......                              ......                                                                         
        .....                                  ......                                                                       
      .....                                      .....                                                                      
     .....                 ......                  ....                                                                     
    .....              ...............              ....                                                                    
    ....            .........   ........             ....                                                                   
   ....            .....            ......            ....                                                                  
  ....            ....                .....           ....                                                                  
  ....           ....                   ....           ....                                                                 
  ....          ....                    ....           ....     ......   ..                                      ..  ..     
  ...           ....                     ....          ....    ..        ..   ....   ..   ..   .  .....  ....    ..  ..     
  ...           ....                     ....          ....     .....    ..  ..   ..  .. ...  ..  ..    ..   ..  ..  ..     
  ....          ....                     ...           ....         ...  .. ..    ..  .. . .. .   ..   ..    ..  ..  ..     
  ....           ....                   ....           ....          ..  ..  .    ..   ...  ...   ..    .    ..  ..  ..     
  .....           ......                ....          ....     .......   ..   .....    ..   ...   ..     .....   ..  ..     
   ....             ........           ....           ....                                                                  
   ......              .....          ....           ....                                                                   
    ......                          .....           ....                                                                    
     .......                      ......           ....                                                                     
      .........                .......            ....                                                                      
        ............      ..........            .....                                                                       
         ........................             .....                                                                         
           ......  ........                .......                                                                          
             ........                  ........                                                                             
                .............................                                                                               
                    .....................                                                                                   
                            ....                                                                                            $W
" > $motd
echo -e "$G---------------------------------------------------------------" >> $motd
echo -e "$W   Good $TIME$A You're Logged Into $B$A$HOSTNAME$W! "            >> $motd
echo -e "$G---------------------------------------------------------------" >> $motd
echo -e "$B    KERNEL $G:$W $KERNEL $ARCH                                 " >> $motd
echo -e "$B       CPU $G:$W $CPU                                          " >> $motd
echo -e "$B    MEMORY $G:$W $MEMORY1 used of $MEMORY2 - $MEMPERCENT             " >> $motd
echo -e "$B ROOT DISK $G:$W $ROOTDISKUsed used of $ROOTDISKTotal | $ROOTDISKFree Free" >> $motd
echo -e "$B IPv4 ADDR $G:$W $IPv4ADDRESSES                                    " >> $motd
echo -e "$B IPv6 ADDR $G:$W $IPv6ADDRESSES                                    " >> $motd
echo -e "$G---------------------------------------------------------------" >> $motd
echo -e "$B  LOAD AVG $G:$W $LOAD1, $LOAD5, $LOAD15                       " >> $motd
echo -e "$B    UPTIME $G:$W $upDays days $upHours hours $upMins minutes $upSecs seconds " >> $motd
echo -e "$B PROCESSES $G:$W There are currently $PROCESSES processes running " >> $motd
echo -e "$B    ZYPPER $G:$W $ZYPPER packages can be updated               " >> $motd
echo -e "$B     USERS $G:$W `users | wc -w` users logged in               " >> $motd
echo -e "$G---------------------------------------------------------------" >> $motd
echo -e " $SERVICES" >> $motd
echo -e "$G---------------------------------------------------------------" >> $motd
echo -e " $SSLCERTS" >> $motd
echo -e "$N" >> $motd