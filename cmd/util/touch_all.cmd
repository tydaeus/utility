@Echo Off
setLocal enableDelayedExpansion

:: updates the modified timestamp of all files in the specified directory

set ERRLEV=0
set TARGET_DIR=%~1

if defined ProgramFiles(x86) (
    goto :64bit
) else (
    goto :32bit
)

:64bit
:: no XP support
for /R "%TARGET_DIR%" %%A in (*) do (
    copy /b "%%A"+,, "%TARGET_DIR%" > nul
    set ERRLEV=%ERRORLEVEL%
    if not "%ERRLEV%"=="0" goto :ERR
)
goto :END

:32bit
:: XP supported
pushd "%TARGET_DIR%"
for /R "%TARGET_DIR%" %%A in (*) do (
    copy /b "%%A"+,, > nul
    set ERRLEV=%ERRORLEVEL%
    if not "%ERRLEV%"=="0" goto :ERR
)
popd
goto :END

goto :END

:ERR
if "%ERRLEV%"=="0" set ERRLEV=1
echo:ERR: failed to touch all files in %TARGET_DIR% 1>&2
:END
endLocal & set ERRLEV=%ERRLEV%
exit /b %ERRLEV%