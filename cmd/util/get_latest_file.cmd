@Echo off
setLocal enableDelayedExpansion

:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: get_latest_file
::
:: Usage:
::      get_latest_file PATH FILE_NAME
::
:: Example:
::      get_latest_file "C:\logs\" "foo.*\.log"
::
:: Returns the most recently modified file in PATH whose name matches 
:: FILE_NAME as RET. Note that FILE_NAME is processed using findstr, so
:: some basic regex can be used.
::
:: Sets ERRLEV and ERRORLEVEL to 1 if no files matched.
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
set DIR_PATH=%~1
set FILE_NAME=%~2
set NEWEST=
set RET=
set ERRLEV=0

for /f "tokens=*" %%A in ('dir /b /od "%DIR_PATH%" ^| findstr "%FILE_NAME%"') do set NEWEST=%DIR_PATH%\%%~A

if not ["%NEWEST%"]==[""] goto :SUCCESS

:ERR
set ERRLEV=1
goto :END

:SUCCESS
set RET=%NEWEST%
goto :END

:END
endLocal & set "RET=%RET%" & set ERRLEV=%ERRLEV%
exit /b %ERRLEV%