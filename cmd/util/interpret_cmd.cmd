@Echo off
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
set FOUND=0

set COMMAND_NAME=%~1

call xshift %*
set "COMMAND=%LIST%"

:: process the command to interpret script vars
set "COMMAND=!COMMAND:{=%%CMD[!"
set "COMMAND=!COMMAND:}=]%%!"
call set "COMMAND=!COMMAND!"

:: attempt to run the named command
call :CMD_%COMMAND_NAME% %COMMAND%

:: check if the command was successfully found, error if not
if "%FOUND%"=="1" goto :COMMAND_FOUND
echo:ERR: interpret_cmd: command not recognized: "%COMMAND_NAME%" 1>&2
goto :ERR

:COMMAND_FOUND
if not "%ERRLEV%"=="0" (
    echo:ERR: interpret_cmd: failed to %COMMAND_NAME% %COMMAND% 1>&2
    goto :ERR
)
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
if defined EXPORT goto :EXPORT_END
endLocal & set ERRLEV=%ERRLEV%
exit /b %ERRLEV%

:: export variables set via the set command
:EXPORT_END
endLocal & set ERRLEV=%ERRLEV% & %EXPORT:""="%
::"
exit /b %ERRLEV%
::-----------------------------------------------------------------------------
:: Define Invokable Commands
:: 
:: DevNote: by redirecting commands through "cmd_" files, derivative
:: implementations can provide their own versions of these files for alternate
:: functionality.
::-----------------------------------------------------------------------------
:CMD_backup
echo:backup %*
call backup %*
set ERRLEV=%ERRORLEVEL%
set FOUND=1
exit /b %ERRLEV%

:CMD_CALL
echo:call %*
call %*
set ERRLEV=%ERRORLEVEL%
set FOUND=1
exit /b %ERRLEV%

:CMD_COPY
echo:copy %*
call smart_copy %*
set ERRLEV=%ERRORLEVEL%
set FOUND=1
exit /b %ERRLEV%

:CMD_DELETE
echo:delete %*
call smart_delete %*
set ERRLEV=%ERRORLEVEL%
set FOUND=1
exit /b %ERRLEV%

:CMD_ECHO
echo:%*
set FOUND=1
exit /b

:CMD_EXE
echo:exe %*
%*
set ERRLEV=%ERRORLEVEL%
set FOUND=1
exit /b %ERRLEV%

:CMD_SET
set VAR_NAME=%1
call xshift %*
set "CMD[%RET%]=%LIST%"
call export_vars CMD[%RET%]
set ERRLEV=%ERRORLEVEL%
set FOUND=1
exit /b %ERRLEV%

:CMD_TOUCH
echo:touch %*
call touch %*
set ERRLEV=%ERRORLEVEL%
set FOUND=1
exit /b %ERRLEV%

:CMD_touchAll
echo:touch_all %*
call touch_all %*
set ERRLEV=%ERRORLEVEL%
set FOUND=1
exit /b %ERRLEV%

