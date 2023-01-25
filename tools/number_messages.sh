#!/bin/bash

while read line; do n=$((++n)) &&  echo $line | sed -e 's/\(.*\)/\0 = '$(($n-1))'/' ; done
