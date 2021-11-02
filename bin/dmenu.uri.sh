#!/bin/sh
tac ~/.surf/history.txt | dmenu -l 10 -b -i | cut -d ' ' -f 3
