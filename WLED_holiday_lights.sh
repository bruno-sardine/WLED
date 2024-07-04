#!/bin/bash


# WLED light presets for the following holidays
# New Years, Valentines, St Patricks, Easter, Cinco de Mayo, Memorial Day, Independence Day
# Labor Day, Halloween, Thanksgiving, Christmas, New Years Eve

# create log file
logfile=/Users/[your username]/Desktop/WLED.log
echo -e "\n-------- Start Holiday Check --------" >> $logfile
RIGHTNOW=$(date +"%A, %B %d, %Y %I:%M:%S %p")
echo $RIGHTNOW >> $logfile
# Get the year from the argument
YEAR=$(date '+%Y')

# Get today's date and set a couple of needed variables
TODAY=$(date +"%m/%d/$YEAR")
month=$(date -j -f "%m/%d/%Y" "$TODAY" +%m)
day=$(date -j -f "%m/%d/%Y" "$TODAY" +%d)


# Function to calculate the date of Easter for a given year
calculate_easter() {
    local Y=$1

    local a=$((Y % 19))
    local b=$((Y / 100))
    local c=$((Y % 100))
    local d=$((b / 4))
    local e=$((b % 4))
    local f=$(((b + 8) / 25))
    local g=$(((b - f + 1) / 3))
    local h=$((19 * a + b - d - g + 15))
    local h=$((h % 30))
    local i=$((c / 4))
    local k=$((c % 4))
    local l=$((32 + 2 * e + 2 * i - h - k))
    local l=$((l % 7))
    local m=$(((a + 11 * h + 22 * l) / 451))
    local month=$(((h + l - 7 * m + 114) / 31))
    local day=$(((h + l - 7 * m + 114) % 31 + 1))

    printf "%02d/%02d/%04d\n" $month $day $Y
}

# Function to find the date of the Nth weekday of a given month and year
nth_weekday_of_month() {
    local N=$1
    local WEEKDAY=$2
    local MONTH=$3
    local YEAR=$4

    # Find the first occurrence of the weekday in the month
    local FIRST=$(date -j -f "%Y-%m-%d" "$YEAR-$MONTH-01" +"%w")
    local OFFSET=$(( ( ( $WEEKDAY - $FIRST + 7 ) % 7 ) + 1 ))

    # Calculate the date of the Nth occurrence
    local DATE=$(( ($N - 1) * 7 + $OFFSET ))
    echo $(date -j -f "%Y-%m-%d" "$YEAR-$MONTH-$DATE" +"%m/%d/%Y")
}

# Function to check if a date is within +/- 2 days of a holiday
within_two_days() {
    local HOLIDAY=$1
    local HOLIDAY_DATE=$(date -j -f "%m/%d/%Y" "$HOLIDAY" +%s)
    local TODAY_DATE=$(date -j -f "%m/%d/%Y" "$TODAY" +%s)
    local DIFF=$(( (HOLIDAY_DATE - TODAY_DATE) / (60*60*24) ))
    if [ $DIFF -ge -2 ] && [ $DIFF -le 2 ]; then
        echo 1
    else
        echo 0
    fi
}

# Function to check if a date is within +/- 4 days of a holiday
within_four_days() {
    local HOLIDAY=$1
    local HOLIDAY_DATE=$(date -j -f "%m/%d/%Y" "$HOLIDAY" +%s)
    local TODAY_DATE=$(date -j -f "%m/%d/%Y" "$TODAY" +%s)
    local DIFF=$(( (HOLIDAY_DATE - TODAY_DATE) / (60*60*24) ))

    if [ $DIFF -ge -4 ] && [ $DIFF -le 4 ]; then
        echo 1
    else
        echo 0
    fi
}



# ##########################################
# BEGIN Define your holidays
# ##########################################

# New Years (run it from 1/1 +5 days)
NEW_YEARS_DAY="01/01/$YEAR"

# Valentines Day (just run it on the day)
VALENTINE_DAY="02/14/$YEAR"

# St Patricks
STPATRICKS_DAY="03/17/$YEAR"

# Easter Sunday (run +/- 2 days)
EASTER=$(calculate_easter $YEAR)

# Cinco De Mayo
CINCODEMAYO="05/05/$YEAR"

# Memorial Day (this date formula works until 2035 and maybe after - I just got tired of checking)
MEMORIAL_DAY=$(date -j -v -1d -v -Mon -f "%Y-%m-%d" "$YEAR-06-01" +"%m/%d/%Y")

# Independence Day 
INDEPENDENCE_DAY="07/04/$YEAR"

