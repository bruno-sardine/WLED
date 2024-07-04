# WLED Scheduler with Weather for MacOS
Scripts used to automate WLED through the holidays and show weather

Inspiration came from https://printspired.shop/blogs/news/off-topic-controlling-wled-with-a-custom-holiday-schedule <br>
That site’s approach was to use the os call calendar() to figure out holidays.

For calendar() on macOS: I’m either dumb as shit, or it’s yet another os command on the Mac that differs just enough from every other implementation to be a hassle. The best I can tell is Apple ditched the calendar files (e.g. calendar.usholidays) in 14.4, and even using copies of a calendar file still will not work. Hence this project. I'm probably just dumb.  I tend to reinvent the wheel a lot.

### The basic workflow is this: 
1. Run a job at 5am to get the sunrise and sunset times and alter the crontab, daily, to reflect these new times.  
2. At sunrise, check the weather.  If there’s a 50% chance of rain or higher, show WLED’s “Rain” for 1.5 hrs.  Else, show solid yellow lights (sunny) for 1.5hrs. 
3. At sunset, compare today’s date with a holiday date and determine if we are within a range, or the exact day of a holiday.  If so, run a light effect.  If not, just make sure the lights are OFF (they should be, but if the WLED reboots for any reason, they’ll come on)
    1. Example: If today’s date = Dec 31, run the New Year’s Eve preset at sunset.
    2. Example: If today’s date falls in the range of July 1 to July 7, run the 4th of July preset at sunset.
4. At 11:59pm, turn off the lights - even if the lights never came on.

### List of files to be used:
You need the files to be named with a dash or underscore.  This is because we re-write the crontab daily and have to re-write the entries with “WLED_” while the files with “WLED-“ are static. 
- WLED-sunset_sunrise.sh	
- WLED_weather_check.sh
- WLED_holiday_lights.sh
- WLED-LightsOff.sh	

Consider this crontab showing what the static and dynamic entries are:
```sh
00 05 * * * /Users/[username]/WLED-sunset_sunrise.sh  <- static entry, never changes
59 23 * * * /Users/[username]/WLED-LightsOff.sh   <- static entry, never changes
32 06 * * * /Users/[username]/WLED_weather_check.sh <-dynamic entry, changes daily
26 20 * * * /Users/[username]/WLED_holiday_lights.sh <-dynamic entry, changes daily
```
### Installation:
1. Place all files in your home directory: /Users/[your username]
2. If you don’t have one, create a user-level cron file.  If you already have a cron file, it should be okay because we only replace entries with “WLED_” in them. But maybe you should backup your existing crontab entries just in case.
    1. $ crontab -e
    2. At least add these 2 entries:
        ```sh 
        1. 00 05 * * * /Users/cmelvin/WLED-sunset_sunrise.sh
        2. 59 23 * * * /Users/cmelvin/WLED-LightsOff.sh
        ```
    4. ESC, :x to save and quit
3. In each script, replace [your username] with your actual username reflecting the full path of your User directory, without the brackets:  For example, `/Users/[your username]/` becomes `/Users/greg/`  By default, a logfile (WLED.log) is written to your desktop.  You can change this location here.  The user directory entires are only for the log file.  Please KEEP a log file somewhere, because there are 77 echo commands that want to be written.
4. In the weather and the sunrise scripts, change [airport code] to the closest airport to you, without the brackets.  For example, `wttr.in/[airport code]?1` becomes `wttr.in/JFK?1`
5. Except for WLED-sunset_sunrise.sh, the remaining 3 scripts have a curl command that uses the IP address of the ESP32 module (your WLED box).  You need to just search for x.x.x.x and replace with your own IP address.
6.  THE HARD PART: In the file WLED_holiday_lights.sh, you need to replace every PRESET variable to match your own PRESET for a WLED effect.  This can be either a preset or playlist number.  These replacements begin under the line `“Set a WLED Preset variable based on holidays and how long I want them to run”`.  I've also uploaded an ASCII table of all of my holiday settings for you to use.  In reallity, I got most off of reddit, stuck it all together, and changed the speeds to my liking for my length of lights
7. `$ chmod +x WLED*`

### MacOS Permissions:
I went overboard (and I don't need to be reminded how "dangerous" it is to grant bash FDA), but in System Settings > Privacy and Security > Full Disk Access, these items all have full disk access (I think only terminal and cron need it though)
- bash
- cron
- curl
- terminal
- zsh
- WLED-sunset_sunrise.sh	
- WLED_weather_check.sh
- WLED_holiday_lights.sh
- WLED-LightsOff.sh

Terminal is easy to add the normal way, but for the others,  use “which” and drag/drop the executable from Finder into the Full Disk Access area.  For example:
```sh
$ which cron
/usr/sbin/cron
```
Finder > Go > Go To Folder > /usr/sbin
Look for “cron”
Drag it to Full Disk Access 

Repeat for the other executables or files.  The WLED files can just be dragged from Finder.

### FAC (Frequently Asked Comments)
C: You know this exact thing exists [here]<br>
A: No, I didn’t.  Again, I’m famous for reinventing the wheel.

C: printf() is the standard for writing to log files, not echo. <br>
A: I know. I just didn’t feel like dealing with formatting to account for dashes and percents signs   

C: The code is sloppy / you rely too much on IF statements / some of your IFs are not used properly / there are easier ways of checking what you’re doing.<br>
A: I know. It’s the result of intermittent testing to see how I was progressing. Once I was done, I didn’t care enough to clean it up and make the scripts tighter. 

C: bash is not the most efficient way to do this.  You should have used something like python<br>
A: Sounds like a great project for you to do… go for it!  ChatGPT could probably spit out Python code if you pasted in the scripts.

### FAQ
Q: Can you add / alter this feature?  <br>
A: The scripts are as-is. Feel free to pull to your repository, download, change, sell it. I won't be making any more additions here.

Q: Will this work with GoVee Lights? <br>
A: I think it can.  The meat of the project is figuring out the holidays.  With GoVee you need an API key, and I think you make similar POST calls with curl.  I don't see why this could not be repurposed.

Q: Will this work on another OS besides MacOS?<br>
A: Maybe linux?  I’m sure there’s something goofy about Mac vs Linux where one OS likes a single backtick vs a quote, or no space after a bracket.  But they should be pretty simple to get through.

Q: Why are you using full paths everywhere?<br>
A: Because I’m a full path kind of guy.  It’s also more friendly with cron 






