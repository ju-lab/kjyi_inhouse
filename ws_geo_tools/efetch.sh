#!/bin/bash
ssh 143.248.231.149 -p 2030 -t "/home/users/kjyi/tools/edirect/efetch $*" < /dev/stdin 2>/dev/null
