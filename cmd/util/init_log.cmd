@Echo Off
setLocal enableDelayedExpansion
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: init_log
::
:: Initializes logging for use with the log.cmd script.
::
:: Usage:
::      init_log [LOGPATH]
::
:: If LOGPATH is not specified, logs will be placed in C:\temp\log.log
:: Fully qualified path should get passed as LOGPATH, otherwise results may be
:: inconsistent when operating over network or on different drives.
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

set ERRLEVEL=0
set LOGPATH=%~1

if ["%LOGPATH%"]==[""] set LOGPATH=C:\temp\log.log

call :MAKE_DIRS "%LOGPATH%"
set ERRLEVEL=%ERRORLEVEL%

endLocal & set LOGPATH=%LOGPATH% & set ERRLEVEL=%ERRLEVEL%
exit /b %ERRLEVEL%

:MAKE_DIRS
:: make necessary dirs for logging; used as function to allow reprocessing of var
setLocal enableDelayedExpansion
set ERRLEVEL=0

set DIRS=%~dp1

if not exist "%DIRS%" md "%DIRS%" > nul 2>&1

endLocal & set ERRLEVEL=%ERRORLEVEL%
exit /b %ERRLEVEL%