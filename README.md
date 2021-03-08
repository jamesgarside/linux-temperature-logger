# Linux Temperature logger
Linux system temperature logger compatible with Elastic.

This project allows a user to monitor the temperature of their Linux based system using Filebeat and Elasticsearch. 
A script reads the temperature of the CPU from the kernal and writes the output to a logfile in JSON format. Filebeat will then read that log file and ship the logs to Elasticsearch. 

## Tested Systems
This should work on most Linux systems however I've only tested on the following systems. If you are able to run ```cat /sys/class/thermal/thermal_zone1/temp``` and anything other than 0 is returned you should be good to go.
[ ] - CentOS 7 - AMD64
[x] - CentOS 7 - Raspberry Pi4 
[ ] - Ubuntu 18.04 - AMD64
[ ] - Ubuntu 18.04 - Raspberry Pi4
[ ] - Ubuntu 20.04 - AMD64
[ ] - Ubuntu 20.04 - Raspberry Pi4

## How it works
1. A Bash script runs in the background to collect the system temperature at a given interval and then writes it to a log file.
2. Filebeat reads the log file line by line and ships it to Elasticsearch.
3. Elasticsearch indexes the documents.

The temperature script writes logs as JSON structured entries, Filebeat then processes the JSON to extract key/value pairs, this mitigates the need for any further log processing i.e., Ingest Pipelines or Logstash.

Unfortunately Elastic Common Schema is yet to have a field mapping for system temperature (or any temperature at that), therefore a field is needed to be added to hold the system temp. To avoid adding any custom index templates the script formats the temperature logs in such a way that Elasticsearch will dynamically map the custom temperature field to a float. This allows mathematical operations and visualisations to be carried on the field contents such as line charts. 

By running the script as a service, it allows for easy management as it will automatically start with the system.

## Install
1. Copy the ```temp_logger.sh``` script to ```/opt/temp_logger/temp_logger.sh```
2. Copy ```temp_logger.service``` to ```/etc/systemd/system/temp_logger.sh```
3. Install Filebeat - https://www.elastic.co/guide/en/beats/filebeat/current/setup-repositories.html
4. Configure Filebeat. I have included a very basic Filebeat config in the resources folder.
5. Enable temp_logger service ```systemctl enable temp_logger.service```
6. Start temp_logger service ```systemctl start temp_logger.service```

## Script Variables
These variables reside in the ```temp_logger.sh``` script and control the behaviour of the script.
| Variable | Description |
| ----------- | ----------- |
| PROBE_RATE | Rate of which the temperature is recorded |
| RETENTION_PERIOD | How many days to retain log files for. Default=30 |
| TEMPERATURE_LOG_PATH | Path of where to store log files. Default=/var/log/temperature/ | 
| TEMPERATURE_LOG_FILE_NAME | Log file name. Default=cpu_temp | 
