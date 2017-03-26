#!/bin/bash
#title          :websitemonitor-cron.sh
#description    :A script that will check if a website is online or not and 
#                log the results to the specified file.
#author         :William Gile
#date           :20170323
#version        :1.0    
#usage          :Set as a cron to monitor the online status of a website and 
#                the connection status of the local pc.  Configure which 
#                optional events are saved to the log with parameters (-u,-o)
#                For my use I check the status of the website and the script
#                every minute (-o), and log the uptime once a day (-u -o).
#notes          :Use both -u and -o to create a log entery every time the 
#                script is ran,  When called in the terminal status events
#                will be displayed.
#bash_version   :4.3.30(1)-release
#============================================================================

#Create Variables and Flags
LOG_UP_EVENT=false
LOG_OFFLINE_EVENT=false
WEBSITE=""
FILENAME=""
PARAM_HELP_DISPLAY="
-h this help file
-o force script will log when it is offline 
-u force script will log when website is up
-w REQUIRED website url to check (ping)
-f REQUIRED logfile (location/name) "

#Check incoming options
#Echo error and exit if parameters are invalid
while getopts ":huow:f:" opt; do
  case $opt in
  h)  echo "$PARAM_HELP_DISPLAY" >&2
      exit 1 ;;
  u)  LOG_UP_EVENT=true
      echo "-u was enabled, up events will be logged" >&2 ;;
  o)  LOG_OFFLINE_EVENT=true
      echo "-o was enabled, offline connection events will be logged" >&2 ;;
  w)  WEBSITE=$OPTARG
      echo "-w = $WEBSITE" >&2 ;;
  f)  FILENAME=$OPTARG
      echo "-f = $FILENAME" >&2 ;;
  \?) echo "Invalid option: -$OPTARG" >&2
      exit 1 ;;
  :)  echo "Option -$OPTARG requires an argument." >&2
      exit 1 ;;
  esac
done
#Echo error and exit if parameter arguments are invalid
if [ -z $WEBSITE ]; then
  echo "WEBSITE is required (-w)"
  exit 1
elif [ -z $FILENAME ]; then
  echo "FILENAME is required (-f)"
  exit 1
fi

#Check connection
echo "checking connection"
# Send ping to google to verify we are online
# Only send two pings (in case first fails) and send output to /dev/null
ping -c2 www.google.com > /dev/null

# If the return code from ping ($?) is 0 (meaning there was no error)
if [ $? = 0 ]; then
  # Website monitor is online
  echo "connection is online"
  
  # Send ping to website to check if site is online
  # Only send two pings (in case first fails) and send output to /dev/null
  echo "checking $WEBSITE"
  ping -c2 $WEBSITE > /dev/null
  
  # If the return code from ping ($?) is not 0 (meaning there was an error)
  if [ $? != 0 ]; then
    # Website is Down, always log it
    echo "$WEBSITE is down, logged to $FILENAME"
    echo $(date +%Y-%m-%d:%H:%M:%S) " $WEBSITE was down" >> $FILENAME
    # ADD_ON Send email/alert user - Need to configure OS so leave it to end 
    #user to implement 		
  else
    # Website is Up, check if it needs to be logged
    echo "$WEBSITE is up"
    if [ $LOG_UP_EVENT = true ]; then	        
      echo "logging online event (-u) to $FILENAME"
      echo $(date +%Y-%m-%d:%H:%M:%S) " $WEBSITE was up" >> $FILENAME
    fi
  fi
else
  # Website monitor is not online, check if it needs to be logged
  echo "connection is offline, check if it needs to be logged"
    if [ $LOG_OFFLINE_EVENT = true ]; then
      echo "logging offline event (-o) to $FILENAME"
      echo $(date +%Y-%m-%d:%H:%M:%S) " website monitor connection is offline" >> $FILENAME				
  fi	
fi
