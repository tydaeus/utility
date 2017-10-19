@Echo Off
setLocal enableDelayedExpansion

:: updates the modified timestamp of all files in the specified directory

set ERRLEV=0
set TARGET_DIR=%~1

:: no XP support
for /R "%TARGET_DIR%" %%A in (*) do (
    copy /b "%%A"+,, "%TARGET_DIR%" > nul
    set ERRLEV=%ERRORLEVEL%
    if not "%ERRLEV%" == "0" goto :ERR
)

:: Version with XP support:
:: pushd "%TARGET_DIR%"
:: for /R "%TARGET_DIR%" %%A in (*) do (
::     copy /b "%%A"+,, > nul
::     set ERRLEV=%ERRORLEVEL%
::     if not "%ERRLEV%" == "0" goto :ERR
:: )
:: popd


goto :END

:ERR
:END
endLocal & set ERRLEV=%ERRLEV%
exit /b %ERRLEV%