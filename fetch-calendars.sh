#!/bin/sh

# Calendar URLs
WEBCAL_URL="https://r.elvanto.eu/fullcalendar/753273ae-219b-4007-b86f-e794397cbbde/60a53343-8476-4ccd-8b1b-729f8ce7c5b8.ics"
TEAM_WEBCAL_URL="https://r.elvanto.eu/fullcalendar/7b489ca4-e465-4eb4-b6cd-492ad1178b12/acaf434d-c2c0-41da-8403-73b1e3fabf92.ics"

# Output directory
OUTPUT_DIR="/usr/share/nginx/html/data"
mkdir -p "$OUTPUT_DIR"

# Fetch main calendar
echo "Fetching main calendar..."
curl -s "$WEBCAL_URL" > "$OUTPUT_DIR/calendar.ics"

# Fetch team calendar
echo "Fetching team calendar..."
curl -s "$TEAM_WEBCAL_URL" > "$OUTPUT_DIR/team-calendar.ics"

# Create timestamp file
echo "{\"lastUpdated\": \"$(date -Iseconds)\"}" > "$OUTPUT_DIR/status.json"

echo "Calendars updated at $(date)"
