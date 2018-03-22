#!/bin/bash

set -e
umask 0000

if [ -z "$*" ]; then
    tail -f /dev/null
else
    $@
fi

