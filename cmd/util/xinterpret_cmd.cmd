@Echo off
setLocal enableDelayedExpansion
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: interpret_cmd
::
:: Interprets a single simplified command statement. Kept as separate file for
:: simplification.
::
:: DevNote: individual command subroutines will receive the original invocation
:: params. %1 will be the command name, %2 will be param 1, etc.
:: DevNote: individual commands must set FOUND=1 to indicate that the command
:: was found, otherwise they will be interpreted as not found.
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
set ERRLEV=0
set FOUND=0

if not defined DEST_PATH set DEST_PATH=
if not defined RSRC_PATH set RSRC_PATH=

set COMMAND_NAME=%~1

call xshift %*
set "COMMAND=%LIST%"

:: process the command to interpret script vars
set "COMMAND=!COMMAND:{=%%CMD[!"
set "COMMAND=!COMMAND:}=]%%!"
call set "COMMAND=!COMMAND!"

call :INVOKE_COMMAND

:: check if the command was successfully found, error if not
if "%FOUND%"=="1" goto :COMMAND_FOUND

:COMMAND_NOT_FOUND
echo:ERR: interpret_cmd: command not recognized: "%COMMAND_NAME%" 1>&2
goto :ERR

:COMMAND_FOUND
if not "%ERRLEV%"=="0" (
    echo:ERR: interpret_cmd: failed to %COMMAND_NAME% %COMMAND% 1>&2
    goto :ERR
)
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
if defined EXPORT goto :EXPORT_END
endLocal & set ERRLEV=%ERRLEV%
exit /b %ERRLEV%

:: export variables set via the set command
:EXPORT_END
endLocal & set ERRLEV=%ERRLEV% & %EXPORT:""="%
::"
exit /b %ERRLEV%

::-----------------------------------------------------------------------------
:: Define Invokable Commands
:: Operates on COMMAND and COMMAND_NAME
::-----------------------------------------------------------------------------
:INVOKE_COMMAND
setLocal

set FOUND=0
set INVOCATION=
set INVOCATION_CONFIG=

set "CMD_ECHO=echo"
set "CMD_CONFIG_ECHO=set CONFIG_VERBOSE=0"

set "CMD_BACKUP=call backup"
set "CMD_CALL=call"
set "CMD_COPY=call smart_copy"
set "CMD_DELETE=call smart_delete"
set "CMD_touchAll=call touch_all"

set "CMD_SET=call :CMD_SET"
set "CMD_CONFIG_SET=set CONFIG_VERBOSE=0"

if defined CMD_%COMMAND_NAME% (
	set "INVOCATION=!CMD_%COMMAND_NAME%!"
	set FOUND=1
)

if defined CMD_CONFIG_%COMMAND_NAME% (
	set "INVOCATION_CONFIG=!CMD_CONFIG_%COMMAND_NAME%!"
)

endLocal & set "FOUND=%FOUND%" & set "INVOCATION=%INVOCATION%" & set "INVOCATION_CONFIG=%INVOCATION_CONFIG%"

:: skip invoking command if not found
if %FOUND%==0 exit /b

set CONFIG_VERBOSE=1

::use config if provided
if not ["%INVOCATION_CONFIG%"]==[""] call :CONFIG_INVOCATION

if "%CONFIG_VERBOSE%"=="1" (
	echo %INVOCATION% %COMMAND%
)

%INVOCATION% %COMMAND%
set ERRLEV=%ERRORLEVEL%
exit /b

:CONFIG_INVOCATION
%INVOCATION_CONFIG%
exit /b

:CMD_SET
set VAR_NAME=%1
call xshift %*
set "CMD[%RET%]=%LIST%"
call export_vars CMD[%RET%]
exit /b
