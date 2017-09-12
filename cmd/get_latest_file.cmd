@Echo off
setLocal enableDelayedExpansion

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

set DIR_PATH=%~f1
set FILE_NAME=%~2

:: temporarily switch to target dir, otherwise calculating full path doesn't work
pushd %DIR_PATH%

for /f "tokens=*" %%A in ('dir /b /od "%DIR_PATH%" ^| findstr "%FILE_NAME%"') do set NEWEST=%%~fA

set RET=%NEWEST%

popd

endLocal & set RET=%RET%