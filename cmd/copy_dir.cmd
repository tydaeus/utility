:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: COPY_DIR
::
:: USAGE:
::      COPY_DIR SRC_DIR DEST_DIR
::
:: Copies the specified dir to the specified destination. Must specify full 
:: path.
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
@Echo Off
setLocal enableDelayedExpansion

set ERRLEVEL=0
set SRC_DIR=%~1
set TARGET_DIR=%~2
set FILE_NAME=%~fx1

echo Copying %FILE_NAME%...
echo D | xcopy /E /Y /Q "%SRC_DIR%" "%TARGET_DIR%" > nul

if "%ERRORLEVEL%"=="0" goto :COPY_DIR_END

:COPY_DIR_ERR
set ERRLEVEL=1
echo ERROR: failed to copy %SRC_DIR%
:COPY_DIR_END
endLocal & set ERRLEVEL=%ERRLEVEL%
exit /b %ERRLEVEL%