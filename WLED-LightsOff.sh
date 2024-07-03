#!/bin/bash

<<COMMENT
Turn the lights off.
During any holiday run, I want to turn the 
lights off at midnight.  This is controlled 
on crontab.  So it is going to send the OFF
command regardless is the lights were ever on or not.
COMMENT

logfile=/Users/[your username]/Desktop/WLED.log

echo -e "\n--------  Turn the lights off ----------" >> $logfile
echo `(date +"%A, %B %d, %Y %I:%M:%S %p")` >> $logfile
echo "Sending request to turn off the lights..." >> $logfile
response=$(curl -s -X POST "http://x.x.x.x/json/state" -H "Content-Type: application/json" -d '{"on":false}')
# Check if the response contains {"success":true}
if [[ "$response" == *'"success":true'* ]]; then
    echo "Request good: $response" >> $logfile
else
    echo "Request failed: $response" >> $logfile
fi
echo -e "\n--------------------------- Hopefully ----------------------------" >> $logfile
echo "---------- All of this machinery was making modern music ---------" >> $logfile
echo -e "--------------------------- Goodnight ----------------------------\n" >> $logfile                                                          
