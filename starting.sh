#!/bin/bash

DOMAIN="*:2222"
DIR="/mnt/240/workspace/geo_points"
APPNAME="geo"
SCRIPT="script/geo"

PID=`ps -aef | grep $APPNAME | grep -v grep | awk '{print $2}'`

startme() {
    if [ -n "$PID" ]
        then
            echo "Service already working"
        else
            cd $DIR
            echo "Starting $APPNAME daemon at $DOMAIN"
            perl /usr/local/bin/morbo $SCRIPT reload --listen http://$DOMAIN > /dev/null 2>&1 &
    fi
}

stopme() {
    if [ -n "$PID" ]
        then
            kill -9 $PID 
            echo "Service stoppped"
        else
            echo "Service not starting"
    fi
}

case "$1" in 
    start)   startme ;;
    stop)    stopme ;;
    restart) stopme; startme ;;
    *) echo "usage: $0 start|stop|restart" >&2
       exit 1
       ;;
esac

# 		perl /usr/local/bin/morbo script/geo reload --listen http://*:2222 > /dev/null 2>&1 &
