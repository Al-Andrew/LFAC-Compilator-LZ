#!/bin/bash

EXPECTED_PATH=./tests/expected
LATEST_PATH=./tests/latest
UNITS_PATH=./tests/units
UPDATE=0

if [ $# -eq 1 ]; then
    if [ "$1" = "update" ]; then
        echo "Updating expected results"
        UPDATE=1
    elif [ "$1" = "clean" ]; then
        rm -rf $EXPECTED_PATH/*
        rm -rf $LATEST_PATH/*
        exit 0
    else
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
    RES=$?
    echo "------------------" >> $OFP
    echo "code: $RES" >> $OFP
    echo "------------------" >> $OFP
    echo "functions: " >> $OFP
    if [ $RES -eq 0 ]; then
        cat Functions.txt >> $OFP
    fi
    echo "------------------" >> $OFP
    echo "variables: " >> $OFP
    if [ $RES -eq 0 ]; then
    cat Vars.txt >> $OFP
    fi
    echo "------------------" >> $OFP

    if [ $UPDATE -eq 1 ]; then
        cp $OFP $EFP
    fi

    diff $OFP $EFP > /dev/null
    if [ $? -ne 0 ]; then
        echo "Test $FILE failed"
        diff $OFP $EFP
    fi

    rm -rf Functions.txt Vars.txt
done