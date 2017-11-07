@Echo Off
setLocal enableDelayedExpansion
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: smart_delete
::
:: Usage:
::      smart_delete TARGET
::
:: Deletes TARGET file or dir; automatically detects the appropriate delete
:: command to use.
::
:: Sets ERRLEV to reflect error code
:: Outputs error messages to stderr
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
set ERRLEV=0
set TARGET=%~1

:: consider command successful if target does not exist
if not exist "%TARGET%" (
    goto :END
)

if exist "%TARGET%"\* (
    rd /S /Q "%TARGET%"
    set ERRLEV=%ERRORLEVEL%
) else (
    del /Q "%TARGET%"
    set ERRLEV=%ERRORLEVEL%
)

if "%ERRLEV%"=="0" goto :END

:ERR
echo:ERR: smart_delete: Failed to delete %TARGET% 1>&2

:END
endLocal & set ERRLEV=%ERRLEV%

exit /b %ERRLEV%