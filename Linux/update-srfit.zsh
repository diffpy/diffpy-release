#!/bin/zsh -f

cp -f ./buildtools/*.zsh .

./00-clean.zsh
./01-fetchsources.zsh
./02-buildall.zsh

rm -f 00-clean.zsh 01-fetchsources.zsh 02-buildall.zsh
