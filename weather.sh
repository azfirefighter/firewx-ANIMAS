#!/bin/sh
#
# Fire Weather Forecast for Animas, NM
#
# This script is licensed under the GPL 3.0 and may
# be modified and shared provided the original author
# is credited by leaving the footer.html as-is.
#

#########################################################################
#        This script requires the wxcast Python3 library.               #
# 1. Install by issuing "sudo pip3 install wxcast" on the command line. #
# 2. Set the wxcast variable to the path for wxcast.                    #
# 3. Set the dir variable to the directory this script and its files    #
#    are in.                                                            #
# 4. Set the webhome variable to the directory on your web server where #
#    the page will be accessed.                                         #
# 5. Use crontab -e to set the frequency the script will be ran.        #
#    It is recommended to run it at least every hour.                   #
# 6. Edit send-mail.sh to the correct email address.                    #
# 7. Use crontab -e to set when to send the email reminder.             #
#    I send it out once per day.                                        #
#########################################################################

source ./config
cd $dir
# Ugly-ass hack for the day of the week
day=$(date | head -c 3)

if [ $day = "Sun" ]; then
	export modday="SUNDAY"
elif [ $day = "Mon" ]; then
	export modday="MONDAY"
elif [ $day = "Tue" ]; then
	export modday="TUESDAY"
elif [ $day = "Wed" ]; then
	export modday="WEDNESDAY"
elif [ $day = "Thu" ]; then
	export modday="THURSDAY"
elif [ $day = "Fri" ]; then
	export modday="FRIDAY"
elif [ $day = "Sat" ]; then
	export modday="SATURDAY"
fi

# Get daily Southwest Area Fire Danger and other info from the SWCC
wget https://gacc.nifc.gov/swcc/predictive/intelligence/daily/UPLOAD_Files_toSWCC/F_01_50_Daily_Fire_Danger_DISPATCH.jpg -O /var/www/html/firewx-ANIMAS/FireDanger.jpg
wget https://gacc.nifc.gov/swcc/predictive/intelligence/daily/UPLOAD_Files_toSWCC/A_01_10_PREPAREDNESS_LEVEL.csv -O /var/www/html/firewx-ANIMAS/A_01_10_PREPAREDNESS_LEVEL.csv
wget https://gacc.nifc.gov/swcc/predictive/intelligence/daily/UPLOAD_Files_toSWCC/G_02_30_Daily_RX_NM_Website.csv -O /var/www/html/firewx-ANIMAS/Daily_RX_NM.csv
##########################################################

# REGULAR WATCHES / WARNINGS / ADVISORIES
$wxcast text EPZ AFD > afd-raw.txt
sed -n '/\.EPZ/,/&&/p' afd-raw.txt > wwa-raw.txt
sed -i '/TX\.\.\./,/$/d' wwa-raw.txt
sed -i '1d' wwa-raw.txt
sed -i '$d' wwa-raw.txt
sed -i '$d' wwa-raw.txt
sed -i 's/NM\.\.\.//' wwa-raw.txt
cp wwa-raw.txt wwa.txt
##########################################################

