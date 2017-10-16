@echo off
setLocal enableDelayedExpansion

goto :INIT
::-----USAGE-------------------------------------------------------------------
:DISPLAY_USAGE_MESSAGE
echo: Usage:
echo:   %SCRIPT_NAME% [--output=OUTPUT] STRING PATTERN
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
echo:   sets RET=1 if STRING matches, 0 if STRING does not match
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

call :PROCESS_ARGS %*

if [%DISPLAY_HELP%]==[1] (
	call :DISPLAY_HELP
	goto :END
)

if [%USAGE_ERR%]==[1] (
	echo:ERR: Invalid usage 1>&2
	call :DISPLAY_USAGE_MESSAGE
	goto :ERR
)

set "STRING=%~1"
set "PATTERN=%~2"

call :MATCH_SUB "%STRING%" "%PATTERN%"

:ERR
if "%ERRLEV%"=="0" set ERRLEV=1
goto :END

:END
echo %RET%
endLocal & set ERRLEV=%ERRLEV%
exit /b %ERRLEV%

:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: PROCESS_ARGS
::
:: Process script parameters to initialize corresponding variables.
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:PROCESS_ARGS

:: TODO: simplify, add --output processing

:LOOP_UNTIL_STRING
if [%~1]==[] goto :END_PROCESS_ARGS
call :MATCH_SUB "%~1" "^-"
if [%RET%]==[1] (
	call :PROCESS_FLAG "%~1"
	shift
	goto :LOOP_UNTIL_STRING
) else (
	set "STRING=%~1"
	shift
	goto :LOOP_UNTIL_PATTERN
)


:LOOP_UNTIL_PATTERN
if [%~1]==[] goto :END_PROCESS_ARGS
call :MATCH_SUB "%~1" "^-"
if [%RET%]==[1] (
	call :PROCESS_FLAG "%~1"
	shift
	goto 
) else (
	set "PATTERN=%~1"
	shift
	goto :LOOP_UNTIL_END
)

:LOOP_UNTIL_END
if [%~1]==[] goto :END_PROCESS_ARGS
call :MATCH_SUB "%~1" "^-"
if [%RET%]==[1] (
	call :PROCESS_FLAG "%~1"
	shift
	goto 
) else (
	set "USAGE_ERR=1"
	goto :END_PROCESS_ARGS
)

:END_PROCESS_ARGS
if [%STRING%]==[] set USAGE_ERR=1
if [%PATTERN%]==[] set USAGE_ERR=1
exit /b

:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: PROCESS_FLAG
::
:: Examines a flag to determine appropriate response.
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:PROCESS_FLAG
set "FLAG=%~1"

echo:flag detected as %FLAG%
if [%FLAG%]==[-?] (
	echo help flag found
	set DISPLAY_HELP=1
	exit /b
)
if [%FLAG%]==[-h] (
	set DISPLAY_HELP=1
	exit /b
)
if ["%FLAG%"]==["--help"] (
	set DISPLAY_HELP=1
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

echo %STRING% | findstr /R "%PATTERN%" > nul
set FINDSTR_RET=%ERRORLEVEL%
echo FINDSTR_RET: %FINDSTR_RET%

if "%FINDSTR_RET%"=="0" (
	set RET=1
) else (
	set RET=0
)

echo MATCH_SUB RET: %RET%

endLocal & set RET=%RET%
exit /b