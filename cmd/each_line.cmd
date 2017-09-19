@Echo Off
setLocal enableDelayedExpansion

:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: each_line
::
:: Provides a sample implementation of a for loop that processes each line of
:: a specified file.
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

set FILE_NAME=%~1

for /F "tokens=*" %%A in ('type "%FILE_NAME%"') do call :PROCESS_LINE %%A

exit /b

:PROCESS_LINE
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: PROCESS_LINE
::
:: Performs processing for a given line. For sample implementation, we echo the
:: first 3 arguments.
::
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
setLocal

echo 1: %~1
echo 2: %~2
echo 3: %~3
echo *: %*

endLocal
exit /b