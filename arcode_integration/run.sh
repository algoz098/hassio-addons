#!/usr/bin/env bashio

REPO="local"
SLUG="arcode_integration"
NAME="${REPO}_${SLUG}"

ACCESS_TOKEN=$(bashio::config 'accessToken')
DEVICES=$(bashio::config 'devices')
DEVICES="[${DEVICES//$'\n'/,}]"
LENGTH=$(echo $DEVICES | jq length)

BASE_URL="https://smart-be.arcode.online"

function getDeviceData() {
  local ITEM=${1}
  local ID=$(bashio::jq $ITEM ".id")
  local PATH_TO_VALUE=$(bashio::jq $ITEM ".pathToValue")

  bashio::log.info "Getting data for $ID"

  local RESULT=$(curl -s -X GET \
    -H "Authorization: Bearer ${SUPERVISOR_TOKEN}" \
    -H "Content-Type: application/json" \
    http://supervisor/core/api/states/${ID})

  bashio::log.info "data for $ID retrived"
  echo $RESULT | jq ".${PATH_TO_VALUE}"
}

function mountPayload() {
  local ITEM=${1}
  local VALUE=${2}
  local FOR_MS_TIME=$(echo $ITEM | jq ".forMsTime")
  local ABOVE=$(echo $ITEM | jq ".above")
  local BELOW=$(echo $ITEM | jq ".below")
  bashio::log.info "Mounting payload"

  echo "{\"value\": $VALUE, \"meta\": {\"forMsTime\": $FOR_MS_TIME, \"above\": $ABOVE, \"below\": $BELOW }}"
}

function haLivecheck() {
  bashio::log.info "HA Livechecking"
  local URL="${BASE_URL}/ha-livecheck"
  bashio::log.info "${URL}"

  echo $(curl -s -X PATCH \
    -H "Authorization: Bearer ${ACCESS_TOKEN}" \
    -H "Content-Type: application/json" \
    -d "{}" \
    $URL)
}

function reportData() {
  local ITEM=${1}
  local PAYLOAD=${2}
  local REMOTE_ID=$(echo $ITEM | jq ".remoteId")
  local URL="${BASE_URL}/remote-entities/external/${REMOTE_ID//$'"'/}"

  bashio::log.info "Reporting data for $REMOTE_ID in $URL"
  bashio::log.info "payload $PAYLOAD"

  echo $(curl -s -X PATCH \
    -H "Authorization: Bearer ${ACCESS_TOKEN}" \
    -H "Content-Type: application/json" \
    -d "$PAYLOAD" \
    $URL)
}

haLivecheckResult=$(haLivecheck)
bashio::log.info "Result of HA Livecheck: ${haLivecheckResult}"
for ((i=0; i < $LENGTH; i++)); do
  echo " "
  echo "STARTING INDEX $i"
  ITEM=$(bashio::jq $DEVICES ".[$i]")
  VALUE=$(getDeviceData $ITEM)
  PAYLOAD=$(mountPayload $ITEM $VALUE)
  reportData $ITEM "$PAYLOAD"
  echo "------"
done
