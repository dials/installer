# Activate DIALS for the current PowerShell session:  . .\setpaths.ps1
#
# Only dialsbin goes on PATH -- it holds a forwarder for every DIALS, xia2,
# dxtbx and cctbx command.  Each forwarder applies the full conda environment
# PATH to the process it launches, so the bundled environment stays out of this
# session while the programs themselves still resolve their DLLs and can spawn
# each other.
#
# $PSScriptRoot is this file's directory, so the installation can be moved.
$env:PATH = "$PSScriptRoot\dialsbin;$env:PATH"
