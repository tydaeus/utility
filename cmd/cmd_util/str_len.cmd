@Echo Off
setLocal enableDelayedExpansion

:: puts the length of all combined arguments (%*) into RET

set RET=0
set ERRLEV=0

set "STR=%*"

::-----
:WHILE_CHARS_REMAIN

::empty string
if not defined STR goto :END

set "STR=!STR:~1!" || goto :ERR
set /a "RET=RET+1" || goto :ERR

goto :WHILE_CHARS_REMAIN
::-----

:ERR
set ERRLEV=1
goto :END

:END
endLocal & set "RET=%RET%" & set "ERRLEV=%ERRLEV%"
exit /b %ERRLEV%