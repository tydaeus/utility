@Echo Off
setLocal enableDelayedExpansion
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: interpret_file
::
:: Usage:
::      interpret_file FILE
:: 
:: Acts as a simplified script interpreter, thereby allowing the performance
:: of common sequences of steps from a config file instead of needing to write
:: custom cmd scripts.
::
:: On success, exits with ERRLEV and ERRORLEVEL set to 0, with ERRMSG blank.
:: On failure, exits after the first failed command with ERRLEV set to that 
:: command's exit code, and ERRMSG set to a description of the error that 
:: occurred (if available).
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
set ERRLEV=0
set ERRMSG=

set FILENAME=%~1

if not exist "%FILENAME%" (
    set ERRMSG=file not found: "%FILENAME%"
    goto :ERR
)

if exist "%FILENAME%"\* (
    set ERRMSG=file is dir: "%FILENAME%"
    goto :ERR
)

call :INTERPRET_FILE || goto :ERR
goto :END

:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: Ensure errors have some default handling, allowing for a simple jump for
:: error handling for default processing
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:ERR
if "%ERRMSG%"=="" set ERRMSG=unknown error occurred
if "%ERRLEV%"=="0" set ERRLEV=1
goto :END

:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:END
endLocal & set ERRLEV=%ERRLEV% & set ERRMSG=%ERRMSG%
exit /b %ERRLEV%


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: File interpretation loop
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:INTERPRET_FILE

for /F "tokens=*" %%A in ('type "%FILENAME%"') do (
    call interpret_cmd %%A || goto :INTERPRET_FILE_ERR
)
goto :INTERPRET_FILE_END

:INTERPRET_FILE_ERR
set ERRLEV=%ERRORLEVEL%
:INTERPRET_FILE_END
exit /b %ERRLEV%
