#!/bin/bash
PROGRAM=${1}
ws=`otool -L ${PROGRAM} | grep libwebsockets.dylib \
    | sed -e "s/ (compatibility version 0.0.0, current version 0.0.0)//g"`
echo "change libwebsockets.dylib from build path ${ws} to run path ../lib/libwebsockets.dylib"
install_name_tool -change ${ws} ../lib/libwebsockets.dylib ${PROGRAM}