#!/bin/bash

if [ "$1" == "" ]; then
    echo "No target string specified!"

    # Target string table
    echo "wsl     ::  x86-64 Linux"
    echo "pi-zero ::  arm32v6 Linux (Raspberry Pi Zero)"

    exit
else
    if [ "$1" == "wsl" ]; then
        export NF_PLATFORM_TARGET="x86-64-Linux"
        export NF_BOARD_TARGET="wsl"
        export NF_BOARD_CONFIG="BOARD_PI_ZERO"
    fi
    
    if [ "$1" == "pi-zero" ]; then
        export NF_PLATFORM_TARGET="armel-Linux"
        export NF_BOARD_TARGET="pi-zero"
        export NF_BOARD_CONFIG="BOARD_PI_ZERO"
    fi
fi

# build version
export NF_VERSION="0.0.0.1"

clear

# cleanup the build folder
rm -rf build
mkdir build
cd build

# build it
if [ "$2" == "debug" ]; then
    cmake -D CMAKE_BUILD_TYPE=Debug ..
else
    cmake -D CMAKE_BUILD_TYPE=Release ..
fi

make -j12
