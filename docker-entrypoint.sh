#!/bin/bash

set -e

if [ -z "$@" ]; then
    tail -f /dev/null
else
    echo "$@"
    PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin $@
fi

