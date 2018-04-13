@Echo Off
setLocal enableDelayedExpansion
goto :INIT
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: vshift
::
:: Shifts a param list held in VAR_NAME. The removed value gets placed in 
:: VAR_NAME.CURRENT.
:USAGE
echo:Usage:
echo:  call !SCRIPTNAME! VAR_NAME
exit /b
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:INIT
set "SCRIPTNAME=%~n0"
set "ERRLEV=0"

set "VAR_NAME=%~1"

if not defined VAR_NAME (
    echo:ERROR: Invalid Usage 1>&2
    call :USAGE
    set ERRLEV=2
    goto :ERR
)

call :VSHIFT_CURRENT !%VAR_NAME%!
call :VSHIFT_REST !%VAR_NAME%!

goto :END

:: populate !VAR_NAME!.CURRENT with the contents of the first param
:VSHIFT_CURRENT
set "!VAR_NAME!.CURRENT=%1"
exit /b

:: populate !VAR_NAME! with the contents of every param after the first
:VSHIFT_REST
setLocal
set REST=

shift
:WHILE_REST
set "CURRENT_PARAM=%1"
shift
if not defined CURRENT_PARAM goto :END_WHILE_REST

if defined REST set "REST=!REST! "
set "REST=!REST!!CURRENT_PARAM!"

goto :WHILE_REST

:END_WHILE_REST
endLocal & set "!VAR_NAME!=%REST%"
exit /b

:: provide default error messaging and error level, if errlev hasn't already been set
:ERR
if "!ERRLEV!"=="0" (
    set ERRLEV=1
    echo:ERROR: !SCRIPTNAME! failed 1>&2
)
goto :END

:END
set "CURRENT=!%VAR_NAME%.CURRENT!"
set "REST=!%VAR_NAME%!"
endLocal & set "ERRLEV=%ERRLEV%" & set "%VAR_NAME%.CURRENT=%CURRENT%" & set "%VAR_NAME%=%REST%"
exit /b %ERRLEV%