@Echo Off
setLocal enableDelayedExpansion

:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: standard_script TODO: replace with scripts actual name
::
:: Usage:
::      TODO: provide usage message
::
:: TODO: describe script
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

set "SCRIPT_NAME=%~n0"
set "SCRIPT_DIR=%~dp0"
set "ERRLEV=0"

:: TODO: insert main logic here

goto :END

:: Default error handling. Ensures that error level is set to a non-success
:: value and a basic error message is displayed. Set ERRLEV to a nonzero value
:: prior to calling if default error messaging and level is not desired.
:ERR
if "!ERRLEV!"=="0" (
    set "ERRLEV=1"
    1>&2 echo:ERROR: !SCRIPT_NAME! failed
)
goto :END

:: Finish the script and tidy up
:END
endLocal & set ERRLEV=%ERRLEV%
exit /b %ERRLEV%

:: TODO: insert any functions here