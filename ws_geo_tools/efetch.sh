#!/bin/bash
ssh 10.0.2.254 -t ssh 143.248.231.149 -p 2201 -t "/home/users/kjyi/tools/edirect/efetch $*" < /dev/stdin 2>/dev/null
