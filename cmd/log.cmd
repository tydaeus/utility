@Echo Off
setLocal enableDelayedExpansion
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: log
::
:: Logs the specified message with a timestamp to the location specified by the
:: LOGPATH var. Use init_log to conveniently initialize LOGPATH.
::
:: Usage:
::      log "MESSAGE"
::
:: To simplify subsequent log reading, you may wish to prefix all messages with
:: an indication of their priority (e.g. "WARN:").
::
:: Note that the timestamp is dependent on the OS, configuration, and local
:: timezone.
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

set ERRLEVEL=0
set MESSAGE=%~1

echo [%DATE%-%TIME%]%MESSAGE% >> "%LOGPATH%"
set ERRLEVEL=%ERRORLEVEL%

endLocal & set ERRLEVEL=%ERRLEVEL%
exit /b %ERRLEVEL%