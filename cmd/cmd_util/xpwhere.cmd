@Echo Off
setLocal enableDelayedExpansion

::TODO - test against command name with spaces
::TODO - test appropriate precedence of full-path provided cmd
::TODO - enforce that command is found in path order

set extension=%~x1
set PATH=.;%PATH%
set FOUND=0
set ERRLEV=1
set FOUND_PATH=

:: assume we'll need to guess at the actual extension
set CHECK=EXTENSION_INFER

:: extension known to be one of (.exe,.bat,.cmd) makes life easier
if "%extension%"==".exe" set CHECK=EXT_KNOWN
if "%extension%"==".bat" set CHECK=EXT_KNOWN
if "%extension%"==".cmd" set CHECK=EXT_KNOWN

call :%CHECK% "%~1"

if [%FOUND%]==[1] (
    echo %FOUND_PATH%
    set ERRLEV=0
) else (
    echo Command not found.
)

endLocal & set ERRLEV=%ERRLEV%
exit /b %ERRLEV%


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:EXT_KNOWN
set FOUND_PATH=%~$PATH:1
if not ["%FOUND_PATH%"]==[""] set FOUND=1
exit /b

:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: to infer extension, we need to check against  several possibilities
:EXTENSION_INFER

:: 1st: no added extension
call :ATTEMPT_MATCH "%~1"
if %FOUND%==1 exit /b

:: 2nd: try .exe
call :ATTEMPT_MATCH "%~1.exe"
if %FOUND%==1 exit /b

:: 3rd: try .cmd
call :ATTEMPT_MATCH "%~1.cmd"
if %FOUND%==1 exit /b

:: 4th: try .bat
call :ATTEMPT_MATCH "%~1.bat"
if %FOUND%==1 exit /b

exit /b

:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:ATTEMPT_MATCH
set "FOUND_PATH=%~$PATH:1"
if not ["%FOUND_PATH%"]==[""] set FOUND=1
exit /b