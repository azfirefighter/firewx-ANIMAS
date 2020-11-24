#!/bin/bash
source ./config

logger "Emailing morning fire weather briefing."

echo -e "The Fire Weather Update for $(date) has been updated.\nRemember to view it at $url." | mail -s "Fire Weather Update" -r "$from" "$email"
