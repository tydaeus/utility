@Echo off
setLocal enableDelayedExpansion
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: interpret_cmd
::
:: Interprets a single simplified command statement.
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
set ERRLEV=0
set FOUND=0
set EXPORT=
set RETRIES=0
set "COMMAND_NAME=%~1"

call xshift %*
set "COMMAND_ARGS=%LIST%"

:: process the command to interpret script vars
if defined COMMAND_ARGS (
    set "COMMAND_ARGS=!COMMAND_ARGS:{=%%CMD[!"
    set "COMMAND_ARGS=!COMMAND_ARGS:}=]%%!"
    call set "COMMAND_ARGS=!COMMAND_ARGS!"
)

:: processing on command string is complete, time to invoke it
:COMMAND_READY_TO_INVOKE

call :INVOKE_COMMAND

:: check if the command was successfully found, error if not
if "%FOUND%"=="1" goto :COMMAND_FOUND

:COMMAND_NOT_FOUND
call :ECHO_OUTPUT ##STDERR##ERR: interpret_cmd: command not recognized: "%COMMAND_NAME%"
goto :ERR

:COMMAND_FOUND
if not "%ERRLEV%"=="0" (
    call :ECHO_OUTPUT ##STDERR##ERR: interpret_cmd: failed to !COMMAND_NAME! !COMMAND_ARGS!
    goto :ERR
)
goto :END

:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: Ensure errors have standardized handling, allowing for a simple jump for
:: error handling for default processing
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:ERR
if not defined SCRIPT_CONFIG[ERROR_MODE] set "SCRIPT_CONFIG[ERROR_MODE]=DEFAULT"

if "!SCRIPT_CONFIG[ERROR_MODE]!"=="DEFAULT" goto :ERR_REPORT_FAILURE
if "!SCRIPT_CONFIG[ERROR_MODE]!"=="FAIL" goto :ERR_REPORT_FAILURE
:: attempt to retry the command
if "!SCRIPT_CONFIG[ERROR_MODE]!"=="RETRY" goto :ERR_CHECK_RETRY
if "!SCRIPT_CONFIG[ERROR_MODE]!"=="IGNORE" (
    call :ECHO_OUTPUT Ignoring error.
    set ERRLEV=0
    goto :END
)

:: See if we should still retry the command
:ERR_CHECK_RETRY
if not defined SCRIPT_CONFIG[MAX_RETRIES] set "SCRIPT_CONFIG[MAX_RETRIES]=1"

if !RETRIES! geq !SCRIPT_CONFIG[MAX_RETRIES]! (
    call :ECHO_OUTPUT Retries exceeded.
    goto :ERR_REPORT_FAILURE
)
call :ECHO_OUTPUT Retrying...
set /a "RETRIES+=1"
goto :COMMAND_READY_TO_INVOKE

:: Indicate that command interpretation has failed
:ERR_REPORT_FAILURE
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
set EXPORT=!EXPORT:""="!
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
set "CMD_DEF[CD]=cd"
set "CMD_DEF[CONFIG]=call :CMD_CONFIG"
set "CMD_DEF[COPY]=call smart_copy"
set "CMD_DEF[DELETE]=call smart_delete"

set "CMD_DEF[ECHO]=call :CMD_ECHO"
set "CMD_CONFIG[ECHO]=set CONFIG_VERBOSE=0"

set "CMD_DEF[EXE]=cmd /C"
set "CMD_DEF[EXPORT]=call :CMD_EXPORT"
set "CMD_DEF[FILTER]=call filter -q"
set "CMD_DEF[ResolvePath]=call resolve_path"

set "CMD_DEF[SET]=call :CMD_SET"
set "CMD_CONFIG[SET]=set CONFIG_VERBOSE=0"

set "CMD_DEF[StartLog]=call :CMD_START_LOG"
set "CMD_CONFIG[StartLog]=set CONFIG_VERBOSE=0"
set "CMD_DEF[StopLog]=call :CMD_STOP_LOG"
set "CMD_CONFIG[StopLog]=set CONFIG_VERBOSE=0"

set "CMD_DEF[TOUCH]=call touch"
set "CMD_DEF[touchAll]=call touch_all"

set "CMD_DEF[UNZIP]=call unzip"
set "CMD_DEF[WAIT]=call :CMD_WAIT"
set "CMD_CONFIG[WAIT]=set CONFIG_VERBOSE=0"

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
    call :ECHO_OUTPUT !COMMAND_NAME! !COMMAND_ARGS!
)

:: remove previous value
set CMD[ReturnValue]=

::----- Determine Appropriate Invocation
:: function calls don't play nice with the for /f loop, so must handle their 
:: own output
call instring "%INVOCATION%" ":"
if "%RET%"=="1" goto :INVOKE_WITH_MANUAL_OUTPUT

if not defined SCRIPT_CONFIG[OUTPUT_MODE] set "SCRIPT_CONFIG[OUTPUT_MODE]=DEFAULT"

