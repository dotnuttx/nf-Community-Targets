#!/bin/bash

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
