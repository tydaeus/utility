@Echo off
setLocal enableDelayedExpansion

:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: backup
::
:: Usage:
::      backup TARGET
::
:: Makes a copy of TARGET as [timestamp]TARGET.bak.
:: Does nothing if TARGET does not exist.
::
:: Depends on several of the utility commands.
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

set ERRLEVEL=0
set TARGET=%~1
set TARGET_PATH=%~dp1
set TARGET_NAME=%~nx1

call eval "short_date" SDATE
call eval "short_time" STIME
set "TIMESTAMP=[%SDATE%-%STIME%]"

if exist "%TARGET%" (
    call smart_copy "%TARGET%" "%TARGET_PATH%%TIMESTAMP%%TARGET_NAME%.bak" > nul || goto :ERR
)

goto :END

:ERR
set ERRLEVEL=1
echo ERROR: failed to backup %TARGET% 1>&2
:END
endLocal & set ERRLEVEL=%ERRLEVEL%
exit /b %ERRLEVEL%