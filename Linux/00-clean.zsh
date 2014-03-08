#!/bin/zsh -f

setopt err_exit
setopt extendedglob

MYDIR="$(cd ${0:h} && pwd)"
cd $MYDIR

# Clean any generated files except the src directory
git clean -fdx --exclude=src

# clean up all git repositories
for gd in src/*/.git(N:h); (
    cd $gd && git clean -fdx
)

# clean up all subversion repositories
for sd in src/*/.svn(/N:h) src/*/*/.svn(/N:h); (
    cd $sd
    junkfiles=( ${(f)"$(svn status --no-ignore | grep '^[?I]' | cut -b9-)"} )
    rm -vrf $junkfiles
)
