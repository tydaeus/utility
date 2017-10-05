@Echo Off
setLocal enableDelayedExpansion
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: install
::
:: Provides simple installer utility, by using util scripts.
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

::-- Config Vars
set LOG_NAME="Installer Log"
set LOG_LOC=C:\temp\installer.log
set SCRIPT_FILE="install.cfg"

::-- Functional Vars
set ERRLEV=0
set ERRMSG=
set SCRIPT_DIR=%~dp0

::-----------------------------------------------------------------------------
:: setup the path to util scripts
::
:: precedence:
::  1. in script's dir
::  2. in script's \util subdir
::  3. in script's parent dir's \util subdir
::  4. at CMD_UTIL_HOME
::-----------------------------------------------------------------------------
if not "%CMD_UTIL_HOME%"=="" set PATH=%CMD_UTIL_HOME%;%PATH%
set PATH=%SCRIPT_DIR%;%SCRIPT_DIR%util\;%SCRIPT_DIR%..\util\;%PATH%
call init_log "%LOG_LOC%" "%LOG_NAME%"

call :RUN_FILE || goto :ERR

goto :SUCCESS

:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:ERR
if "%ERRMSG%"=="" set ERRMSG=unknown error occurred
if "%ERRLEV%"=="0" set ERRLEV=1
echo %ERRMSG% 1>&2
goto :END

:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:SUCCESS
echo Install complete.
goto :END

:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:END
call end_log
endLocal & set ERRLEV=%ERRLEV% & set ERRMSG=%ERRMSG%

if not "%ERRMSG%"=="" echo %ERRMSG% 1>&2
exit /b %ERRLEV%

:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: RUN_FILE
:: Read and execute provided install.cfg
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:RUN_FILE
:: use a sentinel file to detect success/failure, due to pipe limitations
set "SENTINEL=%SCRIPT_DIR%.failed.%COMPUTERNAME%.tmp"
echo > "%SENTINEL%"

2>&1 (call interpret_file "%SCRIPT_DIR%%SCRIPT_FILE%" && del "%SENTINEL%") | call log

if exist "%SENTINEL%" (
    set ERRLEV=1
    del "%SENTINEL%"
)

exit /b %ERRLEV%