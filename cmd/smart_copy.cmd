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
::  Sets ERRMSG as user-readable error string
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
set ERRLEV=0
set ERRMSG=
set SRC=%~1
set DEST=%~2

if not exist "%SRC%" (
    set ERRLEV=1
    set ERRMSG=Failed to copy "%SRC%": does not exist
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
set ERRMSG=Failed to copy "%SRC%" to "%DEST%"

:END
endLocal & set ERRLEV=%ERRLEV% & set ERRMSG=%ERRMSG%
exit /b %ERRLEV%