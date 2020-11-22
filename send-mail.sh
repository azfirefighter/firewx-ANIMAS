#!/bin/bash
logger "Emailing morning fire weather briefing."
echo -e "The Fire Weather Briefing for $(date) has been updated.\nRemember to view it at \
https://www.lltodd.family/firewx." | mail -s "Fire Weather Briefing" -r "weather-noreply@www.lltodd.family" weather-noreply@stdavidfire.com
