#!/bin/bash
url="https://www.lltodd.family/firewx-ANIMAS"
email="jake@lltodd.family"
from="weather-noreply@www.lltodd.family"

logger "Emailing morning fire weather briefing."

echo -e "The Fire Weather Briefing for $(date) has been updated.\nRemember to view it at \
$url." | mail -s "Fire Weather Briefing" -r "$from" "$email"
