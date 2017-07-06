#!/usr/bin/env bash

function usage ()
{
    echo ${0} influx_url influx_db url name
    exit 1
}

if [ ${#} -ne 4 ]; then
    usage
fi

INFLUXURL=${1}
INFLUXDB=${2}
URL=${3}
NAME=${4}

HASH=$(echo ${0} ${URL}|sha256sum|awk '{print $1}')
TMPFILE=/tmp/.${HASH}
TS=$(date +%s%N)

curl -X GET ${URL} \
     -s \
     -w "\
curl_timing.namelookup,curl_timing_name=${NAME},curl_timing_host=${HOSTNAME} value=%{time_namelookup} ${TS}
curl_timing.connect,curl_timing_name=${NAME},curl_timing_host=${HOSTNAME} value=%{time_connect} ${TS}
curl_timing.appconnect,curl_timing_name=${NAME},curl_timing_host=${HOSTNAME} value=%{time_appconnect} ${TS}
curl_timing.pretransfer,curl_timing_name=${NAME},curl_timing_host=${HOSTNAME} value=%{time_pretransfer} ${TS}
curl_timing.redirect,curl_timing_name=${NAME},curl_timing_host=${HOSTNAME} value=%{time_redirect} ${TS}
curl_timing.starttransfer,curl_timing_name=${NAME},curl_timing_host=${HOSTNAME} value=%{time_starttransfer} ${TS}
curl_timing.total,curl_timing_name=${NAME},curl_timing_host=${HOSTNAME} value=%{time_total} ${TS}" \
     -o /dev/null > ${TMPFILE}

curl -i -XPOST "${INFLUXURL}/write?db=${INFLUXDB}" --data-binary "@${TMPFILE}"

rm -f ${TMPFILE}
