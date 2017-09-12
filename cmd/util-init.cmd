@ECHO off
:: Adds the folder containing this script to the path, if not already present.
:: Assumes the instring utility script is available.
setLocal EnableDelayedExpansion

set UTIL_DIR=%~dp0
set EXPORT_PATH=%PATH%

:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: Add the utility folder to the path, if not already present
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
call "%~dp0"instring "%PATH%" "%~dp0"

if "%RET%"=="0" (
    echo adding utility scripts to path
    set "EXPORT_PATH=%UTIL_DIR%;%PATH%"
)

endLocal & set PATH=%EXPORT_PATH%