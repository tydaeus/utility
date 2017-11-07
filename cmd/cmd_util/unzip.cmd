@echo off
setLocal enableDelayedExpansion

goto :INIT
::-----USAGE-------------------------------------------------------------------
:DISPLAY_USAGE_MESSAGE
echo: Usage:
echo:   %SCRIPT_NAME% [-n] [--no-clobber] ZIP_FILE DESTINATION_FILE
exit /b

:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: unzip
::
:: Wraps 7zip's unzip functionality for easier use in scripting.
::
:: Flags:
::      -n, --no-clobber
::          if DESTINATION_FILE already exists, skip unzipping
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::-----INIT--------------------------------------------------------------------
:INIT
set SCRIPT_NAME=%~n0
set ERRLEV=0
set USAGE_ERR=0

set NO_CLOBBER=0
set ZIP_FILE=
set DESTINATION_FILE=

::-----Dependency Check
call find_on_path "7z.exe"

if not defined RET (
    echo:ERR: unzip: 7-zip not found 1>&2
    goto :ERR
)

::-----Process Parameters
call split_flags %*

call :PROCESS_ARGS %ARGS%
call :PROCESS_SIMPLE_FLAGS
call :PROCESS_LONG_FLAGS %LONG_FLAGS%

if [%USAGE_ERR%]==[1] (
    echo:ERR: Invalid usage 1>&2
    call :DISPLAY_USAGE_MESSAGE
    goto :ERR
)

::-----Verify Target
if exist "%ZIP_FILE%" goto :VERIFY_DEST

echo:ERR: %SCRIPT_NAME%: unable to unzip %ZIP_FILE%, file does not exist 1>&2
goto :ERR


::-----Verify Destination
:VERIFY_DEST
:: Always copy if no preexisting DESTINATION_FILE
if not exist "%DESTINATION_FILE%" goto :UNZIP_FILE
:: Overwrite if no-clobber is off
if not "%NO_CLOBBER%"=="1" goto :UNZIP_FILE
:: DESTINATION_FILE exists and no-clobber is on; skip unzip
echo:Unzip target %DESTINATION_FILE% already exists, unzip skipped
goto :END

:UNZIP_FILE
7z x "%ZIP_FILE%" -o"%DESTINATION_FILE%" 1>nul || goto :ERR

goto :END

:ERR
if "%ERRLEV%"=="0" set ERRLEV=1
goto :END

:END
endLocal & set "ERRLEV=%ERRLEV%"
exit /b %ERRLEV%

:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: PROCESS_ARGS
::
:: Process script parameters to initialize corresponding variables.
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:PROCESS_ARGS

set "ZIP_FILE=%~1"
if not defined ZIP_FILE set USAGE_ERR=1
shift

set "DESTINATION_FILE=%~1"
if not defined DESTINATION_FILE set USAGE_ERR=1
shift

:: too many args
setLocal
set "ARG=%~1"
if defined ARG set USAGE_ERR=1
endLocal & set "USAGE_ERR=%USAGE_ERR%"

:END_PROCESS_ARGS
exit /b

:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: PROCESS_SIMPLE_FLAGS
::
:: Examines SIMPLE_FLAGS to determine appropriate response
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:PROCESS_SIMPLE_FLAGS

::-----
:WHILE_SIMPLE_FLAGS
:: no flags remain
if not defined SIMPLE_FLAGS goto :END_PROCESS_SIMPLE_FLAGS
:: get first char from SIMPLE_FLAGS as CUR_FLAG
set "CUR_FLAG=%SIMPLE_FLAGS:~0,1%"
:: remove first char from SIMPLE_FLAGS
set "SIMPLE_FLAGS=%SIMPLE_FLAGS:~1%"

if "%CUR_FLAG%"=="n" (
    set NO_CLOBBER=1
    goto :WHILE_SIMPLE_FLAGS
)
::-----

:: unrecognized char
echo:unrecognized char in SIMPLE_FLAGS: %CUR_FLAG%
set USAGE_ERR=1

:END_PROCESS_SIMPLE_FLAGS
exit /b


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: PROCESS_LONG_FLAGS
::
:: Iterates through the set of long flags to determine appropriate config
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:PROCESS_LONG_FLAGS

:WHILE_LONG_FLAG
set "CUR_FLAG=%~1"
if not defined CUR_FLAG goto :END_PROCESS_LONG_FLAGS
call :PROCESS_LONG_FLAG "%CUR_FLAG%"
shift
goto :WHILE_LONG_FLAG

:END_PROCESS_LONG_FLAGS
exit /b

:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: PROCESS_LONG_FLAG
::
:: Checks a single long flag to determine appropriate config
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:PROCESS_LONG_FLAG
set "FLAG=%~1"

if ["%FLAG%"]==["no-clobber"] (
    set NO_CLOBBER=1
    exit /b
)

set USAGE_ERR=1
exit /b