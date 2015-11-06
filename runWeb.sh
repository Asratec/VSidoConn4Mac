#!/bin/bash
cd ./usr/share/WebServer && node ./WebServer.js >/dev/null&
cd ./usr/share/debug && node ./WebServer.js >/dev/null&
