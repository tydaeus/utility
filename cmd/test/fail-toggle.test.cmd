@Echo Off

:: alternately succeeds or fails; first call will fail
:: set fail-toggle.test to 0 before calling to trigger failure, 1 to trigger success

if not defined fail-toggle.test set fail-toggle.test=0

if "%fail-toggle.test%"=="0" (
    set fail-toggle.test=1
) else (
    set fail-toggle.test=0
)

exit /b %fail-toggle.test%