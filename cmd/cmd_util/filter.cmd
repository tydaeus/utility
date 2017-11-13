@Echo Off
setLocal enableDelayedExpansion

goto :INIT
::-----USAGE-------------------------------------------------------------------
:DISPLAY_USAGE_MESSAGE
echo: Usage:
echo:   %SCRIPT_NAME% [-q] [--match:"MATCH_PATTERN"] [--omit:"OMIT_PATTERN"] 
echo:     [INPUT_PATH [OUTPUT_PATH]]
exit /b

:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: filter
::
:: Filters piped input and then outputs to standard output.
::
:: Options:
::      --match:"MATCH_PATTERN"
::          remove any lines that do not match MATCH_PATTERN
::
::      --omit:"OMIT_PATTERN"
::          remove any lines that do match OMIT_PATTERN
::
::      -q  Quiet mode. The only output will be to OUTPUT_PATH.
::
:: Empty lines will always be included. An empty line will be added to the end
:: of output, even if none is present on input, due to cmd limitations.
::
:: If INPUT_PATH is specified, input will be read from this file, instead of
:: from the pipe.
::
:: If OUTPUT_PATH is specified, output will also be directed there, wiping any
:: existing file.
::
:: Note that this is an inherently flawed implementation due to the limits of
:: cmd scripting. 
::      Cmd special characters (^, &, !, %, |) may cause problems.
::
:: Any error messages will be prefixed with "#ERR#:" if an error occurs (and is 
:: successfully detected), and output to STDERR.
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

::-----INIT--------------------------------------------------------------------
:INIT
set SCRIPT_NAME=%~n0
set ERRLEV=0

set USAGE_ERR=0

set INPUT_PATH=
set OUTPUT_PATH=
set MATCH_PATTERN=
set OMIT_PATTERN=
set QUIET=0

call split_flags %*

call :PROCESS_ARGS %ARGS%
call :PROCESS_SIMPLE_FLAGS
call :PROCESS_LONG_FLAGS %LONG_FLAGS%

if [%USAGE_ERR%]==[1] (
    echo:ERR: Invalid usage 1>&2
    call :DISPLAY_USAGE_MESSAGE
    goto :ERR
)

:: remove anything existing at OUTPUT_PATH, if provided
if defined OUTPUT_PATH call smart_delete "%OUTPUT_PATH%"

if not defined INPUT_PATH goto :PIPED_INPUT

:FILE_INPUT
call :READ_FILE || goto :ERR
goto :END

:PIPED_INPUT
call :READ_PIPE || goto :ERR
goto :END

:ERR
echo:#ERR#: filter failed 1>&2
if "%ERRLEV%"=="0" set ERRLEV=1
goto :END

:END
endLocal & set ERRLEV=%ERRLEV%

exit /b %ERRLEV%

:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: READ_FILE
::
:: Reads from INPUT_PATH
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:READ_FILE
if not exist "!INPUT_PATH!" (
    echo:#ERR#: filter: input file !INPUT_PATH! does not exist 1>&2
    goto :READ_FILE_ERR
)

for /F "tokens=* usebackq" %%A in (`type "!INPUT_PATH!"`) do (
    call :READ_LINE %%A || goto :READ_FILE_ERR
)
goto :READ_FILE_END

:READ_FILE_ERR
set ERRLEV=1
goto :READ_FILE_END

:READ_FILE_END
exit /b %ERRLEV%


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: READ_PIPE
::
:: Runs the input filter pipe until the pipe is complete.
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:READ_PIPE

for /F "tokens=*" %%A in ('findstr /n "^"') do (
    call :READ_LINE %%A || goto :READ_PIPE_ERR
)
goto :READ_PIPE_END

:READ_PIPE_ERR
set ERRLEV=1
goto :READ_PIPE_END

:READ_PIPE_END
exit /b %ERRLEV%

:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: READ_LINE
::
:: Processes a single line, either from the pipe or the input file.
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:READ_LINE

set "LINE=%*"
set PRESERVE_LINE=1
set "LINE=!LINE:*:=!" || goto :READ_LINE_ERR
call :CHECK_MATCH "!LINE!" || goto :READ_LINE_ERR
call :CHECK_OMIT "!LINE!" || goto :READ_LINE_ERR
call :OUTPUT_LINE "!LINE!" || goto :READ_LINE_ERR

goto :READ_LINE_END

:READ_LINE_ERR
set ERRLEV=1
goto :READ_LINE_END

:READ_LINE_END
exit /b %ERRLEV%

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
:: If PRESERVE_LINE remains true: 
::     - output the line to stdout if not in quiet mode
::     - output the line to OUTPUT_PATH if defined
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:OUTPUT_LINE
if !PRESERVE_LINE!==0 exit /b 0

if "%QUIET%"=="0" echo:%~1
if defined OUTPUT_PATH echo:%~1>>"%OUTPUT_PATH%"

exit /b 0

:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: PROCESS_ARGS
::
:: Process script parameters to initialize corresponding variables.
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:PROCESS_ARGS

set "INPUT_PATH=%~1"
shift

set "OUTPUT_PATH=%~1"
shift

:: no more args currently supported
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

if "!CUR_FLAG!"=="q" (
    set QUIET=1
    goto :WHILE_SIMPLE_FLAGS
)

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