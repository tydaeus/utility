@Echo Off
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: pwait
::
:: Usage:
::      pwait [SECONDS]
::
:: Provide wait functionality via loopback ping, for compatibility and
:: efficiency. Defaults to a ~1s wait.
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

setLocal

set "WAIT_SECONDS=%~1"
if not defined WAIT_SECONDS set WAIT_SECONDS=1
set /a "WAIT_SECONDS=%WAIT_SECONDS% + 1"
ping 127.0.0.1 -n %WAIT_SECONDS% >nul

endLocal
exit /b