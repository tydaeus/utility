@Echo Off
setLocal enableDelayedExpansion
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: init_log
::
:: Initializes logging for use with the log.cmd script.
::
:: Usage:
::      init_log [LOG_PATH] [LOG_NAME]
::
:: If LOG_PATH is not specified, logs will be placed in C:\temp\log.log
:: Fully qualified path should get passed as LOG_PATH, otherwise results may be
:: inconsistent when operating over network or on different drives.
::
:: LOG_NAME is used to indicate start of logging
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

set ERRLEV=0
set LOG_PATH=%~1
:: default to filename, if present
set LOG_NAME=%~nx1

if ["%LOG_PATH%"]==[""] (
    set LOG_PATH=C:\temp\log.log
    set LOG_NAME=Log
)

if not ["%~2"]==[""] set "LOG_NAME=%~2"

call :MAKE_DIRS "%LOG_PATH%"
set ERRLEV=%ERRORLEVEL%

call eval short_date SDATE
call eval short_time STIME

echo Log started as %LOG_NAME% at %LOG_PATH%

echo -------------------------------------------------------------------------------- >> "%LOG_PATH%"
echo -- %LOG_NAME% started %SDATE%-%STIME% >> "%LOG_PATH%"
echo -------------------------------------------------------------------------------- >> "%LOG_PATH%"

endLocal & set LOG_PATH=%LOG_PATH% & set "LOG_NAME=%LOG_NAME%" & set ERRLEV=%ERRLEV%
exit /b %ERRLEV%

:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:MAKE_DIRS
:: make necessary dirs for logging; used as function to allow reprocessing of var
setLocal enableDelayedExpansion
set ERRLEV=0

set DIRS=%~dp1

if not exist "%DIRS%" md "%DIRS%" > nul

endLocal & set ERRLEV=%ERRORLEVEL%
exit /b %ERRLEV%