#!/bin/bash

umask 022
module load languages/anaconda3/
cd $SUBMIT_DIR
export PYTHONPATH=$HOME/lib/python3.7/site-packages
python wind.py
