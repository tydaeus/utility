@Echo off
setLocal enableDelayedExpansion

goto :INIT
::-----USAGE-------------------------------------------------------------------
:DISPLAY_USAGE_MESSAGE
echo: Usage:
echo:   %SCRIPT_NAME% [--startToken:START_TOKEN] FILE
exit /b

:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: interpret_file
::
:: Usage:
::      interpret_file FILE
:: 
:: Acts as a simplified script interpreter, thereby allowing the performance
:: of common sequences of steps from a config file instead of needing to write
:: custom cmd scripts.
::
:: On success, exits with ERRLEV and ERRORLEVEL set to 0.
:: On failure, exits after the first failed command with ERRLEV set to that 
:: command's exit code.
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

::-----INIT--------------------------------------------------------------------
:INIT
set SCRIPT_NAME=%~n0
set ERRLEV=0
set USAGE_ERR=0
set START_TOKEN=
set FILENAME=

call split_flags %*

call :PROCESS_ARGS %ARGS%
call :PROCESS_SIMPLE_FLAGS
call :PROCESS_LONG_FLAGS %LONG_FLAGS%

if "%USAGE_ERR%"=="1" (
    echo:ERR: Invalid usage 1>&2
    call :DISPLAY_USAGE_MESSAGE
    goto :ERR
)

if not exist "%FILENAME%" (
    echo:ERR: interpret_file: file not found: "%FILENAME%" 1>&2
    goto :ERR
)

if exist "%FILENAME%"\* (
    echo:ERR: interpret_file: unable to interpret dir "%FILENAME%" 1>&2
    goto :ERR
)

call :INTERPRET_FILE || goto :ERR
goto :END

:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: Ensure errors have some default handling, allowing for a simple jump for
:: error handling for default processing
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:ERR
if "%ERRLEV%"=="0" set ERRLEV=1
goto :END

:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:END
endLocal & set ERRLEV=%ERRLEV%
exit /b %ERRLEV%

:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: PROCESS_LONG_FLAGS
::
:: Changes run configuration based on content of command-line options (flags)
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

if ["%FLAG:~0,11%"]==["startToken:"] (
    set "START_TOKEN=%FLAG:~11%"
    exit /b
)

set USAGE_ERR=1
exit /b

:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: PROCESS_SIMPLE_FLAGS
::
:: Examines the content of SIMPLE_FLAGS to determine appropriate response
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:PROCESS_SIMPLE_FLAGS
:: no flags
if not defined SIMPLE_FLAGS exit /b

:: currently, no simple flags are supported
set USAGE_ERR=1
exit /b

:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: PROCESS_ARGS
::
:: Process script parameters to initialize corresponding variables. Currently,
:: we expect exactly 1 arg - FILENAME.
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:PROCESS_ARGS
if ["%~1"]==[""] (
    set USAGE_ERR=1
    exit /b
)

set "FILENAME=%~1"
shift

if not ["%~1"]==[""] (
    set USAGE_ERR=1
)

exit /b

:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: INTERPRET_FILE
::
:: File interpretation loop
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:INTERPRET_FILE
setLocal enableDelayedExpansion
set LINE=

set SCRIPT_STARTED=0
if "%START_TOKEN%"=="" set SCRIPT_STARTED=1

for /F "eol=# tokens=* usebackq" %%A in (`type "%FILENAME%"`) do (
    call :INTERPRET_LINE %%A || goto :INTERPRET_FILE_ERR
)
goto :INTERPRET_FILE_END

:INTERPRET_FILE_ERR
set ERRLEV=%ERRORLEVEL%
goto :INTERPRET_FILE_END

:INTERPRET_FILE_END
endLocal & set ERRLEV=%ERRLEV%
exit /b %ERRLEV%

:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: INTERPRET_LINE
::
:: File interpretation loop
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:INTERPRET_LINE

set "LINE=%*"

if not "%SCRIPT_STARTED%"=="1" goto :CHECK_FOR_START

:RUN_LINE
call interpret_cmd %LINE%
exit /b %ERRORLEVEL%

:CHECK_FOR_START
:: '"' confuses the compare op
set "LINE=!LINE:"=!"
::"
if ["%LINE%"]==["%START_TOKEN%"] set SCRIPT_STARTED=1
exit /b