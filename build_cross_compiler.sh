#!/bin/sh

set -e
export TARGET=powerpc-linux-gnueabi
export PREFIX=$PWD/cross
export PATH=$PATH:$PREFIX/bin
rm -fr $PREFIX
mkdir $PREFIX
mkdir $PREFIX/etc
touch $PREFIX/etc/ld.so.conf
mkdir $PREFIX/$TARGET
mkdir $PREFIX/$TARGET/lib
touch $PREFIX/$TARGET/lib/crti.o
touch $PREFIX/$TARGET/lib/crtn.o
touch $PREFIX/$TARGET/lib/libc.so

rm -fr build_binutils
rm -fr build_gcc
rm -fr build_gdb
rm -fr build_gdbserver
rm -fr build_glibc
rm -fr binutils-2.17
rm -fr gdb-6.6
rm -fr glibc-2.5
rm -fr gcc-4.1.2

if [ ! -f binutils-2.17.tar.bz2 ]; then
	wget http://ftp.gnu.org/gnu/binutils/binutils-2.17.tar.bz2
fi

if [ ! -f gdb-6.6a.tar.bz2 ]; then
	wget http://ftp.gnu.org/gnu/gdb/gdb-6.6a.tar.bz2
fi

if [ ! -f glibc-2.5.tar.bz2 ]; then
	wget http://ftp.gnu.org/gnu/glibc/glibc-2.5.tar.bz2
fi

if [ ! -f gcc-4.1.2.tar.bz2 ]; then
	wget http://ftp.gnu.org/gnu/gcc/gcc-4.1.2/gcc-4.1.2.tar.bz2
fi

if [ ! -d linux ]; then
	git clone git://github.com/torvalds/linux.git
fi 

tar xjfv binutils-2.17.tar.bz2
tar xjfv gdb-6.6a.tar.bz2
tar xjfv glibc-2.5.tar.bz2
tar xjfv gcc-4.1.2.tar.bz2

cd linux
git checkout -f tags/v2.6.18
make ARCH=powerpc INSTALL_HDR_PATH=$PREFIX/$TARGET headers_install
cd ../

mkdir build_binutils
mkdir build_gcc
mkdir build_gdb
mkdir build_gdbserver
mkdir build_glibc

cd build_binutils
../binutils-2.17/configure \
		--target=$TARGET \
		--prefix=$PREFIX \
		--disable-multilib \
		--disable-nls
make -j2 all
make install
cd ..

cd build_gcc
../gcc-4.1.2/configure \
                --target=$TARGET \
                --prefix=$PREFIX \
                --enable-languages=c,c++ \
                --disable-multilib \
                --disable-nls \
                --disable-threads \
                --with-long-double-128
make -j2 all-gcc
make install-gcc
cd ..

cd build_glibc
../glibc-2.5/configure \
                --prefix=$PREFIX/$TARGET \
                --host=$TARGET \
                --target=$TARGET \
                --with-headers=$PREFIX/$TARGET/include \
                --disable-multilib \
                --enable-kernel=2.6.18 \
                --disable-nls \
                --disable-threads \
                libc_cv_forced_unwind=yes \
		libc_cv_c_cleanup=yes
make install-bootstrap-headers=yes install-headers
make -j2 csu/subdir_lib
install csu/crt1.o csu/crti.o csu/crtn.o $PREFIX/$TARGET/lib
$TARGET-gcc -nostdlib -nostartfiles -shared -x c /dev/null \
                -o $PREFIX/$TARGET/lib/libc.so
touch $PREFIX/$TARGET/include/gnu/stubs.h
cd ..

rm -fr build_gcc
mkdir build_gcc
cd build_gcc
../gcc-4.1.2/configure \
                --target=$TARGET \
                --prefix=$PREFIX \
                --enable-languages=c,c++ \
                --disable-multilib \
                --disable-nls \
                --with-long-double-128
make -j2 all-gcc
make install-gcc
cd ..

rm -fr build_glibc
mkdir build_glibc
cd build_glibc
../glibc-2.5/configure \
                --prefix=$PREFIX/$TARGET \
                --build=$MACHTYPE \
                --host=$TARGET \
                --target=$TARGET \
                --with-headers=$PREFIX/$TARGET/include \
                --disable-multilib \
                --enable-kernel=2.6.18 \
                --disable-nls \
		libc_cv_forced_unwind=yes \
                libc_cv_c_cleanup=yes
make -j2
make install
cd ..

cd build_gcc
make -j2
make install
cd ..

cd build_gdb
../gdb-6.6/configure \
			--target=$TARGET \
			--prefix=$PREFIX \
			--enable-sim-powerpc \
			--enable-sim-stdio
make -j2 all
make install
cd ..

cd build_gdbserver
../gdb-6.6/gdb/gdbserver/configure \
			--target=$TARGET \
			--host=$TARGET \
			--prefix=
make -j2 all
make DESTDIR=$PREFIX/target install
cd ..

rm -fr build_glibc
mkdir build_glibc
cd build_glibc
../glibc-2.5/configure \
                --prefix= \
                --build=$MACHTYPE \
                --host=$TARGET \
                --target=$TARGET \
                --with-headers=$PREFIX/$TARGET/include \
                --disable-multilib \
                --enable-kernel=2.6.18 \
                --disable-nls
make -j2 all
make install_root=$PREFIX/target install
cd ..
cp $PREFIX/$TARGET/lib/libgcc* $PREFIX/target/lib/
cp $PREFIX/$TARGET/lib/libstdc++* $PREFIX/target/lib/
cp $PREFIX/$TARGET/lib/libsupc++* $PREFIX/target/lib/





