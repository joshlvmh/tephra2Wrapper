#!/bin/bash

ls | grep -P "[0-9].txt" | xargs -d"\n" rm
