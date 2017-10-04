@Echo Off
setLocal enableDelayedExpansion
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: log
::
:: Logs the specified message with a timestamp to the location specified by the
:: LOGPATH var. Use init_log to conveniently initialize LOGPATH.
::
:: Usage:
::      log MESSAGE...
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

call eval short_time STIME

if [%1]==[] (
    call :PIPED_INPUT
) else (
    call :ARG_INPUT %*
)
set LOG_ERR=%ERRORLEVEL%

:END
endLocal & set LOG_ERR=%LOG_ERR%
if not "%LOG_ERR%"=="0" echo ERROR: logging error encountered 1>&2
exit /b %LOG_ERR%

:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:PIPED_INPUT

for /F "tokens=*" %%A in ('findstr /n "^"') do (
    rem echo in-loop ERRLEV %ERRLEV%
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

echo %MESSAGE%
echo [%STIME%]%MESSAGE%>> "%LOGPATH%"
set LOG_ERR=%ERRORLEVEL%

exit /b %LOG_ERR%
