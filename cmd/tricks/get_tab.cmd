@Echo Off
:: retrieves the tab character used as a column separator in a reg query as #TAB

:: skip if tab is already defined
if defined #TAB goto :END

if not defined ProgramFiles(x86) goto :32BIT
for /F "delims=pR tokens=1,2" %%a in ('reg query hkcu\environment /v temp') do (
    set "#TAB=%%b"
)
goto :END

:32BIT
for /F "skip=4 delims=pR tokens=1,2" %%a in ('reg query hkcu\environment /v temp') do (
    set "#TAB=%%b"
)

:END