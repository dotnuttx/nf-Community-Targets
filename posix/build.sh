#!/bin/bash

# build version
export NF_VERSION="2.6.4.6"

export NF_VERSION_MAJOR=2
export NF_VERSION_MINOR=6
export NF_VERSION_BUILD=4
export NF_VERSION_REVISION=6

function linux_build () {
    clear

    # cleanup the build folder
    rm -rf build
    mkdir build
    cd build

    # build it
    if [ "$1" == "debug" ]; then
        cmake -D CMAKE_BUILD_TYPE=Debug ..
    else
        cmake -D CMAKE_BUILD_TYPE=Release ..
    fi

    make -j12
    if [ "$1" == "debug" ]; then
        cp dotnet-nf ../dotnet-nf.$NF_PLATFORM_TARGET.$(echo $NF_VERSION | sed 's/\.//g').debug
    else
        cp dotnet-nf ../dotnet-nf.$NF_PLATFORM_TARGET.$(echo $NF_VERSION | sed 's/\.//g')
    fi
}

function nuttx_build () {
    clear

    # cleanup the build folder
    make -C ../../../nuttx distclean -j12

    # config
    ../../../nuttx/tools/./configure.sh \
        -l \
        raspberrypi-pico:dotnetromfs

    # generate init script
    cd ../../../apps/nshlib/
    ../../nuttx/tools/./mkromfsimg.sh ../../nuttx/
    cd -

    # build
    if [ "$1" == "debug" ]; then
        make V=1 -C ../../../nuttx -j12 > build.log 2>&1
    else
        make -C ../../../nuttx -j12
    fi

    if [ "$NF_BOARD_TARGET" == "pi-pico" ]; then
        cp ../../../nuttx/nuttx.uf2 ./dotnet-nf.$NF_PLATFORM_TARGET.$(echo $NF_VERSION | sed 's/\.//g').uf2
    fi
}

if [ "$1" == "" ]; then
    echo "No target string specified!"

    # Target string table
    echo "wsl     ::  x86-64 Linux"
    echo "pi-zero ::  arm32v6 Linux (Raspberry Pi Zero)"
    echo "pi-pico ::  rp2040 Nuttx (Raspberry Pi Pico)"

    exit
else
    if [ "$1" == "wsl" ]; then
        export NF_PLATFORM_TARGET="x86-64-Linux"
        export NF_PLATFORM_TARGET_STRING="x86-64 Linux"
        export NF_BOARD_TARGET="wsl"
        export NF_BOARD_CONFIG="BOARD_WSL"
        linux_build $2
    fi
    
    if [ "$1" == "pi-zero" ]; then
        export NF_PLATFORM_TARGET="armel-Linux"
        export NF_PLATFORM_TARGET_STRING="arm32v6 Linux (Raspberry Pi Zero)"
        export NF_BOARD_TARGET="pi-zero"
        export NF_BOARD_CONFIG="BOARD_PI_ZERO"

        if [ "$2" == "podman-qemu" ]; then
            echo "To run torizon/binfmt we need super cow powers:"
            sudo podman run --rm -it --privileged torizon/binfmt

            # build from container
            podman \
                run \
                --rm \
                -it \
                -v ../../:/nf-interpreter \
                dotnuttx/builder:linux-arm32v6 \
                ./build.sh pi-zero

            exit
        fi

        linux_build $2
    fi

    if [ "$1" == "pi-pico" ]; then
        export NF_PLATFORM_TARGET="rp2040-Nuttx"
        export NF_PLATFORM_TARGET_STRING="rp2040 Nuttx (Raspberry Pi Pico)"
        export NF_BOARD_TARGET="pi-pico"
        export NF_BOARD_CONFIG="BOARD_PI_PICO"
        nuttx_build $2
    fi
fi
