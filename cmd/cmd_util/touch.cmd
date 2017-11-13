@Echo Off
setLocal enableDelayedExpansion

:: updates the modified timestamp of the specified file

set ERRLEV=0
set TARGET_FILE=%~1
set TARGET_DIR=%~dp1

if not exist "%TARGET_DIR%%TARGET_FILE%" (
    echo:ERR: file %TARGET_DIR%%TARGET_FILE% does not exist; please provide full path 1>&2
    goto :ERR
)

if defined ProgramFiles(x86) (
    goto :64bit
) else (
    goto :32bit
)

:64bit
:: no XP support
copy /b "%TARGET_FILE%"+,, "%TARGET_DIR%" > nul
set ERRLEV=%ERRORLEVEL%
if not "%ERRLEV%"=="0" goto :ERR

goto :END

:32bit
:: XP supported
pushd "%TARGET_DIR%"

copy /b "%TARGET_FILE%"+,, > nul
set ERRLEV=%ERRORLEVEL%
if not "%ERRLEV%"=="0" goto :ERR

popd
goto :END

goto :END

:ERR
if "%ERRLEV%"=="0" set ERRLEV=1
echo:ERR: failed to touch file %TARGET_FILE% 1>&2
:END
endLocal & set ERRLEV=%ERRLEV%
exit /b %ERRLEV%