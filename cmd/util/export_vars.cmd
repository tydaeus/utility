@Echo Off
setLocal enableDelayedExpansion

set EXPORT=

if [%~1]==[] exit /b 1

:LOOP
call :PROCESS_VAR "%~1" "!%~1!"

if [%~2]==[] goto :END
shift
goto :LOOP

:END
echo EXPORT pre-return: !EXPORT!
endLocal & set "EXPORT=%EXPORT%"
echo EXPORT post-return: %EXPORT%
exit /b

:PROCESS_VAR
setLocal

if not "%EXPORT%"=="" set "EXPORT=%EXPORT% ^&"

set VAR_NAME=%~1
set VAR_VALUE=%~2
echo Processing %VAR_NAME%=%VAR_VALUE%

set "EXPORT=%EXPORT% set ""%VAR_NAME%=%VAR_VALUE%"""
echo EXPORT after processing: %EXPORT%
endLocal & set "EXPORT=%EXPORT%"
exit /b
