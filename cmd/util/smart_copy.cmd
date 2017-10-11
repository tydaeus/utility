@Echo Off
setLocal enableDelayedExpansion
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: smart_copy
::
:: Usage:
::      smart_copy SRC DEST
::
::  Copies source to dest, automatically detecting whether src is a dir or
::  file and using the appropriate command.
::
::  Sets ERRLEV to reflect error code
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
set ERRLEV=0
set SRC=%~1
set DEST=%~2

if not exist "%SRC%" (
    set ERRLEV=1
    echo:ERR: smart_copy: failed to copy "%SRC%": does not exist 1>&2
    goto :END
)


if exist "%SRC%"\* (
    echo D | xcopy /E /Y /Q "%SRC%" "%DEST%" > nul
    set ERRLEV=%ERRORLEVEL%
) else (
    echo F | xcopy /Y "%SRC%" "%DEST%" > nul
    set ERRLEV=%ERRORLEVEL%
)

if "%ERRLEV%"=="0" goto :END

:ERR
echo:ERR: smart_copy: Failed to copy "%SRC%" to "%DEST%" 1>&2

:END
endLocal & set ERRLEV=%ERRLEV%
exit /b %ERRLEV%