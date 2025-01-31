#!/use/bin/env sh
# This hook will look for code comments marked 'no-checkin'
#    - case-insensitive
#    - dash is optional
#    - can be prefixed with @
#
COUNT=$(git diff --no-ext-diff --cached --name-only -i -G"@?no-?checkin" | wc -l)
if [ "$COUNT" -ne "0" ]; then
   echo "WARNING: You are attempting to commit changes which include a 'no-checkin'."
   echo
   echo "Please check the following changes:"
   git diff --no-ext-diff --cached -U0 --exit-code -i -G"@?no-?checkin"
fi
