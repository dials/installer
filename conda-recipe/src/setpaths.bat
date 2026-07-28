@rem Activate DIALS for the current cmd session:  setpaths.bat
@rem
@rem Only dialsbin goes on PATH -- it holds a forwarder for every DIALS, xia2,
@rem dxtbx and cctbx command.  Each forwarder applies the full conda environment
@rem PATH to the process it launches, so the bundled environment stays out of
@rem this shell while the programs themselves still resolve their DLLs and can
@rem spawn each other.
@rem
@rem %~dp0 is this file's directory, so the installation can be moved.
@set "PATH=%~dp0dialsbin;%PATH%"
