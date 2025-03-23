#!/bin/sh
set -e

touch /mosquitto/config/passwd
chmod 0700 /mosquitto/config/passwd
mosquitto_passwd -b /mosquitto/config/passwd $USERNAME $PASSWORD

chown mosquitto:mosquitto /mosquitto/config/passwd
/usr/sbin/mosquitto -c /mosquitto/config/mosquitto.conf