#!/bin/sh


#+--------------------------------------------------------------------------------------------
#|Description:  This shell script used to download lzo,zlib,mtd-utils source code
#|              and cross compile it for ARM Linux, all is static cross compile.
#|     Author:  GuoWenxue <guowenxue@gmail.com>
#|  ChangeLog:
#|           1, Initialize 1.0.0 on 2011.04.12
#+--------------------------------------------------------------------------------------------

PRJ_PATH=`pwd`

LZO="lzo-2.04"
ZLIB="zlib-1.2.5"
e2fsprogs_ver=1.42
mtd="mtd-utils-1.4.9"

function decompress_packet()
(
    echo "+---------------------------------------------+"
    echo "|  Decompress $1 now"  
    echo "+---------------------------------------------+"
          
      ftype=`file "$1"`
      case "$ftype" in
          "$1: Zip archive"*)
              unzip "$1";;
          "$1: gzip compressed"*)
              if [ `expr "$1" : ".*.tar.*" ` ] ; then
                tar -xzf $1
            else
                gzip -d "$1"
            fi;;
          "$1: bzip2 compressed"*)
              if [ `expr "$1" : ".*.tar.*" ` ] ; then
                  tar -xjf $1
              else
                  bunzip2 "$1"
            fi;;
        "$1: POSIX tar archive"*)
            tar -xf "$1";;
        *)
            echo "$1 is unknow compress format";;
        esac
    )
#download lzo source code packet
if [ ! -s $LZO.tar.gz ] ; then
        wget http://www.oberhumer.com/opensource/lzo/download/$LZO.tar.gz
fi
#Decompress lzo source code packet
    if [ ! -d $LZO ] ; then
        decompress_packet $LZO.tar.*
    fi
#cross compile lzo
    cd $LZO
    if [ ! -s src/.libs/liblzo*.a ] ; then
        unset LDFLAGS
        ./configure --enable-static --disable-shared
        make
    fi
    
    cd -

    echo "+----------------------------------------+"
    echo "|  Cross compile $ZLIB now "  
    echo "| Crosstool:  $CROSS"
    echo "+----------------------------------------+"


#download zlib source code packet
    if [ ! -s $ZLIB.tar* ] ; then
        wget http://pkgs.fedoraproject.org/repo/pkgs/zlib/zlib-1.2.5.tar.bz2/be1e89810e66150f5b0327984d8625a0/$ZLIB.tar.bz2
    fi

#Decompress zlib source code packet
    if [ ! -d $ZLIB ] ; then
        decompress_packet $ZLIB.tar.*
    fi

#Cross compile zlib
    cd $ZLIB
    if [ ! -s libz.a ] ; then
        unset LDFLAGS
        ./configure  -static
        make
    fi
    cd -

    echo "+----------------------------------------+"
    echo "|  Cross compile e2fsprogsV$e2fsprogs_ver now "  
    echo "| Crosstool:  $CROSS"
    echo "+----------------------------------------+"

    if [ ! -s e2fsprogs-$e2fsprogs_ver.tar.gz ] ; then
        wget http://nchc.dl.sourceforge.net/project/e2fsprogs/e2fsprogs/$e2fsprogs_ver/e2fsprogs-$e2fsprogs_ver.tar.gz
    fi
#Decompress e2fsprogs source packet
    if [ ! -d e2fsprogs-$e2fsprogs_ver ] ; then
        decompress_packet e2fsprogs-$e2fsprogs_ver.tar.*
    fi

    cd e2fsprogs-$e2fsprogs_ver
    if [ ! -s lib/libuuid.a ] ; then
        ./configure --enable-elf-shlibs
        make
    fi

    cd -

    echo "+----------------------------------------+"
    echo "|  Cross compile mtd-utils now "  
    echo "| Crosstool:  $CROSS"
    echo "+----------------------------------------+"

    if [ ! -s ${mtd}.tar.bz2 ] ; then
        wget ftp://ftp.infradead.org/pub/mtd-utils/${mtd}.tar.bz2
    fi
    decompress_packet ${mtd}.tar.bz2

#download mtd-utils source code 
    cd ${mtd}
    line=`sed -n '/CFLAGS ?= -O2 -g/=' common.mk`
    if [ ! -z $line ] ; then
        sed -i -e ${line}s"|.*|CFLAGS ?= -O2 -g --static|"common.mk
    fi 

unset LDFLAGS
unset CFLAGS
set -x
export CFLAGS="-DWITHOUT_XATTR -I$PRJ_PATH/$ZLIB -I$PRJ_PATH/$LZO/include -I$PRJ_PATH/e2fsprogs-$e2fsprogs_ver/lib"
export ZLIBLDFLAGS=-L$PRJ_PATH/$ZLIB 
export LZOLDFLAGS=-L$PRJ_PATH/$LZO/src/.libs/
export LDFLAGS="-static -L $PRJ_PATH/e3fsprogs-$e2fsprogs_ver/lib $ZLIBLDFLAGS $LZOLDFLAGS"
make
set -x


