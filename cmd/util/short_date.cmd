@Echo Off
setLocal enableDelayedExpansion

set SPLIT_DATE=%DATE:/= %

call :REARRANGE_DATE %SPLIT_DATE%

echo %RETURN%

endLocal
exit /b

:REARRANGE_DATE
set RETURN=%4%2%3
exit /b