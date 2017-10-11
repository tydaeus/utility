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
set FOUND=0

if not defined DEST_PATH set DEST_PATH=
if not defined RSRC_PATH set RSRC_PATH=

set COMMAND_NAME=%~1

call xshift %*
set "COMMAND=%LIST%"

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
endLocal & set ERRLEV=%ERRLEV%
exit /b %ERRLEV%

::-----------------------------------------------------------------------------
:: Define Invokable Commands
:: 
:: DevNote: by redirecting commands through "cmd_" files, derivative
:: implementations can provide their own versions of these files for alternate
:: functionality.
::-----------------------------------------------------------------------------

:CMD_COPY
echo copying %~1 to %~2
call cmd_copy "%RSRC_PATH%%~1" "%DEST_PATH%%~2"
set ERRLEV=%ERRORLEVEL%
set FOUND=1
exit /b %ERRLEV%

:CMD_CALL
echo calling script %~1
call "%~1"
set ERRLEV=%ERRORLEVEL%
set FOUND=1
exit /b %ERRLEV%

:CMD_ECHO
call cmd_echo %*
set FOUND=1
exit /b

:CMD_backup
echo backing up %~1
call backup "%DEST_PATH%%~1"
set ERRLEV=%ERRORLEVEL%
set FOUND=1
exit /b %ERRLEV%

:CMD_touchAll
call touch_all "%DEST_PATH%%~1"
set ERRLEV=%ERRORLEVEL%
set FOUND=1
exit /b %ERRLEV%

:CMD_DELETE
echo deleting %~1
call smart_delete "%DEST_PATH%%~1"
set ERRLEV=%ERRORLEVEL%
set FOUND=1
exit /b %ERRLEV%