@Echo Off
setLocal enableDelayedExpansion

set COMMAND=%~1
set "TARGET=%~2"
set RESULT=
set COUNT=0

for /f "tokens=* useBackQ" %%A in (`%COMMAND%`) do (
    set "%TARGET%[!COUNT!]=%%A"
    set /a count=!count!+1
)

@Echo on
set %TARGET%[
@Echo off

endLocal & set "%TARGET%=%RESULT%"
exit /b