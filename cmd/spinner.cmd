@Echo Off
setLocal enableDelayedExpansion

:: general format for a progress spinner

set I=0

set "SPINNER[0]=|"
set "SPINNER[1]=/"
set "SPINNER[2]=-"
set "SPINNER[3]=\"

<nul set /p "z=!SPINNER[%I%]!"

:WHILE_INCOMPLETE
:: TODO: check for stop condition, e.g. file presence/absence, process presence/absence

ping 127.0.0.1 -n 1 >nul

set /a "I=I+1"

if %I%==4 set I=0
<nul set /p "z=!SPINNER[%I%]!"

goto :WHILE_INCOMPLETE

endLocal
exit /b
