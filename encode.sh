#!/bin/sh
IN=$1
OUT=$2
BIT_RATE=3000*1000

ffmpeg -i $IN -an -pass 1 -vcodec libx264 -vpre fastfirstpass \
-b $BIT_RATE -bt $BIT_RATE -threads 0 "$OUT" && \
ffmpeg -i $IN -y -acodec libfaac -ab 128k -pass 2 -vcodec libx264 \
-vpre hq -b $BIT_RATE -bt $BIT_RATE -threads 0 "$OUT"
