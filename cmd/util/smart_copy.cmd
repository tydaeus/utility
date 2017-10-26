@Echo Off
setLocal enableDelayedExpansion

goto :INIT
::-----USAGE-------------------------------------------------------------------
:DISPLAY_USAGE_MESSAGE
echo: Usage:
echo:   %SCRIPT_NAME% [-n] [--no-clobber] SRC DEST
exit /b

:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: smart_copy
::
::  Copies source to dest, automatically detecting whether src is a dir or
::  file and using the appropriate command.
::
::  Sets ERRLEV to reflect error code.
::
::  Options:
::		-n, --no-clobber
::			if a file/dir with the specified name already exists at DEST, 
::		    copying will be skipped
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::-----INIT--------------------------------------------------------------------
:INIT
set SCRIPT_NAME=%~n0
set ERRLEV=0
set USAGE_ERR=0

set NO_CLOBBER=0
set SRC=
set DEST=

call split_flags %*

call :PROCESS_ARGS %ARGS%
call :PROCESS_SIMPLE_FLAGS %SIMPLE_FLAGS%
call :PROCESS_LONG_FLAGS %LONG_FLAGS%

if [%USAGE_ERR%]==[1] (
	echo:ERR: Invalid usage 1>&2
	call :DISPLAY_USAGE_MESSAGE
	goto :ERR
)

if not exist "%SRC%" (
    set ERRLEV=1
    echo:ERR: smart_copy: failed to copy "%SRC%": does not exist 1>&2
    goto :END
)

:: TODO: test err detection
if exist "%SRC%"\* (
	call :COPY_DIR || goto :ERR
) else (
	call :COPY_FILE || goto :ERR
)
goto :END

:ERR
if "%ERRLEV%"=="0" set ERRLEV=1
echo:ERR: smart_copy: Failed to copy "%SRC%" to "%DEST%" 1>&2
goto :END

:END
endLocal & set ERRLEV=%ERRLEV%
exit /b %ERRLEV%

:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: PROCESS_ARGS
::
:: Process script parameters to initialize corresponding variables.
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:PROCESS_ARGS

if [%~1]==[] goto :END_PROCESS_ARGS
set "SRC=%~1"
shift

if [%~1]==[] goto :END_PROCESS_ARGS
set "DEST=%~1"
shift

:: too many args
if not [%~1]==[] set USAGE_ERR=1

:END_PROCESS_ARGS
if ["%SRC:"=%"]==[""] set USAGE_ERR=1
if ["%DEST:"=%"]==[""] set USAGE_ERR=1
exit /b

:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: PROCESS_SIMPLE_FLAGS
::
:: Examines the set of simple flags to determine appropriate response
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:PROCESS_SIMPLE_FLAGS

:: no flags
if "%*"=="" exit /b

:: check for invalid flags
call match --output:RET "%*" "[^n]"
if "%RET%"=="1" (
	set USAGE_ERR=1
	exit /b
)

:: check for help flags
call match --output:RET "%*" "n"
if "%RET%"=="1" (
	set NO_CLOBBER=1
)

exit /b

:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: PROCESS_LONG_FLAGS
::
:: Iterates through the set of long flags to determine appropriate config
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:PROCESS_LONG_FLAGS

:WHILE_LONG_FLAG
if ["%~1"]==[""] goto :END_PROCESS_LONG_FLAGS
call :PROCESS_LONG_FLAG "%~1"
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

:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: COPY_FILE
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:COPY_FILE
:: Always copy if no prexisting dest file
if not exist "%DEST%" goto :RUN_COPY_FILE
:: Overwrite if no-clobber is off
if not "%NO_CLOBBER%"=="1" goto :RUN_COPY_FILE
:: dest file exists and no-clobber is on; skip copy
echo:File %DEST% already exists
goto :END_COPY_FILE


:RUN_COPY_FILE
echo F | xcopy /Y "%SRC%" "%DEST%" > nul
set ERRLEV=%ERRORLEVEL%
goto :END_COPY_FILE

:END_COPY_FILE
exit /b %ERRLEV%

:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: COPY_DIR
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:COPY_DIR
:: Always copy if no prexisting dest dir
if not exist "%DEST%" goto :RUN_COPY_DIR
:: Overwrite if no-clobber is off
if not "%NO_CLOBBER%"=="1" goto :RUN_COPY_DIR
:: dest dir exists and no-clobber is on; skip copy
echo:Dir %DEST% already exists
goto :END_COPY_DIR

:RUN_COPY_DIR
echo D | xcopy /E /Y /Q "%SRC%" "%DEST%" > nul
set ERRLEV=%ERRORLEVEL%

:END_COPY_DIR
exit /b %ERRLEV%