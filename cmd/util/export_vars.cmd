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
::
:: Returns the export string as EXPORT; this string will double quotes as "" to
:: preserve them during transfer, so it will be necessary to de-duplicate 
:: quotes before using the string in tunneling.
::
:: e.g:
::      endLocal & set ERRLEV=%ERRLEV% & %EXPORT:""="%
::
:: DevNote: I've used ::" to balance quotes that my syntax highlighter doesn't
:: recognize as balanced.
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

:: no var names - invalid invocation
if [%~1]==[] exit /b 1

set EXPORT=

::-----------------------------------------------------------------------------
:LOOP

set VAR_VALUE=!%~1!

::"
:: escape values
set "VAR_VALUE=!VAR_VALUE:"=""!" 
::"
set "VAR_VALUE=%VAR_VALUE:^=^^%"
::set "VAR_VALUE=%VAR_VALUE:<=^<%"
::set "VAR_VALUE=%VAR_VALUE:>=^>%"
::set "VAR_VALUE=%VAR_VALUE:&=^&%"
::set "VAR_VALUE=%VAR_VALUE:|=^|%"
::"

call :PROCESS_VAR "%~1" "%VAR_VALUE:"=""%"
::"

if [%~2]==[] goto :END
shift
goto :LOOP
::-----------------------------------------------------------------------------

:END
endLocal & set "EXPORT=%EXPORT%"
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

set "EXPORT=%EXPORT% set ""%VAR_NAME%=%VAR_VALUE%"""
endLocal & set "EXPORT=%EXPORT%"
exit /b
