@ECHO off

:: checks if arg 1 contains arg 2
:: if contained, sets RET to 1, otherwise sets RET to 0
setLocal EnableDelayedExpansion

set ARG1=%~1
set ARG2=%~2
set RET=

if not "x!ARG1:%ARG2%=!"=="x%ARG1%" (
    set RET=1
) else (
    set RET=0
)

endlocal & set RET=%RET%