# Get the 7 day forecast for Animas
$wxcast forecast "Animas, NM" > 7dayfcast.txt
sed -i 's/\:/<b>\:<\/b>/' 7dayfcast.txt
sed -i 's/Today/<b>Today<\/b>/' 7dayfcast.txt
sed -i 's/Tonight/<b>Tonight<\/b>/' 7dayfcast.txt
sed -i 's/Tomorrow/<b>Tomorrow<\/b>/' 7dayfcast.txt
sed -i 's/This/<b>This<\/b>/' 7dayfcast.txt
sed -i 's/Thru/<b>Thru<\/b>/' 7dayfcast.txt
sed -i 's/Afternoon/<b>Afternoon<\/b>/' 7dayfcast.txt
sed -i 's/Evening/<b>Evening<\/b>/' 7dayfcast.txt
sed -i 's/Overnight/<b>Overnight<\/b>/' 7dayfcast.txt
sed -i 's/Day/<b>Day<\/b>/' 7dayfcast.txt
sed -i 's/Night/<b>Night<\/b>/' 7dayfcast.txt
sed -i 's/Eve/<b>Eve<\/b>/' 7dayfcast.txt
sed -i 's/Next/<b>Next<\/b>/' 7dayfcast.txt
sed -i 's/Weekend/<b>Weekend<\/b>/' 7dayfcast.txt
sed -i 's/Week/<b>Week<\/b>/' 7dayfcast.txt
sed -i 's/VeteransDay/<b>Veterans Day<\/b/' 7dayfcast.txt
sed -i 's/Memorial/<b>Memorial<\/b/' 7dayfcast.txt
sed -i 's/Labor/<b>Labor<\/b/' 7dayfcast.txt
sed -i 's/Columbus/<b>Columbus<\/b/' 7dayfcast.txt
sed -i 's/Presidents/<b>Presidents<\/b/' 7dayfcast.txt
sed -i 's/New Years/<b>New Years<\/b/' 7dayfcast.txt
sed -i 's/Independence/<b>Independence<\/b/' 7dayfcast.txt
sed -i 's/Inauguration/<b>Inauguration<\/b/' 7dayfcast.txt
sed -i 's/Valentines/<b>Valentines<\/b/' 7dayfcast.txt
sed -i 's/New Year/<b>New Year<\/b/' 7dayfcast.txt
sed -i 's/Halloween/<b>Halloween<\/b/' 7dayfcast.txt
sed -i 's/Easter/<b>Easter<\/b/' 7dayfcast.txt
sed -i 's/Thanksgiving Day/<b>Thanksgiving Day<\/b/' 7dayfcast.txt
sed -i 's/Christmas/<b>Christmas<\/b/' 7dayfcast.txt
sed -i 's/Monday/<br><b>Monday<\/b>/' 7dayfcast.txt
sed -i 's/Tuesday/<br><b>Tuesday<\/b>/' 7dayfcast.txt
sed -i 's/Wednesday/<br><b>Wednesday<\/b>/' 7dayfcast.txt
sed -i 's/Thursday/<br><b>Thursday<\/b>/' 7dayfcast.txt
sed -i 's/Friday/<br><b>Friday<\/b>/' 7dayfcast.txt
sed -i 's/Saturday/<br><b>Saturday<\/b>/' 7dayfcast.txt
sed -i 's/Sunday/<br><b>Sunday<\/b>/' 7dayfcast.txt
sed -i 's/$/<br>/' 7dayfcast.txt
##########################################################

# Get the area discussion
sed -n '/\.FIRE WEATHER\.\.\./,/&&/p' afd-raw.txt > afd.txt
sed -i '$d' afd.txt
sed -i '$d' afd.txt
sed -i 's/^$/<br><br>/' afd.txt
sed -i 's/\.FIRE WEATHER\.\.\.//' afd.txt
echo -e "<\/p>" >> afd.txt
##########################################################

# Pull out just the fire zone forecast
$wxcast text EPZ FWF > fwf-raw.txt
sed -n '/NMZ111/,/$$/p' fwf-raw.txt > fwf.txt
sed -i '/NMZ/,/2020/d' fwf.txt
sed -i '/.FORECAST DAYS 3 THROUGH 5.../,$d' fwf.txt
#sed -n '/\.Today\.\.\./,/$^/p' fwf.txt > zone111.txt
cp fwf.txt zone111.txt
sed -i '$d' zone111.txt
sed -i '$d' zone111.txt
sed -i 's/Today/<b>TODAY<\/b>/' zone111.txt
sed -i 's/TODAY/<b>TODAY<\/b>/' zone111.txt
sed -i 's/TONIGHT/<b>TONIGHT<\/b>/' zone111.txt
sed -i 's/NIGHT/<b>NIGHT<\/b>/' zone111.txt
sed -i 's/VETERANS DAY/<b>VETERANS DAY<\/b>/' zone111.txt
sed -i 's/MEMORIAL DAY/<b>MEMORIAL DAY<\/b>/' zone111.txt
sed -i 's/LABOR DAY/<b>LABOR DAY<\/b>/' zone111.txt
sed -i 's/COLUMBUS DAY/<b>COLUMBUS DAY<\/b>/' zone111.txt
sed -i 's/PRESIDENTS DAY/<b>PRESIDENTS DAY<\/b>/' zone111.txt
sed -i 's/NEW YEARS DAY/<b>NEW YEARS DAY<\/b>/' zone111.txt
sed -i 's/NEW YEAR/<b>NEW YEAR<\/b>/' zone111.txt
sed -i 's/INDEPENDENCE DAY/<b>INDEPENDENCE DAY<\/b>/' zone111.txt
sed -i 's/INAUGUARATION DAY/<b>INAUGURATION DAY<\/b>/' zone111.txt
sed -i 's/VALENTINE DAY/<b>VALENTINE DAY<\/b>/' zone111.txt
sed -i 's/HALLOWEEN/<b>HALLOWEEN<\/b>/' zone111.txt
sed -i 's/EASTER/<b>EASTER<\/b>/' zone111.txt
sed -i 's/THANKSGIVING DAY/<b>THANKSGIVING DAY<\/b>/' zone111.txt
sed -i 's/CHRISTMAS/<b>CHRISTMAS<\/b>/' zone111.txt
sed -i 's/SUNDAY/<b>SUNDAY<\/b>/' zone111.txt
sed -i 's/MONDAY/<b>MONDAY<\/b>/' zone111.txt
sed -i 's/TUESDAY/<b>TUESDAY<\/b>/' zone111.txt
sed -i 's/WEDNESDAY/<b>WEDNESDAY<\/b>/' zone111.txt
sed -i 's/THURSDAY/<b>THURSDAY<\/b>/' zone111.txt
sed -i 's/FRIDAY/<b>FRIDAY<\/b>/' zone111.txt
sed -i 's/SATURDAY/<b>SATURDAY<\/b>/' zone111.txt
#sed -i 's/.FORECAST DAYS 3 THROUGH 5.../<b>FORECAST DAYS 3 THROUGH 5<\/b>/' zone111.txt
sed -i 's/$/<br>/' zone111.txt
##########################################################

