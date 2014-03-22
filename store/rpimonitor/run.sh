#!/bin/bash
LINE1="<b>RPi-Monitor</b> is correctly installed.\n"
LINE2="You can reach its web interface by browsing:\n"
LINE3=$(ip addr | perl -ne '/(\d+\.\d+\.\d+\.\d+)/ and  print "  <a href=\"http://$1:8888/\">http://$1:8888/</a>\\n"')
#echo $LINE1
#echo $LINE2
#echo $LINE3
zenity --info --text="$LINE1$LINE2$LINE3"
