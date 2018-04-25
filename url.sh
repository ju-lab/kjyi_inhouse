#!/bin/bash
file=`readlink -f $1`
echo "The link below is copied to clipboard (X11 connection required)"
echo "First, login to 143.248.19.138:8001 and then see the file with your local browser with the link below"
echo "143.248.19.138:8001/file_show?path=$file"
echo "143.248.19.138:8001/file_show?path=$file" | xclip
