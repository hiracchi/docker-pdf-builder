#!/bin/bash

set -e

if [ -z "$@" ]; then
    tail -f /dev/null
else
    $@
fi

