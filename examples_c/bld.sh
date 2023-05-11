#!/bin/bash
export SDIR=../source
gcc $1.c $SDIR/hb_ssh2.c -lssh2 -o $1 -I $SDIR
