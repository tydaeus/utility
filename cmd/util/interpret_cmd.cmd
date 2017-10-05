@Echo Off
setLocal enableDelayedExpansion
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: interpret_cmd
::
:: Interprets a single simplified command statement. Kept as separate file for
:: simplification.
::
:: DevNote: individual command subroutines will receive the original invocation
:: params. %1 will be the command name, %2 will be param 1, etc.
:: DevNote: individual commands must set FOUND=1 to indicate that the command
:: was found, otherwise they will be interpreted as not found.
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
set ERRLEV=0
set ERRMSG=
set FOUND=0

set COMMAND_NAME=%~1

call xshift %*
set "COMMAND=%LIST%"

:: attempt to run the named command
call :CMD_%COMMAND_NAME% %COMMAND%

:: check if the command was successfully found, error if not
if "%FOUND%"=="1" goto :COMMAND_FOUND
set ERRMSG=command not recognized: "%COMMAND_NAME%"
goto :ERR

:COMMAND_FOUND
if not "%ERRLEV%"=="0" (
    set ERRMSG=ERR: failed to %COMMAND%
    goto :ERR
)
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
if not "%ERRMSG%"=="" echo %ERRMSG% 1>&2
endLocal & set ERRLEV=%ERRLEV% & set "ERRMSG=%ERRMSG%"
exit /b %ERRLEV%

::-----------------------------------------------------------------------------
:: Define Invokable Commands
:: 
:: DevNote: by redirecting commands through "cmd_" files, derivative
:: implementations can provide their own versions of these files for alternate
:: functionality.
::-----------------------------------------------------------------------------

:CMD_COPY
call cmd_copy %*
set ERRLEV=%ERRORLEVEL%
set FOUND=1
exit /b %ERRLEV%

:CMD_ECHO
call cmd_echo %*
set FOUND=1
exit /b
