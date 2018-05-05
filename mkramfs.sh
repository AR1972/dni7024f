#!/bin/sh
cd root
find . | cpio -o -H newc | gzip --best > ../root.cpio.gz
cd ../
