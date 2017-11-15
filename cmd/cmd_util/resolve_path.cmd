@Echo Off
setLocal enableDelayedExpansion

goto :INIT
::-----USAGE-------------------------------------------------------------------
:DISPLAY_USAGE_MESSAGE
echo: Usage:
echo:   %SCRIPT_NAME% BASE_PATH "PATTERN1"...
exit /b

:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: resolve_path
::
:: Attempts to find a viable file path starting in the dir at BASE_PATH 
:: followed by zero or more matching patterns (using findstr's "regex" 
:: support).
::
:: If a pattern resolves to more than one possible matching file, returns the
:: most recently modified file/dir matching the pattern. Uses get_latest_file
:: for this purpose.
::
:: Returns by outputting the final computed file path to stdout
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:INIT
set ERRLEV=0
set USAGE_ERR=0
set BASE_PATH=
set PATTERN=
set "SCRIPT_NAME=%~n0"

set "BASE_PATH=%~dpnx1"

if not defined BASE_PATH (
    echo:ERR: %SCRIPT_NAME%: invalid usage 1>&2
    call :DISPLAY_USAGE_MESSAGE
    goto :ERR
)

if not exist "!BASE_PATH!\*" (
    echo:ERR: %SCRIPT_NAME%: BASE_PATH '%BASE_PATH%' does not exist as dir1>&2
    goto :ERR
)

:WHILE_PATTERN
shift
set "PATTERN=%~1"
if not defined PATTERN goto :END_WHILE_PATTERN

call get_latest_file "!BASE_PATH!" "!PATTERN!" || goto :ERR
set "BASE_PATH=!RET!"
goto :WHILE_PATTERN

:END_WHILE_PATTERN

echo:!BASE_PATH!
goto :END

:ERR
set ERRLEV=1
echo:ERR: %SCRIPT_NAME% failed
goto :END

:END
endLocal & set ERRLEV=%ERRLEV%
exit /b %ERRLEV%