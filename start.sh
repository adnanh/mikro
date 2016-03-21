#!/bin/sh
if [ -z "$1" ]
then
    PORT=8800
else
    PORT=$1
fi

RACK_ENV=production nohup ruby mikro.rb -p $PORT > mikro.log 2>&1 &