# Labor Day (1st Monday in September (run +/- 2 days))
LABOR_DAY=$(nth_weekday_of_month 1 1 09 $YEAR)

# Halloween (run from 10/15 to Nov 1)
HALLOWEEN=$"10/31/$YEAR"

# Thanksgiving (4th Thursday in November (run from -3 days to the day))
THANKSGIVING=$(nth_weekday_of_month 4 4 11 $YEAR)

# Christmas (run from Thanksgiving+1 to Dec 31)
CHRISTMAS="12/25/$YEAR"

# New Years Eve
NYE="12/31/$YEAR"

#echo -e "\nDisplaying all holidays for the year $YEAR" >> $logfile
#echo - New Years Day: $NEW_YEARS_DAY >> $logfile
#echo - Valentines Day: $VALENTINE_DAY >> $logfile
#echo - St. Patricks Day: $STPATRICKS_DAY >> $logfile
#echo - Easter Sunday: $EASTER >> $logfile
#echo - Cinco De Mayo: $CINCODEMAYO >> $logfile
#echo - Memorial Day: $MEMORIAL_DAY >> $logfile
#echo - 4th of July: $INDEPENDENCE_DAY >> $logfile
#echo - Labor Day: $LABOR_DAY >> $logfile
#echo - Halloween: $HALLOWEEN >> $logfile
#echo - Thanksgiving: $THANKSGIVING >> $logfile
#echo - Christmas: $CHRISTMAS >> $logfile
#echo - New Years Eve: $NYE >> $logfile

# ##########################################
# END Define your holidays
# ##########################################


# ##########################################
# Routines defined to run times
# we want some effects to run.  Thanksgiving
# being an odd one because we want Christmas
# to activate the very next day (which is a 
# variable day we need to figure out)
# ##########################################

# Holidays we want lights on +/- 2 days of the holiday
easter_2_days=$(within_two_days $EASTER)
memorial_2_days=$(within_two_days $MEMORIAL_DAY)
labor_2_days=$(within_two_days $LABOR_DAY)

# Holidays we want lights on +/- 4 days of the holiday
independence_2_days=$(within_four_days $INDEPENDENCE_DAY)


# Special case for Thanksgiving and christmas
# Convert Thanksgiving date to the same format as current_date
thanksgiving_date=$(date -j -f "%m/%d/%Y" "$THANKSGIVING" +%m/%d/%Y)
# Calculate the date 3 days before Thanksgiving, and the day after
three_days_before_thanksgiving=$(date -j -v-3d -f "%m/%d/%Y" "$THANKSGIVING" +%m/%d/%Y)
day_after_thanksgiving=$(date -j -v+1d  -f "%m/%d/%Y" "$THANKSGIVING" +%m/%d/%Y)
DEC30="12/30/$YEAR"
december_thirty=$(date -j -f "%m/%d/%Y" "$DEC30" +%m/%d/%Y)

# ##########################################
# END Run Times
# ##########################################

# #####################################################################################
# Set a WLED Preset variable based on holidays and how long I want them to run
# #####################################################################################
echo -e "\nChecking if we are in or around a holiday..." >> "$logfile"

# NEW YEARS
# Run from Jan 1st to Jan 5th
if [[ "$month" == "01" && "$day" -ge 1 && "$day" -le 5 ]]; then
    echo "..The date $TODAY is between January 1st and January 5th." >> "$logfile"
    PRESET=34
    echo -e "..New Years WLED Preset $PRESET is activating.\n" >> "$logfile"
fi

# VALENTINES DAY
# Run on Valentine's Day only
if [[ "$TODAY" == "02/14/$YEAR" ]]; then
    echo "..The date $TODAY is Valentine's Day" >> "$logfile"
    PRESET=19
    echo -e "..Valentines Day WLED Preset $PRESET is activating.\n" >> "$logfile"
fi

# EASTER
# Run lights 2 days before and 2 days after Easter
if [ "$easter_2_days" -eq 1 ]; then
    echo "..The date $TODAY is within 2 days of Easter Sunday" >> "$logfile"
    PRESET=35
    echo -e ".. Easter WLED Preset $PRESET is activating.\n" >> "$logfile"
fi

# CINCO DE MAYO
# Run on Cinco de Mayo only
if [[ "$TODAY" == "05/05/$YEAR" ]]; then
    echo "..The date $TODAY is Cinco de Mayo" >> "$logfile"
    PRESET=32
    echo -e "..Cinco de Mayo WLED Preset $PRESET is activating.\n" >> "$logfile"
fi


