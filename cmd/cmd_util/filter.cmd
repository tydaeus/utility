@Echo Off
setLocal enableDelayedExpansion

goto :INIT
::-----USAGE-------------------------------------------------------------------
:DISPLAY_USAGE_MESSAGE
echo: Usage:
echo:   %SCRIPT_NAME% [--match:"MATCH_PATTERN"] [--omit:"OMIT_PATTERN"] [FILE_PATH]
exit /b

:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: filter
::
:: Filters piped input and then outputs to standard output.
::
:: If --match is specified, only input that matches MATCH_PATTERN will be output.
:: If --omit is specified, only input that does not match OMIT_PATTERN will be 
:: output.
:: Both may be specified. If neither is specified, input will be output 
:: unmodified.
::
:: Empty lines will always be included. An empty line will be added to the end
:: of output, even if none is present on input, due to cmd limitations.
::
:: If FILE_PATH is specified, output will also be directed there, wiping any
:: existing file.
::
:: Note that this is an inherently flawed implementation due to the limits of
:: cmd scripting. 
::      Cmd special characters (^, &, !, %, |) may cause problems.
::
:: ##ERR: ERRMSG## will be output if an error occurs (and is successfully 
:: detected)
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

::-----INIT--------------------------------------------------------------------
:INIT
set SCRIPT_NAME=%~n0
set ERRLEV=0

set USAGE_ERR=0

set FILE_PATH=
set MATCH_PATTERN=
set OMIT_PATTERN=

call split_flags %*

call :PROCESS_ARGS %ARGS%
call :PROCESS_SIMPLE_FLAGS
call :PROCESS_LONG_FLAGS %LONG_FLAGS%

if [%USAGE_ERR%]==[1] (
    echo:ERR: Invalid usage 1>&2
    call :DISPLAY_USAGE_MESSAGE
    goto :ERR
)

call :CLEAR_FILE

call :START_PIPE || goto :ERR

goto :END

:ERR
echo:ERR
if "%ERRLEV%"=="0" set ERRLEV=1
goto :END

:END
endLocal & set ERRLEV=%ERRLEV%

exit /b %ERRLEV%

:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: CLEAR_FILE
::
:: Deletes the output file if it already exists
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:CLEAR_FILE

if not defined FILE_PATH exit /b 0
call smart_delete "%FILE_PATH%"

:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: START_PIPE
::
:: Runs the input filter pipe until the pipe is complete.
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:START_PIPE

for /F "tokens=*" %%A in ('findstr /n "^"') do (
    set "LINE=%%A"
    set PRESERVE_LINE=1
    set "LINE=!LINE:*:=!"
    call :CHECK_MATCH "!LINE!"
    call :CHECK_OMIT "!LINE!"
    call :OUTPUT_LINE "!LINE!"
)
exit /b %ERRORLEVEL%

:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: CHECK_MATCH
::
:: If a MATCH_PATTERN has been set, checks if %1 matches this pattern. If not,
:: sets PRESERVE_LINE to 0.
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:CHECK_MATCH
if not defined MATCH_PATTERN exit /b 0

setLocal enableDelayedExpansion

set "LINE=%~1"

if not defined LINE goto :END_CHECK_MATCH_LOCAL

call match "!LINE!" "!MATCH_PATTERN!" --output:RET
if not %RET%==1 set PRESERVE_LINE=0

:END_CHECK_MATCH_LOCAL
endLocal & set "PRESERVE_LINE=%PRESERVE_LINE%"

exit /b 0

:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: CHECK_OMIT
::
:: If a OMIT_PATTERN has been set, checks if %1 matches this pattern. If so,
:: sets PRESERVE_LINE to 0.
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:CHECK_OMIT
if not defined OMIT_PATTERN exit /b 0

setLocal enableDelayedExpansion

set "LINE=%~1"

if not defined LINE goto :END_CHECK_OMIT_LOCAL

call match "%~1" "!OMIT_PATTERN!" --output:RET
if not %RET%==0 set PRESERVE_LINE=0

:END_CHECK_OMIT_LOCAL
endLocal & set "PRESERVE_LINE=%PRESERVE_LINE%"

exit /b 0

:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: OUTPUT_LINE
::
:: If PRESERVE_LINE remains true, output the line to stdout, and, if defined,
:: to FILE_PATH
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:OUTPUT_LINE
if !PRESERVE_LINE!==0 exit /b 0
echo:%~1
if defined FILE_PATH echo:%~1>>"%FILE_PATH%"
exit /b 0

:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: PROCESS_ARGS
::
:: Process script parameters to initialize corresponding variables.
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:PROCESS_ARGS

set "FILE_PATH=%~1"
shift

:: no second arg currently supported
set "CUR_ARG=%~1"
if defined CUR_ARG (
    set USAGE_ERR=1
)
:END_PROCESS_ARGS
exit /b

:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: PROCESS_SIMPLE_FLAGS
::
:: Examines the contents of SIMPLE_FLAGS to determine appropriate response. We
:: trust split_flags to ensure no '"' exists in SIMPLE_FLAGS.
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:PROCESS_SIMPLE_FLAGS


::-----
:WHILE_SIMPLE_FLAGS
:: no flags remain
if not defined SIMPLE_FLAGS exit /b
:: get first char from SIMPLE_FLAGS as CUR_FLAG
set "CUR_FLAG=%SIMPLE_FLAGS:~0,1%"
:: remove first char from SIMPLE_FLAGS
set "SIMPLE_FLAGS=%SIMPLE_FLAGS:~1%"

::-----

:: no simple flags currently defined
set USAGE_ERR=1
:END_PROCESS_SIMPLE_FLAGS
exit /b

:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: PROCESS_LONG_FLAGS
::
:: Iterates through LONG_FLAGS to determine appropriate config
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

if "!FLAG:~0,6!"=="match:" (
    call :STRIP_QUOTES !FLAG:~6!
    set "MATCH_PATTERN=!RET!"
    exit /b
)

if "!FLAG:~0,5!"=="omit:" (
    call :STRIP_QUOTES !FLAG:~5!
    set "OMIT_PATTERN=!RET!"
    exit /b
)

set USAGE_ERR=1
exit /b

:STRIP_QUOTES
set "RET=%~1"
exit /b