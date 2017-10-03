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

call list_args %*
set "MESSAGE=%LIST%"

call eval short_date SDATE
call eval short_time STIME
echo %MESSAGE%
echo [%SDATE%-%STIME%]%MESSAGE% >> "%LOGPATH%"
set ERRLEVEL=%ERRORLEVEL%

endLocal & set ERRLEVEL=%ERRLEVEL%
exit /b %ERRLEVEL%