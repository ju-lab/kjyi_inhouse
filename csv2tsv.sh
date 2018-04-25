#!/bin/bash
sed -E 's/("([^"]*)")?,/\2\t/g' $1
