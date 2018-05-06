#!/bin/sh
mkimage -A PowerPC -O Linux -T multi -C gzip -a 0 -e 0 -n "FASTPATH System for dni85xx" -d orig/vmlinux.gz:root.cpio.gz:orig/shebang:application.tgz test.uboot
cat stk_header.bin test.uboot > test.stk
#rm test.uboot
