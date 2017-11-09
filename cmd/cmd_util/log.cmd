@Echo Off
setLocal enableDelayedExpansion
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: log
::
:: Logs the specified message with a timestamp to the location specified by the
:: LOG_PATH var. Use init_log to conveniently initialize LOG_PATH.
::
:: Usage:
::      log [--pipe] MESSAGE...
::
:: Note that all arguments are used as MESSAGEs for output to the same line.
::
:: Currently always echoes MESSAGE to standard out as well, for piping or user
:: feedback.
::
:: To simplify subsequent log reading, you may wish to prefix all messages with
:: an indication of their priority (e.g. "WARN:").
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

:: use a separate var for logger errors, so conventional ERRLEV is untouched
set LOG_ERR=0

set "ARG1=%~1"

:: output blank input to log
if not defined ARG1 goto :LOG_ARGS
:: look for --pipe flag as first parameter
if "!ARG1!"=="--pipe" goto :LOG_PIPE
:: default to logging whatever was passed
goto :LOG_ARGS


:LOG_PIPE
call :PIPED_INPUT
set LOG_ERR=%ERRORLEVEL%
goto :END

:LOG_ARGS
call :ARG_INPUT %*
set LOG_ERR=%ERRORLEVEL%
goto :END

:END
endLocal & set LOG_ERR=%LOG_ERR%
if not "%LOG_ERR%"=="0" echo ERROR: logging error encountered 1>&2
exit /b %LOG_ERR%

:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:PIPED_INPUT

for /F "tokens=*" %%A in ('findstr /n "^"') do (
    set "line=%%A"
    setlocal enableDelayedExpansion
    set "line=!line:*:=!"
    call :ARG_INPUT !line!
    endLocal
)

exit /b %ERRORLEVEL%

:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:ARG_INPUT
set "MESSAGE=%*"
call eval short_time STIME

echo:!MESSAGE!
echo:[!STIME!]!MESSAGE!>> "!LOG_PATH!"
set "LOG_ERR=%ERRORLEVEL%"

exit /b %LOG_ERR%
