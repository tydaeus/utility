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
set ERRLEVEL=0

call eval short_date SDATE
call eval short_time STIME

if [%1]==[] (
    call :PIPED_INPUT
) else (
    call :ARG_INPUT %*
)
set ERRLEVEL=%ERRORLEVEL%

:END
endLocal & set ERRLEVEL=%ERRLEVEL%
exit /b %ERRLEVEL%

:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:PIPED_INPUT
for /F "tokens=*" %%A in ('findstr /n $') do (
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
echo [%SDATE%-%STIME%]%MESSAGE%>> "%LOGPATH%"
set ERRLEVEL=%ERRORLEVEL%
exit /b %ERRLEVEL%
