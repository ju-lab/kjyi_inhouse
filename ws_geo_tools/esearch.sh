#!/bin/bash
ssh -t 10.0.2.254 ssh 143.248.231.149 -p 2201 -t "/home/users/kjyi/tools/edirect/esearch $*" 2>/dev/null