# MEMORIAL DAY
# Run lights 2 days before and 2 days after Memorial Day
if [ "$memorial_2_days" -eq 1 ]; then
    echo "..The date $TODAY is within 2 days of Memorial Day" >> "$logfile"
    PRESET=22
    echo -e "..Memorial Day WLED Preset $PRESET is activating.\n" >> "$logfile"
fi

# INDEPENDENCE DAY - Set 1
# Run lights between Jul 1 and Jul 3, but not on Jul 4
if [[ "$month" == "07" && "$day" -ge 1 && "$day" -le 3 ]]; then
    echo "..The date $TODAY is between July 1st and July 7th." >> "$logfile"
    PRESET=11
    echo -e "..Independence Day WLED Preset $PRESET is activating.\n" >> "$logfile"
fi

# INDEPENDENCE DAY - Set 2
# Run lights between Jul 5 and Jul 7, but not on Jul 4
if [[ "$month" == "07" && "$day" -ge 5 && "$day" -le 7 ]]; then
    echo "..The date $TODAY is between July 1st and July 7th." >> "$logfile"
    PRESET=11
    echo -e "..Independence Day WLED Preset $PRESET is activating.\n" >> "$logfile"
fi

# INDEPENDENCE DAY - Set 3
# Run on 4th of July only
if [[ "$TODAY" == "$INDEPENDENCE_DAY" ]]; then
    echo "..The date $TODAY is 4th of July" >> "$logfile"
    PRESET=7
    echo -e "..4th of July WLED Preset $PRESET is activating.\n" >> "$logfile"
fi

# LABOR DAY
# Run lights 2 days before and 2 days after Labor Day
if [ "$labor_2_days" -eq 1 ]; then
    echo "..The date $TODAY is within 2 days of Labor Day" >> "$logfile"
    PRESET=22
    echo -e "..Labor Day WLED Preset $PRESET is activating.\n" >> "$logfile"
fi

# HALLOWEEN
# Run lights between Oct 15 and Nov 5
if { [[ "$month" == "10" && "$day" -ge 15 ]] || [[ "$month" == "11" && "$day" -le 5 ]]; }; then
    echo "..The date $TODAY is between Oct 15th and Nov 5th." >> "$logfile"
    PRESET=36
    echo -e "..Halloween WLED Preset $PRESET is activating.\n" >> "$logfile"
fi

# THANKSGIVING
# We want the lights to run 3 days before thanksgiving, but end on thanksgiving.  Thanksgiving day +1 should start christmas lights
if [[ "$TODAY" == "$thanksgiving_date" || "$TODAY" > "$three_days_before_thanksgiving" && "$TODAY" < "$thanksgiving_date" ]]; then
    echo "..The date $TODAY is between 3 days before Thanksgiving and Thanksgiving Day" >> "$logfile"
    PRESET=33
    echo -e "..Thanksgiving WLED Preset $PRESET is activating.\n" >> "$logfile"
fi

# Christmas
# We want the lights to run the day after Thanksgiving, and until Dec 30
if [[ "$TODAY" == "$day_after_thanksgiving" || "$TODAY" > "$day_after_thanksgiving" && "$TODAY" < "$december_thirty" ]]; then
    echo "..The date $TODAY is between [after Thanksgiving Day] and [Dec 30]" >> "$logfile"
    PRESET=37
    echo -e "..Christmas WLED Preset $PRESET is activating.\n" >> "$logfile"
fi

# New Years Eve
# Run on New Years Eve only
if [[ "$TODAY" == "12/31/$YEAR" ]]; then
    echo "..The date $TODAY is New Year's Eve" >> "$logfile"
    PRESET=18
    echo -e "..New Year's Eve WLED Preset $PRESET is activating.\n" >> "$logfile"
fi


#Turn on lights if preset variable exists

if [[ $PRESET ]]; then
echo "Sending request to turn on Lights..." >> $logfile
    response=$(curl -s -X POST "http://x.x.x.x/json/state" -H "Content-Type: application/json" -d '{"on":true,"bri":255,"ps":"'"$PRESET"'"}')
    # Check if the response contains {"success":true}
    if [[ "$response" == *'"success":true'* ]]; then
       echo "Request good: $response" >> $logfile
    else
       echo "Request failed: $response" >> $logfile
    fi
else
echo -e "  No holdays lights for today.\n Making sure lights stay off..." >> $logfile
    response=$(curl -s -X POST "http://x.x.x.x/json/state" -H "Content-Type: application/json" -d '{"on":false}')
    # Check if the response contains {"success":true}
    if [[ "$response" == *'"success":true'* ]]; then
       echo "Request good: $response" >> $logfile
    else
       echo "Request failed: $response" >> $logfile
    fi
fi
echo -e "\n--------- End Holiday Check ---------" >> $logfile

