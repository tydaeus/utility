@Echo Off
setLocal enableDelayedExpansion
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: init_simplescript
::
:: Provides initialization for a .cmd/DSL hybrid simplescript file.
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
set ERRLEV=0
set "SCRIPT_HOME=%~dp1"
set "SCRIPT_NAME=%~n1"
set "SCRIPT_FILE=%~dpnx1"
:: this will get populated by EXTEND_PATH
set "UTIL_HOME="
set "INIT_INVOCATION=%~0"

call :EXTEND_PATH "!%INIT_INVOCATION!"

:: provide calculated script vars' starting values
set "CMD[ScriptHome]=%SCRIPT_HOME%"
set "CMD[ScriptName]=%SCRIPT_NAME%"
set "CMD[UtilHome]=%UTIL_HOME%"
:: future development may pass root in from elsewhere
if "%CMD[Root]%"=="" set "CMD[Root]=C:\"

:: provide default config options
set "SCRIPT_CONFIG[OUTPUT_MODE]=DEFAULT"

call interpret_file "%SCRIPT_FILE%" --startToken:StartSimpleScript
set "ERRLEV=%ERRORLEVEL%"

if "%ERRLEV%"=="0" (
    echo script %SCRIPT_NAME% successful
) else (
    echo script %SCRIPT_NAME% failed with status %ERRLEV%
)

pause

:END
endLocal & set "ERRLEV=%ERRLEV%"
exit /b %ERRLEV%

:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: EXTEND_PATH
::
:: Determine where this script was called from, and set that as UTIL_HOME. If
:: this script is not on the path, add UTIL_HOME to the PATH so that other 
:: scripts in same location can be used from PATH.
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:EXTEND_PATH
set INVOKED_FROM_PATH=0

:: invocation includes path to init_simplescript, so use that as the home of
:: init_simplescript; otherwise we need to lookup init_simplescript from PATH
echo:dpnx1:%~dpnx1
if exist "%~dpnx1" (
    rem init invoked via full path
    set "UTIL_HOME=%~dp1"
) else (
    rem init invoked via path completion
    call :APPLY_EXTENSION "%~nx1"
    call :FIND_ON_PATH "!RET!"
    call :EXTRACT_PATH "!RET!"
    set "UTIL_HOME=!RET!"
    set INVOKED_FROM_PATH=1
)

if %INVOKED_FROM_PATH%==0 set "PATH=%UTIL_HOME%;%PATH%"
:: currently assume that cmd_util_ext is not on PATH; should check this in future
if exist "%UTIL_HOME%..\cmd_util_ext\" set "PATH=%UTIL_HOME%..\cmd_util_ext;%PATH%"
exit /b

:: conditionally apply .cmd extension in case invoked from path without extension
:APPLY_EXTENSION
set "RET=%~1"
if not "!RET:~-3!"=="cmd" set "RET=!RET!.cmd"
exit /b

:: inline of find_on_path.cmd
:FIND_ON_PATH
set "RET=%~$PATH:1"
if not exist "%RET%" set RET=
exit /b

:EXTRACT_PATH
set "RET=%~dp1"
exit /b