#!/bin/bash

# build version
export NF_VERSION="2.7.0.2"

export NF_VERSION_MAJOR=2
export NF_VERSION_MINOR=6
export NF_VERSION_BUILD=4
export NF_VERSION_REVISION=7

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
        cp dotnet-nf ../dotnet-nf.$NF_PLATFORM_TARGET.$NF_BOARD_TARGET.$(echo $NF_VERSION | sed 's/\.//g').debug
    else
        cp dotnet-nf ../dotnet-nf.$NF_PLATFORM_TARGET.$NF_BOARD_TARGET.$(echo $NF_VERSION | sed 's/\.//g')
    fi
}

function nuttx_build () {
    clear

    # cleanup the build folder
    make -C ../../../nuttx distclean -j12

    # config
    ../../../nuttx/tools/./configure.sh \
        -l \
        $1:dotnetromfs

    # generate init script
    cd ../../../apps/nshlib/
    ../../nuttx/tools/./mkromfsimg.sh ../../nuttx/
    cd -

    # build
    if [ "$2" == "debug" ]; then
        make V=1 -C ../../../nuttx -j12 > build.log 2>&1
    else
        make -C ../../../nuttx -j12
    fi

    if [ "$NF_BOARD_TARGET" == "pi-pico" ]; then
        cp ../../../nuttx/nuttx.uf2 ./dotnet-nf.$NF_PLATFORM_TARGET.$(echo $NF_VERSION | sed 's/\.//g').uf2
    fi

    if [ "$NF_BOARD_TARGET" == "esp32c3" ] || [ "$NF_BOARD_TARGET" == "portenta-h7" ]; then
        cp ../../../nuttx/nuttx.bin ./dotnet-nf.$NF_PLATFORM_TARGET.$(echo $NF_VERSION | sed 's/\.//g').bin
    fi
}

if [ "$1" == "" ]; then
    echo "No target string specified!"

    # Target string table
    echo "esp32c3   ::  esp32c3 Nuttx (ESP32-C3 Risc-V)"
    echo "jh7100    ::  riscv64 Linux (StarFive JH7100)"
    echo "nezha     ::  riscv64 Linux (Allwinner D1)"
    echo "pi-pico   ::  rp2040 Nuttx (Raspberry Pi Pico)"
    echo "pi-zero   ::  arm32v6 Linux (Raspberry Pi Zero)"
    echo "portenta  ::  portenta-h7 Nuttx (Arduino Portenta H7)"
    echo "wsl       ::  x86-64 Linux"

    exit
else
    if [ "$1" == "esp32c3" ]; then
        export NF_PLATFORM_TARGET="esp32c3-Nuttx"
        export NF_PLATFORM_TARGET_STRING="esp32c3 Nuttx (ESP32 Risc-V)"
        export NF_BOARD_TARGET="esp32c3"
        export NF_BOARD_CONFIG="BOARD_ESP32_C3"
        nuttx_build "esp32c3-devkit" $2
    fi

    if [ "$1" == "jh7100" ]; then
        export NF_PLATFORM_TARGET="riscv64-Linux"
        export NF_PLATFORM_TARGET_STRING="riscv-64 Linux (StarFive JH7100)"
        export NF_BOARD_TARGET="jh7100"
        export NF_BOARD_CONFIG="BOARD_JH7100"

        if [ "$2" == "container" ]; then
            echo "To run torizon/binfmt we need super cow powers:"
            sudo docker run --rm -it --privileged torizon/binfmt

            # build from container
            docker \
                run \
                --rm \
                -it \
                -v $(realpath ../../):/nf-interpreter \
                dotnuttx/builder:linux-riscv64 \
                ./build.sh jh7100

            exit
        fi

        linux_build $2
    fi

    if [ "$1" == "nezha" ]; then
        export NF_PLATFORM_TARGET="riscv64-Linux"
        export NF_PLATFORM_TARGET_STRING="riscv-64 Linux (Allwinner D1)"
        export NF_BOARD_TARGET="nezha"
        export NF_BOARD_CONFIG="BOARD_NEZHA"

        if [ "$2" == "container" ]; then
            echo "To run torizon/binfmt we need super cow powers:"
            sudo docker run --rm -it --privileged torizon/binfmt

            # build from container
            docker \
                run \
                --rm \
                -it \
                -v $(realpath ../../):/nf-interpreter \
                dotnuttx/builder:linux-riscv64 \
                ./build.sh nezha

            exit
        fi

        linux_build $2
    fi

    if [ "$1" == "pi-pico" ]; then
        export NF_PLATFORM_TARGET="rp2040-Nuttx"
        export NF_PLATFORM_TARGET_STRING="rp2040 Nuttx (Raspberry Pi Pico)"
        export NF_BOARD_TARGET="pi-pico"
        export NF_BOARD_CONFIG="BOARD_PI_PICO"
        nuttx_build "raspberrypi-pico" $2
    fi

    if [ "$1" == "pi-zero" ]; then
        export NF_PLATFORM_TARGET="armel-Linux"
        export NF_PLATFORM_TARGET_STRING="arm32v6 Linux (Raspberry Pi Zero)"
        export NF_BOARD_TARGET="pi-zero"
        export NF_BOARD_CONFIG="BOARD_PI_ZERO"

        if [ "$2" == "container" ]; then
            echo "To run torizon/binfmt we need super cow powers:"
            sudo docker run --rm -it --privileged torizon/binfmt

            # build from container
            docker \
                run \
                --rm \
                -it \
                -v $(realpath ../../):/nf-interpreter \
                dotnuttx/builder:linux-arm32v6 \
                ./build.sh pi-zero

            exit
        fi

        linux_build $2
    fi

    if [ "$1" == "portenta" ]; then
        export NF_PLATFORM_TARGET="portenta-Nuttx"
        export NF_PLATFORM_TARGET_STRING="portenta-h7 Nuttx (Arduino Portenta H7)"
        export NF_BOARD_TARGET="portenta-h7"
        export NF_BOARD_CONFIG="BOARD_ARDUINO_PORTENTA_H7"
        nuttx_build "portenta-h7" $2
    fi

    if [ "$1" == "wsl" ]; then
        export NF_PLATFORM_TARGET="x86-64-Linux"
        export NF_PLATFORM_TARGET_STRING="x86-64 Linux"
        export NF_BOARD_TARGET="wsl"
        export NF_BOARD_CONFIG="BOARD_WSL"
        linux_build $2
    fi
fi
