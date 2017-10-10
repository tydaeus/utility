@Echo Off
setLocal enableDelayedExpansion

:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: interpret_install
::
:: Uses the configuration established by install.cmd to:
::  1. Start Logging
::  2. Interpret the install script, logging its output
::  3. End Logging
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

call init_log "%LOG_LOC%" "%LOG_NAME%"

call :RUN_FILE || goto :ERR

goto :SUCCESS

:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:ERR
if "%ERRLEV%"=="0" set ERRLEV=1
goto :END

:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:SUCCESS
goto :END

:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:END
call end_log
endLocal & set ERRLEV=%ERRLEV%

exit /b %ERRLEV%

:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: RUN_FILE
:: Read and execute provided install.cfg
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:RUN_FILE
:: use a sentinel file to detect success/failure, due to pipe limitations
set "SENTINEL=%INSTALLER_DIR%.failed.%COMPUTERNAME%.tmp"
echo > "%SENTINEL%"

2>&1 (call interpret_file "%INSTALLER_DIR%%SCRIPT_FILE%" && del "%SENTINEL%") | call log

if exist "%SENTINEL%" (
    set ERRLEV=1
    del "%SENTINEL%"
)

exit /b %ERRLEV%