#!/bin/sh
cat ~/.surf/history.txt > ~/.surf/history.txt.$$
cat ~/.surf/history.txt.$$ | sort | uniq >~/.surf/history.txt
rm -f ~/.surf/history.txt.$$
