#!/bin/sh -eux

rm -f /run/pcscd/pcscd.comm >/dev/null 2>&1

pcscd -f -e &
mirakc
