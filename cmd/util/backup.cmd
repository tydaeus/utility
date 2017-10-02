@Echo off
setLocal enableDelayedExpansion

:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: backup
::
:: Usage:
::      backup TARGET
::
:: Makes a copy of TARGET as TARGET.bak, removing any pre-existing TARGET.bak.
:: Does nothing if TARGET does not exist.
::
:: Depends on the smart_delete and smart_copy utility commands.
::
:: Future: This can be easily modified to create timestamped backups instead of
:: keeping just one .bak backup.
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

set ERRLEVEL=0
set TARGET=%~1
set TARGET_NAME=%~nx1

if exist "%TARGET%.bak" (
    call smart_delete "%TARGET%.bak" || goto :ERR
)

if exist "%TARGET%" (
    call smart_copy "%TARGET%" "%TARGET%.bak" > nul || goto :ERR
)

goto :END

:ERR
set ERRLEVEL=1
echo ERROR: failed to backup %TARGET% 1>&2
:END
endLocal & set ERRLEVEL=%ERRLEVEL%
exit /b %ERRLEVEL%