if "!SCRIPT_CONFIG[OUTPUT_MODE]!"=="DEFAULT" goto :INVOKE_WITH_LOOP_OUTPUT
if "!SCRIPT_CONFIG[OUTPUT_MODE]!"=="LOOP" goto :INVOKE_WITH_LOOP_OUTPUT
if "!SCRIPT_CONFIG[OUTPUT_MODE]!"=="REDIRECT" goto :INVOKE_WITH_REDIRECT_OUTPUT
if "!SCRIPT_CONFIG[OUTPUT_MODE]!"=="MANUAL" goto :INVOKE_WITH_MANUAL_OUTPUT

:: invalid configuration
call :ECHO_OUTPUT ##STDERR##WARN: interpret_cmd: invalid OUTPUT_MODE config !SCRIPT_CONFIG[OUTPUT_MODE]!, using DEFAULT
set SCRIPT_CONFIG[OUTPUT_MODE]=DEFAULT
:: acceptable issue: this export will be overridden if current command does its own exporting
call export_vars SCRIPT_CONFIG[OUTPUT_MODE]
goto :INVOKE_WITH_LOOP_OUTPUT
::-----

:: Loop through the command's output and log each line. Does not work 
:: correctly with if command is a function, or in some cases where an invoked
:: script or executable does some of its own output manipulation.
:INVOKE_WITH_LOOP_OUTPUT

:: 'for /f' does not preserve ERRORLEVEL, so we use '##ERROR##' as an indicator that an error occurred
for /f "tokens=* useBackQ" %%A in (`%INVOCATION% %COMMAND_ARGS% 2^>^&1 ^|^| echo ##ERROR##`) do (
    call :ECHO_OUTPUT %%A
    set "CMD[ReturnValue]=%%A"
)
goto :END_INVOKE_COMMAND

:: Run the command, redirecting its output to the log file if logging is on.
:: Safer to use with some scripts and executables, but does not tee the output
:: to stdout
:INVOKE_WITH_REDIRECT_OUTPUT
if not "%CONFIG_LOGGING_ENABLED%"=="1" goto :INVOKE_WITH_MANUAL_OUTPUT
%INVOCATION% %COMMAND_ARGS% >> "%LOG_PATH%"
set ERRLEV=%ERRORLEVEL%
goto :END_INVOKE_COMMAND

:: cannot call a function within for /f, so must invoke otherwise
:: for this reason, functions must handle their own output and logging if 
:: desired
:INVOKE_WITH_MANUAL_OUTPUT
%INVOCATION% %COMMAND_ARGS%
set ERRLEV=%ERRORLEVEL%
goto :END_INVOKE_COMMAND

:END_INVOKE_COMMAND
if defined CMD[ReturnValue] call export_vars CMD[ReturnValue]
exit /b %ERRLEV%

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
::
:: Implemented with goto logic in an attempt to support parentheses in message.
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:ECHO_OUTPUT
set "MSG=%*"

:: blank lines are stdout only and need no pre-processing
if not defined MSG goto :ECHO_OUTPUT_STDOUT

:: ##ERROR## is used to indicate a nonzero errorlevel occurred
:EO_CHECK_FOR_ERROR
if not "##ERROR##"=="!MSG!" goto :EO_CHECK_FOR_STDERR
set ERRLEV=1
goto :END_ECHO_OUTPUT

:EO_CHECK_FOR_STDERR
:: ##STDERR## is used to indicate that the remainder of the line should get output to stdout if logging is off
if not "!MSG:~0,10!"=="##STDERR##" goto :ECHO_OUTPUT_STDOUT

:ECHO_OUTPUT_STDERR
set "MSG=%MSG:~10%"

if not "%CONFIG_LOGGING_ENABLED%"=="1" goto :EO_ECHO_STDERR
call log %MSG%
goto :END_ECHO_OUTPUT

:EO_ECHO_STDERR
echo:!MSG! 1>&2
goto :END_ECHO_OUTPUT

:ECHO_OUTPUT_STDOUT
if not "%CONFIG_LOGGING_ENABLED%"=="1" goto :EO_ECHO_STDOUT
call log !MSG!
goto :END_ECHO_OUTPUT

:EO_ECHO_STDOUT
echo:!MSG!
goto :END_ECHO_OUTPUT

:END_ECHO_OUTPUT
exit /b

:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: Commands that must be executed as functions of interpret_cmd
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:CMD_ECHO
set "OUTPUT=%*"
call :ECHO_OUTPUT !OUTPUT!
exit /b

:CMD_EXPORT
set "VAR_NAME=%~1"
call xshift %*
set "!VAR_NAME!=!LIST!"
call export_vars !VAR_NAME!
exit /b

:CMD_CONFIG
set "VAR_NAME=%~1"
call xshift %*
set "SCRIPT_CONFIG[!VAR_NAME!]=!LIST!"
call export_vars "SCRIPT_CONFIG[!VAR_NAME!]"
exit /b

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

:: use ping to wait specified number of seconds
:CMD_WAIT
set "WAIT_SECONDS=%~1"
call :ECHO_OUTPUT Waiting %WAIT_SECONDS%s...
call pwait %WAIT_SECONDS%
exit /b

