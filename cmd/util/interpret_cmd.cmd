@Echo off
setLocal enableDelayedExpansion
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: interpret_cmd
::
:: Interprets a single simplified command statement.
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
set ERRLEV=0
set FOUND=0

set "COMMAND_NAME=%~1"

call xshift %*
set "COMMAND_ARGS=%LIST%"

:: process the command to interpret script vars
if defined COMMAND_ARGS (
    set "COMMAND_ARGS=!COMMAND_ARGS:{=%%CMD[!"
    set "COMMAND_ARGS=!COMMAND_ARGS:}=]%%!"
    call set "COMMAND_ARGS=!COMMAND_ARGS!"
)

call :INVOKE_COMMAND

:: check if the command was successfully found, error if not
if "%FOUND%"=="1" goto :COMMAND_FOUND

:COMMAND_NOT_FOUND
call :ECHO_OUTPUT ##STDERR##ERR: interpret_cmd: command not recognized: "%COMMAND_NAME%"
goto :ERR

:COMMAND_FOUND
if not "%ERRLEV%"=="0" (
    call :ECHO_OUTPUT ##STDERR##ERR: interpret_cmd: failed to %COMMAND_NAME% %COMMAND_ARGS%
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

::----- FIND_COMMAND subsection
:FIND_COMMAND
:: Defines the invocable commands and optional configuration for them. 
::
:: Command invocations are defined in format CMD_DEF[NAME], with corresponding
:: configuration in format CMD_CONFIG[NAME].
::
:: These invocations can be overridden by adding a file named cmd_NAME.cmd in
:: the path.
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

set "CMD_DEF[EXE]=cmd /C"

set "CMD_DEF[SET]=call :CMD_SET"
set "CMD_CONFIG[SET]=set CONFIG_VERBOSE=0"

set "CMD_DEF[StartLog]=call :CMD_START_LOG"
set "CMD_CONFIG[StartLog]=set CONFIG_VERBOSE=0"
set "CMD_DEF[StopLog]=call :CMD_STOP_LOG"
set "CMD_CONFIG[StopLog]=set CONFIG_VERBOSE=0"

set "CMD_DEF[TOUCH]=call touch"
set "CMD_DEF[touchAll]=call touch_all"

set "CMD_DEF[UNZIP]=call unzip"

call find_on_path "cmd_%COMMAND_NAME%.cmd"

if defined RET (
    set "INVOCATION=call cmd_%COMMAND_NAME%.cmd"
    set FOUND=1
    goto :END_FIND_COMMAND
)

if defined CMD_DEF[%COMMAND_NAME%] (
    set "INVOCATION=!CMD_DEF[%COMMAND_NAME%]!"
    set FOUND=1
)

if defined CMD_CONFIG[%COMMAND_NAME%] (
    set "INVOCATION_CONFIG=!CMD_CONFIG[%COMMAND_NAME%]!"
)

:END_FIND_COMMAND
endLocal & set "FOUND=%FOUND%" & set "INVOCATION=%INVOCATION%" & set "INVOCATION_CONFIG=%INVOCATION_CONFIG%"
::----- End command definition block

:: skip invoking command if not found (error)
if %FOUND%==0 exit /b

set CONFIG_VERBOSE=1
if not defined CONFIG_LOGGING_ENABLED (
    set CONFIG_LOGGING_ENABLED=0
)

::use config if provided
if defined INVOCATION_CONFIG call :CONFIG_INVOCATION

if "%CONFIG_VERBOSE%"=="1" (
    call :ECHO_OUTPUT %COMMAND_NAME% %COMMAND_ARGS%
)

:: Invoke the command
call instring "%INVOCATION%" ":"
if "%RET%"=="1" goto :INVOKE_WITH_LABEL

:: no label present in invocation, so it's safe to use with 'for /f'
:INVOKE_WITHOUT_LABEL
:: 'for /f' does not preserve ERRORLEVEL, so we use '##ERROR##' as an indicator that an error occurred
for /f "tokens=* useBackQ" %%A in (`%INVOCATION% %COMMAND_ARGS% 2^>^&1 ^|^| echo ##ERROR##`) do (
    call :ECHO_OUTPUT %%A
)
goto :END_INVOKE_COMMAND

:: cannot call a function within for /f, so must invoke otherwise
:: for this reason, functions must handle their own logging if desired
:INVOKE_WITH_LABEL
%INVOCATION% %COMMAND_ARGS%
set ERRLEV=%ERRORLEVEL%
goto :END_INVOKE_COMMAND

:END_INVOKE_COMMAND
exit /b

:: helper function, because executing a variable's contents doesn't work within an if
:CONFIG_INVOCATION
%INVOCATION_CONFIG%
exit /b

:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: ECHO_OUTPUT
::
:: Should get used for all echo statements. Outputs to log if logging is 
:: enabled; log also displays to stdout.
::
:: Checks for flags wrapped in "##" and uses them to indicate special 
:: processing:
::      ##ERROR## indicates that a nonzero ERRORLEVEL occurred
::      ##STDERR## indicates that the remainder should get echoed as stderr
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:ECHO_OUTPUT
set "MSG=%*"

:: blank lines are stdout only and need no pre-processing
if not defined MSG goto :ECHO_OUTPUT_STDOUT

:: ##ERROR## is used to indicate a nonzero errorlevel occurred
if "##ERROR##"=="%MSG%" (
    set ERRLEV=1
    goto :END_ECHO_OUTPUT
)

:: ##STDERR## is used to indicate that the remainder of the line should get output to stdout if logging is off
if not "!MSG:~0,10!"=="##STDERR##" goto :ECHO_OUTPUT_STDOUT

:ECHO_OUTPUT_STDERR
set "MSG=%MSG:~10%"
if "%CONFIG_LOGGING_ENABLED%"=="1" (
    call log %MSG%
) else (
    echo:%MSG% 1>&2
)
goto :END_ECHO_OUTPUT

:ECHO_OUTPUT_STDOUT
if "%CONFIG_LOGGING_ENABLED%"=="1" (
    call log %*
) else (
    echo %*
)

:END_ECHO_OUTPUT
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

:CMD_STOP_LOG
call end_log %*
set CONFIG_LOGGING_ENABLED=0
call export_vars CONFIG_LOGGING_ENABLED
exit /b