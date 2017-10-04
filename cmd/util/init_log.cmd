@Echo Off
setLocal enableDelayedExpansion
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: init_log
::
:: Initializes logging for use with the log.cmd script.
::
:: Usage:
::      init_log [LOGPATH] [LOGNAME]
::
:: If LOGPATH is not specified, logs will be placed in C:\temp\log.log
:: Fully qualified path should get passed as LOGPATH, otherwise results may be
:: inconsistent when operating over network or on different drives.
::
:: LOGNAME is used to indicate start of logging
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

set ERRLEV=0
set LOGPATH=%~1
:: default to filename, if present
set LOGNAME=%~nx1

if ["%LOGPATH%"]==[""] (
    set LOGPATH=C:\temp\log.log
    set LOGNAME=Log
)

if not ["%~2"]==[""] set "LOGNAME=%~2"

call :MAKE_DIRS "%LOGPATH%"
set ERRLEV=%ERRORLEVEL%

call eval short_date SDATE
call eval short_time STIME

echo Log started as %LOGNAME% at %LOGPATH%

echo -------------------------------------------------------------------------------- >> "%LOGPATH%"
echo -- %LOGNAME% started %SDATE%-%STIME% >> "%LOGPATH%"
echo -------------------------------------------------------------------------------- >> "%LOGPATH%"

endLocal & set LOGPATH=%LOGPATH% & set "LOGNAME=%LOGNAME%" & set ERRLEV=%ERRLEV%
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