@Echo Off
setLocal enableDelayedExpansion
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: install
::
:: Provides simple installer utility, by using util scripts.
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

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
endLocal & set ERRLEV=%ERRLEV% & set ERRMSG=%ERRMSG%

if not "%ERRMSG%"=="" echo %ERRMSG% 1>&2
exit /b %ERRLEV%

:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: RUN_FILE
:: Read and execute provided install.cfg
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:RUN_FILE
call interpret_file "%SCRIPT_DIR%install.cfg" 2>&1 | call log
exit /b %ERRLEV%