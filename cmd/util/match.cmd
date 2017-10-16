@echo off
setLocal enableDelayedExpansion

goto :INIT
::-----USAGE-------------------------------------------------------------------
:DISPLAY_USAGE_MESSAGE
echo: Usage:
echo:   %SCRIPT_NAME% [--output:OUTPUT] STRING PATTERN
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
call :PROCESS_SIMPLE_FLAGS %SIMPLE_FLAGS%
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
if ["%OUTPUT_VAR%"]==[""] echo:%RET%
goto :END

:END
if ["%OUTPUT_VAR%"]==[""] (
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

:: TODO: multi-patterns?

if [%~1]==[] goto :END_PROCESS_ARGS
set "STRING=%~1"
shift

if [%~1]==[] goto :END_PROCESS_ARGS
set "PATTERN=%~1"
shift

:END_PROCESS_ARGS
if [%STRING%]==[] set USAGE_ERR=1
if [%PATTERN%]==[] set USAGE_ERR=1
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
call :MATCH_SUB "%*" "[^?hH]"
if "%RET%"=="1" (
	set USAGE_ERR=1
	exit /b
)

:: check for help flags
call :MATCH_SUB "%*" "[?hH]"
if "%RET%"=="1" (
	set DISPLAY_HELP=1
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

if ["%FLAG%"]==["help"] (
	set DISPLAY_HELP=1
	exit /b
)

call :MATCH_SUB "%FLAG%" "^output:"
if "%RET%"=="1" (
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