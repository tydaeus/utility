@Echo Off
setLocal enableDelayedExpansion
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: export_vars
::
:: Usage:
::		export_vars VARIABLE_NAME...
::
:: Process a list of variable names to store their names and values in a string
:: formatted for use in variable tunneling.
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

:: no var names - invalid invocation
if [%~1]==[] exit /b 1

set EXPORT=

::-----------------------------------------------------------------------------
:LOOP
call :PROCESS_VAR "%~1" "!%~1!"

if [%~2]==[] goto :END
shift
goto :LOOP
::-----------------------------------------------------------------------------

:END
echo EXPORT pre-return: !EXPORT!
endLocal & set "EXPORT=%EXPORT%"
echo EXPORT post-return: %EXPORT%
exit /b

:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: PROCESS_VAR VAR_NAME VAR_VALUE
:: Processes one variable to store its name and value in the export string.
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
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
