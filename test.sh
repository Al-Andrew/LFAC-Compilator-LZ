#!/bin/bash

EXPECTED_PATH=./tests/expected
LATEST_PATH=./tests/latest
UNITS_PATH=./tests/units
UPDATE=0

if [ $# -eq 1 ]; then
    if [ "$1" = "update" ]; then
        echo "Updating expected results"
        UPDATE=1
    else if [ "$1" = "clean" ]; then
        rm -rf $EXPECTED_PATH/*
        rm -rf $LATEST_PATH/*
        exit 0
    fi
        echo "Command not recognized"
        exit 1
    fi
fi

for FILE in $UNITS_PATH/*; do
    OFP=$LATEST_PATH/"$(basename "$FILE")"".result"
    EFP=$EXPECTED_PATH/"$(basename "$FILE")"".result"

    echo "" > $OFP
    echo "------------------" >> $OFP
    echo "output: " >> $OFP
    ./build/LZ $FILE >> $OFP 2>&1
    echo "------------------" >> $OFP
    echo "functions: " >> $OFP
    cat Functions.txt >> $OFP
    echo "------------------" >> $OFP
    echo "variables: " >> $OFP
    cat Vars.txt >> $OFP
    echo "------------------" >> $OFP

    if [ $UPDATE -eq 1 ]; then
        cp $OFP $EFP
    fi

    diff $OFP $EFP > /dev/null
    if [ $? -ne 0 ]; then
        echo "Test $FILE failed"
        diff $OFP $EFP
    fi
done