# Put it all together!
#
# Headers and Menu
cat header.html > DailyWeather.html
echo "<font color='yellow'>$(TZ='America/Phoenix' date)</font></h6>" >> DailyWeather.html

# Preparedness Levels
echo '<p id="prep"><div id="shadowbox"><b>WILDFIRE PREPAREDNESS LEVELS</b></br>' >> DailyWeather.html
cat  wildfire-prep.html >> DailyWeather.html
echo '</div></p>' >> DailyWeather.html

# Daily Prescribed Burns
echo '<p id="burns"><div id="shadowbox"><b>DAILY PRESCRIBED BURNS (STATEWIDE)</b></br>' >> DailyWeather.html
cat RX_Planned_NM.html >> DailyWeather.html
echo "</div></p>" >> DailyWeather.html

# SWCC Daily Southwest Area Fire Danger
echo '<p id="dngr"><div id="shadowbox"><b>SOUTHWEST AREA FIRE DANGER</b></br>' >> DailyWeather.html
echo '<a href="https://www.lltodd.family/firewx/FireDanger.jpg" target="_blank"><img src="https://www.lltodd.family/firewx/FireDanger.jpg" width="25%"></a></br>' >> DailyWeather.html
echo 'Click to enlarge.</div></p>' >> DailyWeather.html

# TWC WATCHES/WARNINGS/ADVISORIES
echo '<p id="wwa"><div id="shadowbox"><b>WATCHES/WARNINGS/ADVISORIES</b></br><blockquote>' >> DailyWeather.html
cat wwa.txt >> DailyWeather.html
echo "</blockquote></div></p>" >> DailyWeather.html

# 7-DAY FORECAST
echo '<p id="7day"><div id="shadowbox"><b>7-DAY FORECAST</b></br><blockquote>' >> DailyWeather.html
cat 7dayfcast.txt >> DailyWeather.html
echo "</blockquote></div></p>" >> DailyWeather.html

# AREA DISCUSSION
echo '<p id="awd"><div id="shadowbox"><b>AREA DISCUSSION</b></br><blockquote>' >> DailyWeather.html
cat afd.txt >> DailyWeather.html
echo "</blockquote></div></p>" >> DailyWeather.html

# ZONE 111 FORECAST
echo '<p id="zone"><div id="shadowbox"><b>ZONE 111 FORECAST</b></br><blockquote>' >> DailyWeather.html
cat zone111.txt >> DailyWeather.html
echo "</blockquote></div></p>" >> DailyWeather.html

#
# ADD THE FOOTER
cat footer.html >> DailyWeather.html

##########################################################

# Copy the report to a web page

cp DailyWeather.html $webhome/index.html
##########################################################


# Clean up the disk space
rm $dir/*.txt
