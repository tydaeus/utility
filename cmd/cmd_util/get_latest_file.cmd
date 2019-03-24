@Echo off
setLocal enableDelayedExpansion

:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: get_latest_file
::
:: Usage:
::      get_latest_file PATH FILE_PATTERN
::
:: Example:
::      get_latest_file "C:\logs\" "foo.*\.log"
::
:: Returns the most recently modified file in PATH whose name matches
:: FILE_PATTERN as RET. Note that FILE_PATTERN is processed using findstr /R,
:: so some basic regex can be used.
::
:: Sets ERRLEV and ERRORLEVEL to 1, RET to blank if no files matched.
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

set DIR_PATH=%~1
set FILE_PATTERN=%~2
set NEWEST=
set RET=
set ERRLEV=0

for /f "tokens=*" %%A in ('dir /b /od "%DIR_PATH%" ^| findstr /R "%FILE_PATTERN%"') do set NEWEST=%DIR_PATH%\%%~A

if defined NEWEST goto :SUCCESS

:ERR
set ERRLEV=1
goto :END

:SUCCESS
set RET=%NEWEST%
goto :END

:END
endLocal & set "RET=%RET%" & set ERRLEV=%ERRLEV%
exit /b %ERRLEV%
