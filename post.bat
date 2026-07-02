@echo off
rem Expose only the DIALS/xia2/dxtbx/cctbx dispatchers, mirroring post.sh,
rem so activating DIALS does not put all of conda_base on PATH.

mkdir "%PREFIX%\dialsbin" 2>nul

for %%P in (dials xia2 dxtbx cctbx) do (
    copy /y "%PREFIX%\Scripts\%%P*.bat" "%PREFIX%\dialsbin\" >nul 2>&1
    copy /y "%PREFIX%\Scripts\%%P*.exe" "%PREFIX%\dialsbin\" >nul 2>&1
)

rem cmd:        run  setpaths.bat  to activate DIALS for the current session.
(
    echo @set "PATH=%PREFIX%\dialsbin;%%PATH%%"
    rem If DIALS programs fail to find DLLs, also expose conda's core libs:
    rem echo @set "PATH=%PREFIX%\Library\bin;%%PATH%%"
) > "%PREFIX%\setpaths.bat"

rem PowerShell: dot-source  . .\setpaths.ps1  to activate DIALS for the session.
(
    echo $env:PATH = "%PREFIX%\dialsbin;$env:PATH"
    rem If DIALS programs fail to find DLLs, also expose conda's core libs:
    rem echo $env:PATH = "%PREFIX%\Library\bin;$env:PATH"
) > "%PREFIX%\setpaths.ps1"

rem Launcher: open a command window with DIALS pre-loaded on PATH.
(
    echo @echo off
    echo call "%PREFIX%\setpaths.bat"
    echo title DIALS environment
    echo cmd /K
) > "%PREFIX%\dials_env.bat"

rem Add a "Launch DIALS environment" entry to the (per-user) Start menu.
rem NOTE: this shortcut lives outside the install prefix, so the uninstaller
rem will not remove it automatically. For clean install/uninstall integration,
rem ship a menuinst Menu/dials.json in a conda package instead.
powershell -NoProfile -Command ^
    "$W = New-Object -ComObject WScript.Shell;" ^
    "$Dir = Join-Path $W.SpecialFolders('Programs') 'DIALS';" ^
    "[void](New-Item -ItemType Directory -Force -Path $Dir);" ^
    "$S = $W.CreateShortcut((Join-Path $Dir 'Launch DIALS environment.lnk'));" ^
    "$S.TargetPath = '%PREFIX%\dials_env.bat';" ^
    "$S.WorkingDirectory = $env:USERPROFILE;" ^
    "$S.Save()" 2>nul
