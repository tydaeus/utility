@Echo off
setLocal enableDelayedExpansion
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: interpret_cmd
::
:: Interprets a single simplified command statement.
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
set ERRLEV=0
set FOUND=0

set COMMAND_NAME=%~1

call xshift %*
set "COMMAND_ARGS=%LIST%"

:: process the command to interpret script vars
if not "%COMMAND_ARGS%"=="" (
    set "COMMAND_ARGS=!COMMAND_ARGS:{=%%CMD[!"
    set "COMMAND_ARGS=!COMMAND_ARGS:}=]%%!"
    call set "COMMAND_ARGS=!COMMAND_ARGS!"
)

call :INVOKE_COMMAND

:: check if the command was successfully found, error if not
if "%FOUND%"=="1" goto :COMMAND_FOUND

:COMMAND_NOT_FOUND
echo:ERR: interpret_cmd: command not recognized: "%COMMAND_NAME%" 1>&2
goto :ERR

:COMMAND_FOUND
if not "%ERRLEV%"=="0" (
    echo:ERR: interpret_cmd: failed to %COMMAND_NAME% %COMMAND_ARGS% 1>&2
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
:: need to convert double '"' to single
set EXPORT=%EXPORT:""="%
::"
endLocal & set ERRLEV=%ERRLEV% & %EXPORT%
exit /b %ERRLEV%

:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: INVOKE_COMMAND
::
:: Invokes the command named in COMMAND_NAME, with the arguments held in 
:: COMMAND_ARGS.
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:INVOKE_COMMAND

::----- Command definition block
:: Defines the invocable commands and optional configuration for them. 
::
:: Command invocations are defined in format CMD_DEF[NAME], with corresponding
:: configuration in format CMD_CONFIG[NAME].
::
:: Only the invoked command and its configuration leave the block, as 
:: INVOCATION and INVOCATION_CONFIG.
setLocal

set FOUND=0
set INVOCATION=
set INVOCATION_CONFIG=

set "CMD_DEF[BACKUP]=call backup"
set "CMD_DEF[CALL]=call"
set "CMD_DEF[COPY]=call smart_copy"
set "CMD_DEF[DELETE]=call smart_delete"

set "CMD_DEF[ECHO]=echo"
set "CMD_CONFIG[ECHO]=set CONFIG_VERBOSE=0"

set "CMD_DEF[SET]=call :CMD_SET"
set "CMD_CONFIG[SET]=set CONFIG_VERBOSE=0"

set "CMD_DEF[StartLog]=call :CMD_START_LOG"
set "CMD_CONFIG[StartLog]=set CONFIG_VERBOSE=0"

set "CMD_DEF[TOUCH]=call touch"
set "CMD_DEF[touchAll]=call touch_all"

if defined CMD_DEF[%COMMAND_NAME%] (
    set "INVOCATION=!CMD_DEF[%COMMAND_NAME%]!"
    set FOUND=1
)

if defined CMD_CONFIG[%COMMAND_NAME%] (
    set "INVOCATION_CONFIG=!CMD_CONFIG[%COMMAND_NAME%]!"
)

endLocal & set "FOUND=%FOUND%" & set "INVOCATION=%INVOCATION%" & set "INVOCATION_CONFIG=%INVOCATION_CONFIG%"
::----- End command definition block

:: skip invoking command if not found (error)
if %FOUND%==0 exit /b

set CONFIG_VERBOSE=1
if "%CONFIG_LOGGING_ENABLED%"=="" (
    set CONFIG_LOGGING_ENABLED=0
)

::use config if provided
if not ["%INVOCATION_CONFIG%"]==[""] call :CONFIG_INVOCATION

if "%CONFIG_VERBOSE%"=="1" (
    call :ECHO_INVOCATION %INVOCATION% %COMMAND_ARGS%
)

:: TODO: skip logging separately from echo
:: TODO: use log for command output logging
:: TODO: test that using log for command output can still access ERRLEV

%INVOCATION% %COMMAND_ARGS%
set ERRLEV=%ERRORLEVEL%
exit /b

:: helper function, because executing a variable's contents doesn't work within an if
:CONFIG_INVOCATION
%INVOCATION_CONFIG%
exit /b

:: echoes or logs command invocation
:ECHO_INVOCATION
:: logging performs its own echo op
if "%CONFIG_LOGGING_ENABLED%"=="1" (
    call log %INVOCATION% %COMMAND_ARGS%
) else (
    echo %INVOCATION% %COMMAND_ARGS%
)
exit /b

:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: Commands that must be executed as functions of interpret_cmd
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:CMD_SET
set VAR_NAME=%1
call xshift %*
set "CMD[%RET%]=%LIST%"
call export_vars CMD[%RET%]
exit /b

:CMD_START_LOG
call init_log %*
set CONFIG_LOGGING_ENABLED=1
call export_vars LOG_PATH LOG_NAME CONFIG_LOGGING_ENABLED
exit /b