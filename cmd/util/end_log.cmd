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

echo Ending log %LOG_NAME%

echo -------------------------------------------------------------------------------- >> "%LOG_PATH%"
echo -- %LOG_NAME% ended %SDATE%-%STIME% >> "%LOG_PATH%"
echo -------------------------------------------------------------------------------- >> "%LOG_PATH%"
echo: >> "%LOG_PATH%"

endLocal
