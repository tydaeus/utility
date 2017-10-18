@Echo off
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
:: On success, exits with ERRLEV and ERRORLEVEL set to 0.
:: On failure, exits after the first failed command with ERRLEV set to that 
:: command's exit code.
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
set ERRLEV=0

set FILENAME=%~1

if not exist "%FILENAME%" (
    echo:ERR: interpret_file: file not found: "%FILENAME%" 1>&2
    goto :ERR
)

if exist "%FILENAME%"\* (
    echo:ERR: interpret_file: unable to interpret dir "%FILENAME%" 1>&2
    goto :ERR
)

call :INTERPRET_FILE || goto :ERR
goto :END

:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: Ensure errors have some default handling, allowing for a simple jump for
:: error handling for default processing
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:ERR
if "%ERRLEV%"=="0" set ERRLEV=1
goto :END

:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:END
endLocal & set ERRLEV=%ERRLEV%
exit /b %ERRLEV%


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: File interpretation loop
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:INTERPRET_FILE
setLocal enableDelayedExpansion
set LINE=

for /F "eol=# tokens=* usebackq" %%A in (`type "%FILENAME%"`) do (
    set "LINE=%%A"
    call interpret_cmd %%A || goto :INTERPRET_FILE_ERR
)
goto :INTERPRET_FILE_END

:INTERPRET_FILE_ERR
set ERRLEV=%ERRORLEVEL%
echo:ERR: intpret_file: failed to interpret %LINE% 1>&2
goto :INTERPRET_FILE_END

:INTERPRET_FILE_END
endLocal & set ERRLEV=%ERRLEV%
exit /b %ERRLEV%
