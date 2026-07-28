@echo off
@rem Target of the "Launch DIALS environment" Start menu shortcut: opens a
@rem command window with the DIALS programs on PATH.  Also usable directly.
call "%~dp0setpaths.bat"
title DIALS environment
cmd /K
