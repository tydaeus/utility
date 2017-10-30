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

set "SCRIPT_PATH=%~1"

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
endLocal & set ERRLEV=%ERRLEV%

exit /b %ERRLEV%

:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: RUN_FILE
:: Read and execute provided install.cfg
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:RUN_FILE

call interpret_file "%SCRIPT_PATH%"

exit /b %ERRLEV%