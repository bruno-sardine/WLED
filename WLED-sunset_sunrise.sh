# ###########
# Get Sunset and Sunrise Times
# ###########
logfile=/Users/[your username]/Desktop/WLED.log

echo "------------------------- BEGIN THE DAY --------------------------" >> $logfile
echo "--------------------- with a friendly voice ----------------------\n" >> $logfile
RIGHTNOW=$(date +"%A, %B %d, %Y %I:%M:%S %p")
echo $RIGHTNOW >> $logfile


# Function to fetch sunrise and sunset times.  I had to add this because one time is returned nothing.
fetch_times() {
  setrise=$(curl -s "http://wttr.in/[airport code]?format=%S+%s")
  read sunrise sunset <<< "$setrise"
}

# Initial fetch
fetch_times

# Retry if sunrise or sunset is empty, up to 5 times
retry_count=0
max_retries=5

while [[ (-z "$sunrise" || -z "$sunset") && $retry_count -lt $max_retries ]]; do
  echo "Failed to fetch times, retrying... ($((retry_count + 1))/$max_retries)"
  fetch_times
  ((retry_count++))
done

# Check if the fetch was successful after retrying
if [[ -z "$sunrise" || -z "$sunset" ]]; then
  echo "Failed to fetch sunrise and sunset times after $max_retries attempts." >> $logfile
  exit 1
else
  echo "\nAdding Sunrise Sunset CRON Entries..." >> $logfile
  echo "Sunrise: $sunrise" >>$logfile
  echo "Sunset: $sunset" >> $logfile
fi

sunriseHour="${sunrise:0:2}"
sunriseMinute="${sunrise:3:2}"
sunsetHour="${sunset:0:2}"
sunsetMinute="${sunset:3:2}"




# clean out previous crontab entry
crontab -l | grep -v 'WLED_'  | crontab  - 
# add new crontab sunrise entry and run the weather stuff
(crontab -l ; echo "$sunriseMinute $sunriseHour * * * /Users/[your username]/WLED_weather_check.sh") | crontab  -
# add new crontab entry for sunset and run the holiday stuff
(crontab -l ; echo "$sunsetMinute $sunsetHour * * * /Users/[your username]/WLED_holiday_lights.sh") | crontab  -
echo "---- End Sunrise Sunset CRON Entries ---\n" >> $logfile
