#!/bin/sh

echo $1
BASE_ARGS='-XR -l1 -o time'

if [[ $1 ]]; then
	TOP_ARGS="$BASE_ARGS -U $1"
else
	TOP_ARGS=$BASE_ARGS
fi

top $TOP_ARGS | awk '{print $1 " - " $9 " - " $2 " - " $7}'