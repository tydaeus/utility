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
set ERRMSG=
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
if "%ERRMSG%"=="" set ERRMSG=ERROR: Failed to delete %TARGET%

:END
if not "%ERRMSG%"=="" echo %ERRMSG% 1>&2
endLocal & set ERRLEV=%ERRLEV% & set ERRMSG=%ERRMSG%

exit /b %ERRLEV%