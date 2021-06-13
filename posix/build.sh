#!/bin/bash

clear

# cleanup the build folder
rm -rf build
mkdir build

# build it
cd build
cmake ..
make -j12
