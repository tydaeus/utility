@echo off
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: unzip
::
:: Usage:
::      unzip ZIP_FILE [DESTINATION_FILE]
:: 
:: Wraps 7zip's unzip functionality for easier use in scripting.
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
setLocal enableDelayedExpansion
set ERRLEV=0

call find_on_path "7z.exe"

if not defined RET (
    echo:ERR: unzip: 7-zip not found 1>&2
    goto :ERR
)

set "ZIP_FILE=%~1"

if not defined ZIP_FILE (
    echo:ERR: unzip: zip file not specified 1>&2
    goto :ERR
)

set "DESTINATION_FILE=%~2"

if not defined DESTINATION_FILE (
    7z x "%ZIP_FILE%" 1>nul || goto :ERR
) else (
    7z x "%ZIP_FILE%" -o"%DESTINATION_FILE%" 1>nul || goto :ERR
)
goto :END

:ERR
if "%ERRLEV%"=="0" set ERRLEV=1
goto :END

:END
endLocal & set "ERRLEV=%ERRLEV%"
exit /b %ERRLEV%