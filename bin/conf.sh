#!/bin/bash

export REPO_HOME="${PWD}"

mkdir -p ${REPO_HOME}/src/conf
mkdir -p ${REPO_HOME}/src/out


export WIND="${REPO_HOME}/src/wind/gen_files"
export GRID="${REPO_HOME}/src/grid"
export CONF="${REPO_HOME}/src/conf"
export OUT="${REPO_HOME}/src/out"
export INPUTS="${REPO_HOME}/inputs"

make -C ${REPO_HOME}/src/tephra2/ -B

export BINARY="${REPO_HOME}/src/tephra2/tephra2_2020"
