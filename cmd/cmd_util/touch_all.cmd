@Echo Off
setLocal enableDelayedExpansion

:: updates the modified timestamp of all files in the specified directory

set ERRLEV=0
set TARGET_DIR=%~f1

pushd "%TARGET_DIR%"
for /F "usebackq tokens=*" %%A in (`dir /b /a:-d "%TARGET_DIR%"`) do (
    copy /b "%%A"+,, 1>nul
    set ERRLEV=%ERRORLEVEL%
    if not "%ERRLEV%"=="0" goto :ERR
)
popd
goto :END

:ERR
if "%ERRLEV%"=="0" set ERRLEV=1
echo:ERR: failed to touch all files in %TARGET_DIR% 1>&2
:END
endLocal & set ERRLEV=%ERRLEV%
exit /b %ERRLEV%
