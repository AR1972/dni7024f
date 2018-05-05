#!/bin/sh
rm -fr root
mkdir root
cd root
zcat ../orig/root.cpio.gz | cpio -i -d -H newc --no-absolute-filenames
cd ../
rm -fr application
mkdir application
cd application 
tar -xvzf ../orig/switchdrvr.tgz 
cd ../
