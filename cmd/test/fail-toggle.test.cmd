@Echo Off

:: alternately succeeds or fails; first call will fail

if not defined fail-toggle.test set fail-toggle.test=0

if "%fail-toggle.test%"=="0" (
    set fail-toggle.test=1
) else (
    set fail-toggle.test=0
)

exit /b %fail-toggle.test%