#! /bin/bash

PROBE_RATE=5
RETENTION_PERIOD=30
TEMPERATURE_LOG_PATH=/var/log/temperature
TEMPERATURE_LOG_FILE_NAME=cpu_temp

mkdir -p $TEMPERATURE_LOG_PATH



# Convert Kernal reported CPU temp from millidegree Celsius to Degree Celsius (2 decimal place)
convert_temp()
{
echo $(printf %.2f $(echo "scale=2;(((10^2)*$1)+0.5)/(10^2)"/1000 | bc))
}

while true
do
    # Delete log files older than RETENTION_PERIOD.
    find $TEMPERATURE_LOG_PATH/* -mtime +$RETENTION_PERIOD -exec rm {} \;

    # Gets the CPU temp then converts the value to degrees celsius
    CPU_TEMP1=$(convert_temp $(cat /sys/class/thermal/thermal_zone0/temp))
    # Stores date & time in ISO6801 format
    TIMESTAMP=$(date +"%Y-%m-%dT%T.%3NZ")
    # Stores date for filename
    TEMPERATURE_LOG_FILE_DATE=$(date +"%Y%m%d")
    # Concatenates full logfile path
    TEMPERATURE_LOG_FILE="$TEMPERATURE_LOG_PATH/$TEMPERATURE_LOG_FILE_NAME-$TEMPERATURE_LOG_FILE_DATE"

    # Appends log line
    echo {\"@timestamp\":\"$TIMESTAMP\", \"host\":{\"temperature\":{\"cpu\": $CPU_TEMP1}}}>> $TEMPERATURE_LOG_FILE

    sleep $PROBE_RATE
done
