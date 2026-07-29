#!/bin/bash
# Target of the "Launch DIALS environment" desktop entry: opens an interactive
# shell with the DIALS programs on PATH.  Also usable directly.
#
# Note that the interactive shell reads the user's rc files afterwards.  Those
# normally append to PATH, so dialsbin stays in front, but an rc file that
# assigns PATH outright will win -- source setpaths.sh again if that happens.
here=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
. "${here}/setpaths.sh"
exec "${SHELL:-/bin/bash}" -i
