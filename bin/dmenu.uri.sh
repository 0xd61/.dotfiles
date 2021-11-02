#!/bin/sh
tac ~/.surf/history.txt | dmenu -l 10 -b | cut -d ' ' -f 3
