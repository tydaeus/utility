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
:: EXPORT does not clear any previous values of var EXPORT (allowing multiple
:: consecutive calls to build the string); this means EXPORT must get cleared
:: manually before/after usage if you don't want it to get cluttered.
::
:: e.g:
::      endLocal & set ERRLEV=%ERRLEV% & %EXPORT:""="%
::
:: DevNote: I've used ::" to balance quotes that my syntax highlighter doesn't
:: recognize as balanced.
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

:: no var names - invalid invocation
set "CUR_VAR=%~1"
if not defined CUR_VAR exit /b 1

:: deliberately leaving EXPORT containing its previous value, so that 
:: export_vars can be used multiple times

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
set "VAR_VALUE=%VAR_VALUE:&=^&%"
::set "VAR_VALUE=%VAR_VALUE:|=^|%"
::"

call :PROCESS_VAR "%~1" "%VAR_VALUE:"=""%"
::"

set "CUR_VAR=%~2"
if not defined CUR_VAR goto :END
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
setLocal enableDelayedExpansion

if defined EXPORT (
    set "EXPORT=!EXPORT! ^&"
)

set VAR_NAME=%~1
set VAR_VALUE=%~2

set "EXPORT=!EXPORT! set ""!VAR_NAME!=!VAR_VALUE!"""
endLocal & set "EXPORT=%EXPORT%"
exit /b
