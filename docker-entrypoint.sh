#!/bin/bash

if [ $# -eq 0 ]; then
    while :; do sleep 2073600; done
else
    "$@" &
fi

wait -n
