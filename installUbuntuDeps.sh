#!/usr/bin/env bash
CRTDIR=$(pwd)
BUILD_DIR=$CRTDIR/third_party

LIB_DIR=$BUILD_DIR/libdeps
PREFIX_DIR=$LIB_DIR/build/


check_sudo(){
  if [ -z `command -v sudo` ]; then
    echo 'sudo is not available, will install it.'
    apt-get update -y
    apt-get install sudo
  fi
}

parse_arguments(){
  while [ "$1" != "" ]; do
    case $1 in
      "--enable-gpl")
        ENABLE_GPL=true
        ;;
      "--cleanup")
        CLEANUP=true
        ;;
      "--fast")
        FAST_MAKE='-j4'
        ;;
    esac
    shift
  done
}

install_openssl(){
  if [ -d $LIB_DIR ]; then
    cd $LIB_DIR
	echo $LIB_DIR
    if [ ! -f ./openssl-1.1.1g.tar.gz ]; then
	#git clone https://github.com/openssl/openssl.git
	curl -OL https://www.openssl.org/source/openssl-1.1.1g.tar.gz
    fi
    if [ ! -f ./openssl-1.1.1g ]; then
    	tar -zxvf openssl-1.1.1g.tar.gz
    	cd openssl-1.1.1g
    	./config --prefix=$PREFIX_DIR --openssldir=$PREFIX_DIR -fPIC
    	make $FAST_MAKE -s V=0
    	make install_sw
	fi
    
    cd $CURRENT_DIR
  else
    mkdir -p $LIB_DIR
    install_openssl
  fi
}

install_opus(){
  [ -d $LIB_DIR ] || mkdir -p $LIB_DIR
  cd $LIB_DIR
  if [ ! -f ./opus-1.1.tar.gz ]; then
    curl -OL http://downloads.xiph.org/releases/opus/opus-1.1.tar.gz
  fi
  if [ ! -f ./opus-1.1 ]; then
    tar -zxvf opus-1.1.tar.gz
    cd opus-1.1
    ./configure --prefix=$PREFIX_DIR
    make $FAST_MAKE -s V=0
    make install
  else
    echo "opus already installed"
  fi
  cd $CURRENT_DIR
}

install_vpx(){
  [ -d $LIB_DIR ] || mkdir -p $LIB_DIR
  cd $LIB_DIR
  if [ ! -f ./libvpx-1.8.2.tar.gz ]; then
    #git clone https://gitee.com/rzkn/libvpx.git
    curl -OL https://github.com/webmproject/libvpx/archive/v1.8.2/libvpx-1.8.2.tar.gz
  fi
  if [ ! -f ./libvpx-1.8.2 ]; then
    tar -zxvf libvpx-1.8.2.tar.gz
    cd libvpx-1.8.2
    ./configure --prefix=$PREFIX_DIR --enable-shared --disable-static
    make $FAST_MAKE -s V=0
    make install
  else
    echo "vpx already installed"
  fi
  cd $CURRENT_DIR
}

install_x264(){
  [ -d $LIB_DIR ] || mkdir -p $LIB_DIR
  cd $LIB_DIR
  #if [ ! -f ./x264 ]; then
  #  git clone https://code.videolan.org/videolan/x264.git
  #fi
  if [ ! -f ./x264-snapshot-20180101-2245-stable.tar.bz2 ]; then
    curl -O -L http://download.videolan.org/pub/videolan/x264/snapshots/x264-snapshot-20180101-2245-stable.tar.bz2
  fi
  tar -xvf x264-snapshot-20180101-2245-stable.tar.bz2
  cd x264-snapshot-20180101-2245-stable
  ./configure --prefix=$PREFIX_DIR --disable-asm --enable-shared --enable-static
  make $FAST_MAKE -s V=0
  make install
  echo "x264 already installed"
  cd $CURRENT_DIR
}

install_mediadeps(){
  install_opus
  install_vpx
  install_x264
  echo "install_mediadeps"
  sudo apt-get -qq install yasm
  if [ -d $LIB_DIR ]; then
    cd $LIB_DIR
    #if [ ! -f ./v11.9.tar.gz ]; then
    #  curl -O -L https://github.com/libav/libav/archive/v11.9.tar.gz
	#fi

	if [ ! -f ./libav-11.9 ]; then
      tar -zxvf libav-11.9.tar.gz
      cd libav-11.9
      export PKG_CONFIG_PATH=${PREFIX_DIR}/lib/pkgconfig 
      ./configure --prefix=$PREFIX_DIR --extra-cflags="-I${PREFIX_DIR}/include" --extra-ldflags="-L${PREFIX_DIR}/lib" --bindir="${PREFIX_DIR}/bin" --enable-shared --enable-gpl --enable-libvpx --enable-libx264 --enable-libopus --disable-doc
      make $FAST_MAKE -s V=0
      make install
    else
      echo "libav already installed"
    fi
    cd $CURRENT_DIR
  else
    mkdir -p $LIB_DIR
    install_mediadeps
  fi

}

install_mediadeps_nogpl(){
  install_opus
  install_vpx
  echo "install_mediadeps_nogpl"
  sudo apt-get -qq install yasm
  if [ -d $LIB_DIR ]; then
    cd $LIB_DIR
    if [ ! -f ./v11.9.tar.gz ]; then
      curl -O -L https://github.com/libav/libav/archive/v11.9.tar.gz      
    fi

	#if [ ! -f ./libav-11.9 ]; then
		tar -zxvf libav-11.9.tar.gz
		cd libav-11.9
		export PKG_CONFIG_PATH=${PREFIX_DIR}/lib/pkgconfig
		./configure --prefix=$PREFIX_DIR  --extra-cflags="-I${PREFIX_DIR}/include" --extra-ldflags="-L${PREFIX_DIR}/lib" --bindir="${PREFIX_DIR}/bin" --enable-shared --enable-libvpx --enable-libopus --disable-doc
    	make $FAST_MAKE -s V=0
    	make install
	#else
    	echo "libav already installed"
	#fi

    cd $CURRENT_DIR
  else
    mkdir -p $LIB_DIR
    install_mediadeps_nogpl
  fi
}

install_libsrtp(){
  if [ -d $LIB_DIR ]; then
    cd $LIB_DIR
	if [ ! -f ./libsrtp-2.1.0.tar.gz ]; then
    	curl -o -L https://codeload.github.com/cisco/libsrtp/tar.gz/v2.1.0
	fi
	
	if [ ! -f ./libsrtp-2.1.0 ]; then
    	tar -zxvf libsrtp-2.1.0.tar.gz
    	cd libsrtp-2.1.0
    	CFLAGS="-fPIC" ./configure --enable-openssl --prefix=$PREFIX_DIR --with-openssl-dir=$PREFIX_DIR
    	make $FAST_MAKE -s V=0 && make uninstall && make install
	fi

    cd $CURRENT_DIR
  else
    mkdir -p $LIB_DIR
    install_libsrtp
  fi
}

cleanup(){
  if [ -d $LIB_DIR ]; then
    cd $LIB_DIR
    rm -r libsrtp*
    rm -r libav*
    rm -r v11*
    rm -r openssl*
    rm -r opus*
    cd $CURRENT_DIR
  fi
}

parse_arguments $*

mkdir -p $PREFIX_DIR

check_sudo
install_openssl
install_libsrtp

install_opus

install_mediadeps
#install_mediadeps_nogpl

if [ "$CLEANUP" = "true" ]; then
  echo "Cleaning up..."
  cleanup
fi

