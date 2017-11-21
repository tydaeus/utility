@Echo Off
setLocal enableDelayedExpansion

goto :INIT
::-----USAGE-------------------------------------------------------------------
:DISPLAY_USAGE_MESSAGE
echo: Usage:
echo:   %SCRIPT_NAME% [--output:VAR_NAME] BASE_PATH "PATTERN1"...
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
set OUTPUT_VAR=
set BASE_PATH=
set PATTERN=
set "SCRIPT_NAME=%~n0"

set QUOTE="
::"

::-----
:: in this command, all flags must be before args, and will start with '-'
:PROCESS_FLAGS

set "CUR_ARG=%1"
:: we know we'll need at least one non-flag arg
if not defined CUR_ARG (
    echo:ERR: %SCRIPT_NAME%: invalid usage 1>&2
    call :DISPLAY_USAGE_MESSAGE
    goto :ERR
)

:QUOTE_CHECK
:: if arg starts with quotes, it cannot be a flag, so we're done with flags
if !CUR_ARG:~0^,1!==!QUOTE! goto :PROCESS_ARGS

:FLAG_CHECK
if "!CUR_ARG:~0,2!"=="--" (
    call :PROCESS_LONG_FLAG !CUR_ARG! || goto :ERR
    shift
    goto :PROCESS_FLAGS
)

if "!CUR_ARG:~0,1!"=="-" (
    call :PROCESS_SHORT_FLAG !CUR_ARG! || goto :ERR
    shift
    goto :PROCESS_FLAGS
)
::------
:: we're past any flags now

:: ensure OUTPUT_VAR starts blank if we're using one
if defined %OUTPUT_VAR% set %OUTPUT_VAR%=

:PROCESS_ARGS
set "BASE_PATH=%~dpnx1"

if not defined BASE_PATH (
    echo:ERR: %SCRIPT_NAME%: invalid usage 1>&2
    call :DISPLAY_USAGE_MESSAGE
    goto :ERR
)

if not exist "!BASE_PATH!\*" (
    echo:ERR: %SCRIPT_NAME%: BASE_PATH '%BASE_PATH%' does not exist as dir 1>&2
    goto :ERR
)

::-----
:: any remaining params are one of the patterns to try to match
:WHILE_PATTERN
shift
set "PATTERN=%~1"
if not defined PATTERN goto :END_WHILE_PATTERN

call get_latest_file "!BASE_PATH!" "!PATTERN!" || goto :ERR
set "BASE_PATH=!RET!"
goto :WHILE_PATTERN

:END_WHILE_PATTERN

if not defined OUTPUT_VAR (
    echo:!BASE_PATH!
) else (
    set "!OUTPUT_VAR!=!BASE_PATH!"
)
goto :END

:ERR
set ERRLEV=1
echo:ERR: %SCRIPT_NAME% failed 1>&2
goto :END

:END

if not defined OUTPUT_VAR (
    endLocal & set ERRLEV=%ERRLEV%
) else (
    endLocal & set "%OUTPUT_VAR%=%BASE_PATH%" & set ERRLEV=%ERRLEV%
)
exit /b %ERRLEV%

:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:PROCESS_LONG_FLAG
set LONG_FLAG=%1

:: output is only long flag supported
if "!LONG_FLAG:~0,9!"=="--output:" (
    set "OUTPUT_VAR=!LONG_FLAG:~9!"
    exit /b 0
) else (
    echo:ERR: %SCRIPT_NAME%: invalid usage 1>&2
    call :DISPLAY_USAGE_MESSAGE
    exit /b 1
)

:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:PROCESS_SHORT_FLAG
:: no short flags supported
echo:ERR: %SCRIPT_NAME%: invalid usage 1>&2
call :DISPLAY_USAGE_MESSAGE
exit /b 1
