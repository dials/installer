@echo off
setlocal EnableDelayedExpansion

set "LOG=%PREFIX%\post_install.log"
echo ==== post_install.bat started %DATE% %TIME% ==== > "%LOG%"

rem ----------------------------------------------------------------------
rem Stage 1: Expose only the DIALS/xia2/dxtbx/cctbx dispatchers, mirroring
rem post.sh, so activating DIALS does not put all of conda_base on PATH.
rem ----------------------------------------------------------------------
echo [Stage 1] Creating dialsbin directory >> "%LOG%"
mkdir "%PREFIX%\dialsbin" 2>>"%LOG%"
if exist "%PREFIX%\dialsbin" (
    echo [Stage 1] dialsbin directory OK >> "%LOG%"
) else (
    echo [Stage 1] WARNING: dialsbin directory not created >> "%LOG%"
)

echo [Stage 1] Copying dispatchers >> "%LOG%"
for %%P in (dials xia2 dxtbx cctbx) do (
    copy /y "%PREFIX%\Scripts\%%P*.bat" "%PREFIX%\dialsbin\" >>"%LOG%" 2>&1
    copy /y "%PREFIX%\Scripts\%%P*.exe" "%PREFIX%\dialsbin\" >>"%LOG%" 2>&1
    copy /y "%PREFIX%\Scripts\%%P*-script.py" "%PREFIX%\dialsbin\" >>"%LOG%" 2>&1
)
echo [Stage 1] Dispatcher copy complete (missing patterns are expected and non-fatal) >> "%LOG%"

rem ----------------------------------------------------------------------
rem Stage 2: cmd activation script.
rem ----------------------------------------------------------------------
echo [Stage 2] Writing setpaths.bat >> "%LOG%"
(
    echo @set "PATH=%PREFIX%\dialsbin;%%PATH%%"
    rem If DIALS programs fail to find DLLs, also expose conda's core libs:
    rem echo @set "PATH=%PREFIX%\Library\bin;%%PATH%%"
) > "%PREFIX%\setpaths.bat" 2>>"%LOG%"
if exist "%PREFIX%\setpaths.bat" (
    echo [Stage 2] setpaths.bat OK >> "%LOG%"
) else (
    echo [Stage 2] WARNING: setpaths.bat not written >> "%LOG%"
)

rem ----------------------------------------------------------------------
rem Stage 3: PowerShell activation script.
rem ----------------------------------------------------------------------
echo [Stage 3] Writing setpaths.ps1 >> "%LOG%"
(
    echo $env:PATH = "%PREFIX%\dialsbin;$env:PATH"
    rem If DIALS programs fail to find DLLs, also expose conda's core libs:
    rem echo $env:PATH = "%PREFIX%\Library\bin;$env:PATH"
) > "%PREFIX%\setpaths.ps1" 2>>"%LOG%"
if exist "%PREFIX%\setpaths.ps1" (
    echo [Stage 3] setpaths.ps1 OK >> "%LOG%"
) else (
    echo [Stage 3] WARNING: setpaths.ps1 not written >> "%LOG%"
)

rem ----------------------------------------------------------------------
rem Stage 4: Launcher - open a command window with DIALS pre-loaded on PATH.
rem ----------------------------------------------------------------------
echo [Stage 4] Writing dials_env.bat >> "%LOG%"
(
    echo @echo off
    echo call "%PREFIX%\setpaths.bat"
    echo title DIALS environment
    echo cmd /K
) > "%PREFIX%\dials_env.bat" 2>>"%LOG%"
if exist "%PREFIX%\dials_env.bat" (
    echo [Stage 4] dials_env.bat OK >> "%LOG%"
) else (
    echo [Stage 4] WARNING: dials_env.bat not written >> "%LOG%"
)

rem ----------------------------------------------------------------------
rem Stage 5: Add a "Launch DIALS environment" entry to the (per-user) Start
rem menu. NOTE: this shortcut lives outside the install prefix, so the
rem uninstaller will not remove it automatically. For clean install/uninstall
rem integration, ship a menuinst Menu/dials.json in a conda package instead.
rem This stage is wrapped in try/catch and always exits 0 from PowerShell,
rem and its result is logged rather than allowed to fail the whole script -
rem a missing shortcut should never block installation.
rem Use the full path to powershell.exe: the installer's PATH is sanitized
rem and does not necessarily include %SystemRoot%\System32\WindowsPowerShell\v1.0.
rem ----------------------------------------------------------------------
echo [Stage 5] Creating Start Menu shortcut >> "%LOG%"
set "POWERSHELL_EXE=%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe"
if not exist "%POWERSHELL_EXE%" (
    echo [Stage 5] WARNING: %POWERSHELL_EXE% not found, trying 'powershell' on PATH >> "%LOG%"
    set "POWERSHELL_EXE=powershell"
)

"%POWERSHELL_EXE%" -NoProfile -Command ^
    "try {" ^
    "  $W = New-Object -ComObject WScript.Shell;" ^
    "  $Dir = Join-Path $W.SpecialFolders('Programs') 'DIALS';" ^
    "  [void](New-Item -ItemType Directory -Force -Path $Dir);" ^
    "  $S = $W.CreateShortcut((Join-Path $Dir 'Launch DIALS environment.lnk'));" ^
    "  $S.TargetPath = '%PREFIX%\dials_env.bat';" ^
    "  $S.IconLocation = 'dials_icon.ico';" ^
    "  $S.WorkingDirectory = $env:USERPROFILE;" ^
    "  $S.Save();" ^
    "  Write-Output 'Shortcut created successfully'" ^
    "} catch {" ^
    "  Write-Output \"Shortcut creation failed (non-fatal): $_\"" ^
    "}" ^
    "exit 0" >> "%LOG%" 2>&1

if exist "%APPDATA%\Microsoft\Windows\Start Menu\Programs\DIALS\Launch DIALS environment.lnk" (
    echo [Stage 5] Shortcut confirmed on disk >> "%LOG%"
) else (
    echo [Stage 5] WARNING: shortcut not found after creation attempt >> "%LOG%"
)

echo ==== post_install.bat finished %DATE% %TIME% ==== >> "%LOG%"

rem Always report success to the installer: every stage above is logged and
rem self-checked, and none of these steps (dispatcher exposure, activation
rem scripts, Start Menu shortcut) should be treated as fatal to setup.
exit /b 0
