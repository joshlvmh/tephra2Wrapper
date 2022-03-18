#!/bin/bash

SCRIPT_DIR=$(dirname "${BASH_SOURCE[0]}")
cd $SCRIPT_DIR
cd ..

export REPO_HOME="${PWD}"

mkdir -p ${REPO_HOME}/src/conf
mkdir -p ${REPO_HOME}/src/out

export INPUTS="${REPO_HOME}/inputs"
# T2 inputs
export WIND="${REPO_HOME}/inputs/t2_inputs/wind"
export GRID="${REPO_HOME}/inputs/t2_inputs/grids"
export CONF="${REPO_HOME}/inputs/t2_inputs/conf"
export OUT="${REPO_HOME}/outputs/t2_out"

make -C ${REPO_HOME}/src/tephra2/ -B

export BINARY="${REPO_HOME}/src/tephra2/tephra2_2020"
export LD_LIBRARY_PATH=${LD_LIBRARY_PATH}:/mnt/storage/software/libraries/gnu/netcdf-4.7.3/lib/
