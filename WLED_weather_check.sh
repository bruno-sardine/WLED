#!/bin/bash

# ###############################
# Weather Check!
# run "Rain" preset at sunrise for an hour
# if % chance of rain is > 50%
# else just turn on solid yellow for an hour
# indicating probably sun
# ###############################
logfile=/Users/[your username]/Desktop/WLED.log

echo "-------- Start Weather Check --------" >> $logfile
RIGHTNOW=$(date +"%A, %B %d, %Y %I:%M:%S %p")
echo $RIGHTNOW >> $logfile
#  input data string
data=`curl -s "http://wttr.in/[airport code]?1" | grep "%"`
# Extracting numbers and percentages
numbers=$(echo "$data" | grep -oE '[0-9]+\.[0-9]+' | awk 'NR <= 4')
percentages=$(echo "$data" | grep -oE '[0-9]+%' | awk 'NR <= 4' | tr -d '%')
echo "Checking if any percentage is greater than 50..."
found=false
for (( i=1; i<=4; i++ )); do
    number=$(echo "$numbers" | awk -v i=$i 'NR == i {print}')
    percentage=$(echo "$percentages" | awk -v i=$i 'NR == i {print}')
    
    if (( $(echo "$percentage > 50" | bc -l) )); then
        echo "Found entrie(s) with a $percentage% chance of rain." >> $logfile
        found=true

    fi
done

if $found; then
    echo "Sending request to set rainy weather..." >> $logfile
    response=$(curl -s -X POST "http://x.x.x.x/json/state" -H "Content-Type: application/json" -d '{"on":true,"bri":255,"ps":"14"}')
    # Check if the response contains {"success":true}
    if [[ "$response" == *'"success":true'* ]]; then
       echo "Request good: $response" >> $logfile
    else
    echo "Request failed: $response" >> $logfile
    fi
fi
if ! $found; then
    echo "No percentage of rain greater than 50%." >> $logfile
    echo "Sending request to set sunny weather..." >> $logfile
    response=$(curl -s -X POST "http://x.x.x.x/json/state" -H "Content-Type: application/json" -d '{"on":true,"bri":255,"ps":"15"}')
    # Check if the response contains {"success":true}
    if [[ "$response" == *'"success":true'* ]]; then
       echo "Request good: $response" >> $logfile
    else
       echo "Request failed: $response" >> $logfile
    fi
fi
echo "End weather check..." >> $logfile
echo -e "\nLights will turn off in 1.5hrs." >> $logfile

# 1.5hr after sunrise, turn off the lights.
sleep 5400
echo `(date +"%A, %B %d, %Y %I:%M:%S %p")` >> $logfile
echo -e "Weather: Sending request to turn off lights..." >> $logfile
response=$(curl -s -X POST "http://x.x.x.x/json/state" -H "Content-Type: application/json" -d '{"on":false}')
# Check if the response contains {"success":true}
if [[ "$response" == *'"success":true'* ]]; then
    echo "Request good: $response" >> $logfile
else
    echo "Request failed: $response" >> $logfile
fi
echo -e "\n--------- End Weather Check ---------" >> $logfile