#!/usr/bin/env bash
set -euo pipefail

BASE_URL="https://api.amplitude.com"
API_KEY="6a02da83cc930a6db40f27fe5731a42e"

USER_ID="ermenegildo.zegna@fakecompany.com"
USER_EMAIL="ermenegildo.zegna@fakecompany.com"

main() {
  # STEP 1: Uncomment this, run the script. Check Live Events.
  #send_analytics_event_with_just_user_id

  # STEP 2: Comment step 1, uncomment this, run again. Check Live Events.
  #send_analytics_event_with_user_id_and_mapped_field

  # STEP 3: Comment step 2, uncomment this, run again. Check Live Events.
  # Users should merge — click the user id, all three events should be displayed in the user's activity tab
  send_feedback_event_with_device_id
}

hash_device_id() {
  printf '%s' "$1" | iconv -f UTF-8 -t UTF-16LE | xxhsum -H128 | awk '{print $1}'
}

send_analytics_event_with_just_user_id() {
  echo "Sending analytics event with just user ID..."
  curl -s -X POST "$BASE_URL/2/httpapi" \
    -H "Content-Type: application/json" \
    -d "$(cat <<EOF
{
  "api_key": "$API_KEY",
  "events": [
    {
      "user_id": "$USER_ID",
      "event_type": "test"
    }
  ]
}
EOF
)"
  echo ""
}

send_analytics_event_with_user_id_and_mapped_field() {
  echo "Sending analytics event with user ID + user properties..."
  curl -s -X POST "$BASE_URL/2/httpapi" \
    -H "Content-Type: application/json" \
    -d "$(cat <<EOF
{
  "api_key": "$API_KEY",
  "events": [
    {
      "user_id": "$USER_ID",
      "event_type": "test with mapped field",
      "user_properties": {
        "email": "$USER_EMAIL",
        "Country": "United Kingdom",
        "role": "admin",
        "org_tier": "premium"
      }
    }
  ]
}
EOF
)"
  echo ""
}

send_feedback_event_with_device_id() {
  local device_id
  device_id=$(hash_device_id "$USER_EMAIL")
  echo "Sending feedback event with hashed device ID: $device_id"
  curl -s -X POST "$BASE_URL/2/httpapi" \
    -H "Content-Type: application/json" \
    -d "$(cat <<EOF
{
  "api_key": "$API_KEY",
  "events": [
    {
      "device_id": "$device_id",
      "event_type": "[AI Feedback] Feedback",
      "event_properties": {
        "feedback_source": "freshdesk",
        "feedback_source_id": 1500165,
        "feedback_source_name": "Freshdesk",
        "feedback_source_type": "FRESHDESK",
        "feedback_text": "I have been trying to get Feedback to work for a while now, but this does not map to users as described in the documentation. This is rather disappointing thus far."
      }
    }
  ]
}
EOF
)"
  echo ""
}

main
