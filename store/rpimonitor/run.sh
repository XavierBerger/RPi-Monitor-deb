#!/bin/bash
LINE1="<b>RPi-Monitor</b> is correctly installed.\n"
LINE2="You can reach its web interface by browsing:\n"
LINE3=$(ip addr | perl -ne '/(\d+\.\d+\.\d+\.\d+)/ and  print "  - http://$1:8888/\\n"')
LINE4="Note: <b>RPi-Monitor</b> is a Web2.0 application requiring javascript.\n"
LINE5="It has successfly tested with Chrome and Firefox but is not compatible with Midori."
zenity --info --text="$LINE1$LINE2$LINE3$LINE4$LINE5"
