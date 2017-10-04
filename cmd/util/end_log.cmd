@Echo Off
setLocal enableDelayedExpansion
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: end_log
::
:: Provides some end-of-logging tidy up. Not necessary, but can make logs more
:: readable.
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
call eval short_date SDATE
call eval short_time STIME

echo Ending log %LOGNAME%

echo -------------------------------------------------------------------------------- >> "%LOGPATH%"
echo -- %LOGNAME% ended %SDATE%-%STIME% >> "%LOGPATH%"
echo -------------------------------------------------------------------------------- >> "%LOGPATH%"
echo: >> "%LOGPATH%"

endLocal
