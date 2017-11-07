@Echo off
set RET=

if exist "%~1"\* (
    set RET=1
) else (
    set RET=0
)

exit /b