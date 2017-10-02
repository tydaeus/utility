@Echo Off
setLocal enableDelayedExpansion
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: eval
::
:: Usage:
::      eval "COMMAND" TARGET_VAR
::
:: Evaluates COMMAND and places the result (from stdout) into TARGET_VAR. Note
:: that if COMMAND produces multiple lines of output, only the last will be
:: preserved in TARGET_VAR.
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

set COMMAND=%~1
set "TARGET=%~2"
set RESULT=

for /f "tokens=* useBackQ" %%A in (`%COMMAND%`) do (
    set "RESULT=%%A"
)

endLocal & set "%TARGET%=%RESULT%"
exit /b