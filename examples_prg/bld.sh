#!/bin/bash
export SDIR=../source
export HB_INS=/home/alkresin/apps/harbour
export SYSTEM_LIBS="-lm -lssh2"
export HARBOUR_LIBS="-lhbdebug -lhbvm -lhbrtl -lgttrm -lhblang -lhbrdd -lhbmacro -lhbpp -lrddntx -lrddcdx -lrddfpt -lhbsix -lhbcommon -lhbcpage"

$HB_INS/bin/linux/gcc/harbour $1 -n -i$HB_INS/include -w2 2>bldh.log
gcc $1.c $SDIR/hb_ssh2.c -o$1 -D_USE_HB -I $HB_INS/include -I $SDIR -L $HB_INS/lib/linux/gcc $SYSTEM_LIBS -Wl,--start-group $HARBOUR_LIBS -Wl,--end-group  >bld.log 2>bld.log
rm $1.c
