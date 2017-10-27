@echo off
setLocal enableDelayedExpansion

goto :INIT
::-----USAGE-------------------------------------------------------------------
:DISPLAY_USAGE_MESSAGE
echo: Usage:
echo:   %SCRIPT_NAME% [-?h] [--help] [--output:OUTPUT] STRING PATTERN
exit /b

::-----DISPLAY_HELP------------------------------------------------------------
:DISPLAY_HELP
echo:
echo: %SCRIPT_NAME%
echo:
::-----
call :DISPLAY_USAGE_MESSAGE
::-----
echo:
echo: Determines whether STRING matches PATTERN. Note that special character
echo: escaping has not been fully implemented.
echo:
echo: Returns:
echo:   1 if STRING matches, 0 if STRING does not match. This will be assigned to
echo:   variable named in OUTPUT, if specified; sent to stdout otherwise.
echo:
exit /b

::-----INIT--------------------------------------------------------------------
:INIT
set SCRIPT_NAME=%~n0
set ERRLEV=0

set DISPLAY_HELP=0
set USAGE_ERR=0
set STRING=
set PATTERN=
set OUTPUT_VAR=

call split_flags %*

call :PROCESS_ARGS %ARGS%
call :PROCESS_SIMPLE_FLAGS
call :PROCESS_LONG_FLAGS %LONG_FLAGS%

if [%DISPLAY_HELP%]==[1] (
	call :DISPLAY_HELP
	goto :END
)

if [%USAGE_ERR%]==[1] (
	echo:ERR: Invalid usage 1>&2
	call :DISPLAY_USAGE_MESSAGE
	goto :ERR
)

call :MATCH_SUB "%STRING%" "%PATTERN%" || goto :ERR
goto :SUCCESS

:ERR
if "%ERRLEV%"=="0" set ERRLEV=1
goto :END

:SUCCESS
if not defined OUTPUT_VAR echo:%RET%
goto :END

:END
if not defined OUTPUT_VAR (
	endLocal & set ERRLEV=%ERRLEV%
) else (
	endLocal & set %OUTPUT_VAR%=%RET%
)
exit /b %ERRLEV%

:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: PROCESS_ARGS
::
:: Process script parameters to initialize corresponding variables.
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:PROCESS_ARGS

set "STRING=%~1"
shift

set "PATTERN=%~1"
shift

:: no third arg currently supported
:: Future: support multiple patterns?
set "CUR_ARG=%~1"
if defined CUR_ARG set USAGE_ERR=1

:END_PROCESS_ARGS
if not defined STRING set USAGE_ERR=1
if not defined PATTERN set USAGE_ERR=1
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

if "%CUR_FLAG%"=="?" (
	set DISPLAY_HELP=1
	goto :WHILE_SIMPLE_FLAGS
)

if "%CUR_FLAG%"=="h" (
	set DISPLAY_HELP=1
	goto :WHILE_SIMPLE_FLAGS
)
::-----

:: unrecognized char
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

if ["%FLAG%"]==["help"] (
	set DISPLAY_HELP=1
	exit /b
)

if "%FLAG:~0,7%"=="output:" (
	set OUTPUT_VAR=%FLAG:~7%
	exit /b
)

set USAGE_ERR=1
exit /b

:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: MATCH_SUB
::
:: Subroutine that performs the actual matching process and returns result as
:: RET.
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:MATCH_SUB
setLocal enableDelayedExpansion
set FINDSTR_RET=
set RET=

:: we can assume STRING and PATTERN are defined
set "STRING=%~1"
:: '^' gets escaped as part of the call, so we need to unescape it prior to using findstr
set "PATTERN=%~2"
set "PATTERN=%PATTERN:^^=^%"

echo:%STRING%| findstr /R "%PATTERN%" > nul
set FINDSTR_RET=%ERRORLEVEL%

if "%FINDSTR_RET%"=="0" (
	set RET=1
) else (
	set RET=0
)

endLocal & set RET=%RET%
exit /b