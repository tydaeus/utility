@Echo Off
setLocal enableDelayedExpansion
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: init_simplescript
::
:: Provides initialization for a .cmd/DSL hybrid simplescript file.
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
set ERRLEV=0
set "SCRIPT_HOME=%~dp1"
set "SCRIPT_NAME=%~n1"
set "SCRIPT_FILE=%~dpnx1"
set "UTIL_HOME=%~dp0"

set "PATH=%UTIL_HOME%;%PATH%"

set "CMD[ScriptHome]=%SCRIPT_HOME%"
set "CMD[ScriptName]=%SCRIPT_NAME%"
set "CMD[UtilHome]=%UTIL_HOME%"

:: future development may pass root in from elsewhere
if "%CMD[Root]%"=="" set "CMD[Root]=C:\"

call interpret_file "%SCRIPT_FILE%" --startToken:StartSimpleScript
set "ERRLEV=%ERRORLEVEL%"

echo:script %SCRIPT_NAME% complete with status %ERRLEV%
pause
endLocal & set "ERRLEV=%ERRLEV%"
exit /b %ERRLEV%