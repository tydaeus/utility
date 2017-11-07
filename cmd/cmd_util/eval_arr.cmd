@Echo Off
setLocal enableDelayedExpansion
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: eval_arr
::
:: Usage:
::      eval_arr "COMMAND" TARGET_VAR
::
:: Evaluates COMMAND and places the result (from stdout) into TARGET_VAR as a
:: pseudo-array. INCOMPLETE.
::
:: TODO: properly export resulting target array.
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

set COMMAND=%~1
set "TARGET=%~2"
set RESULT=
set COUNT=0

if "%TARGET_VAR%"=="" (
    echo Invalid usage. Please specify a target. 1>&2
    exit /b 1
)

for /f "tokens=* useBackQ" %%A in (`%COMMAND%`) do (
    set "%TARGET%[!COUNT!]=%%A"
    set /a count=!count!+1
)

@Echo on
set %TARGET%[
@Echo off

endLocal & set "%TARGET%=%RESULT%"
exit /b