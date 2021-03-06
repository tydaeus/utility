@Echo Off
goto :INIT
:DISPLAY_USAGE
echo: Usage:
echo:   %SCRIPT_NAME% [--output:VARAME] PARAM EXTENSIONS
exit /b

:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: extend_param
::
:: Returns the result of applying EXTENSIONS as cmd parameter extensions to 
:: PARAM via stdout. Note that '~' always gets applied.
::
:: Convenience method for processing a var as a param without needing to define
:: a specific function for the purpose.
::
:: Supports all parameter extensions listed on ss64 except for 's' and '~'.
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:INIT
setLocal enableDelayedExpansion
set "SCRIPT_NAME=%~n0"
set ERRLEV=0
set RET=
set OUTPUT_VAR=
set QUOTE="
::"

:: check for output flag
:CHECK_FLAG
set "FLAG_CHECK=%1"
:: flag cannot be wrapped in quotes
if !FLAG_CHECK:~0^,1!==!QUOTE! goto :READ_PARAM
if "!FLAG_CHECK:~0,9!"=="--output:" (
    set "OUTPUT_VAR=!FLAG_CHECK:~9!"
    shift
)

:READ_PARAM
set "PARAM=%~1"

if not defined PARAM (
    echo:ERR: invalid usage 1>&2
    call :DISPLAY_USAGE
    goto :ERR
)

:READ_EXTENSIONS
set "EXTENSIONS=%~2"

if not defined EXTENSIONS (
    set "RET=!PARAM!"
    goto :SUCCESS
)

::-----
:: read the list of extensions into vars
:WHILE_EXTENSIONS
if not defined EXTENSIONS goto :END_WHILE_EXTENSIONS
set "CUR_EXT=!EXTENSIONS:~0,1!"
set "EXTENSIONS=!EXTENSIONS:~1!"
set "EXT[!CUR_EXT!]=1"
goto :WHILE_EXTENSIONS
:END_WHILE_EXTENSIONS
::-----

for %%A in (f,d,p,n,x,$,a,t,z) do (
    if defined EXT[%%A] call :APPLY[%%A] "%PARAM%"
)

goto :SUCCESS


:SUCCESS
if not defined OUTPUT_VAR echo:!RET!
goto :END

:ERR
set ERRLEV=1
echo:ERR: %SCRIPT_NAME% failed 1>&2
goto :END

:END
if not defined OUTPUT_VAR (
    endLocal & set "ERRLEV=%ERRLEV%"
) else (
    endLocal & set "ERRLEV=%ERRLEV%" & set "%OUTPUT_VAR%=%RET%"
)
exit /b %ERRLEV%

:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:APPLY[f]
set "RET=!RET!%~f1"
exit /b

:APPLY[d]
set "RET=!RET!%~d1"
exit /b

:APPLY[p]
set "RET=!RET!%~p1"
exit /b

:APPLY[n]
set "RET=!RET!%~n1"
exit /b

:APPLY[x]
set "RET=!RET!%~x1"
exit /b

:APPLY[$]
call :ADD_SPACE
set "RET=!RET!%~$PATH:1"
exit /b

:APPLY[a]
call :ADD_SPACE
set "RET=!RET!%~a1"
exit /b

:APPLY[t]
call :ADD_SPACE
set "RET=!RET!%~t1"
exit /b

:APPLY[z]
call :ADD_SPACE
set "RET=!RET!%~z1"
exit /b

:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:ADD_SPACE
if defined RET set "RET=!RET! "
exit /b