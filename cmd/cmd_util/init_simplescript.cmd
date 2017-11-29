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

if exist "%UTIL_HOME%..\cmd_util_ext\" set "PATH=%UTIL_HOME%..\cmd_util_ext;%PATH%"

:: provide calculated script vars' starting values
set "CMD[ScriptHome]=%SCRIPT_HOME%"
set "CMD[ScriptName]=%SCRIPT_NAME%"
set "CMD[UtilHome]=%UTIL_HOME%"
:: future development may pass root in from elsewhere
if "%CMD[Root]%"=="" set "CMD[Root]=C:\"

:: provide default config options
set "SCRIPT_CONFIG[OUTPUT_MODE]=DEFAULT"

call interpret_file "%SCRIPT_FILE%" --startToken:StartSimpleScript
set "ERRLEV=%ERRORLEVEL%"

if "%ERRLEV%"=="0" (
    echo script %SCRIPT_NAME% successful
) else (
    echo script %SCRIPT_NAME% failed with status %ERRLEV%
)

pause
endLocal & set "ERRLEV=%ERRLEV%"
exit /b %ERRLEV%