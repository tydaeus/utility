@Echo Off
setLocal enableDelayedExpansion
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: short_time
::
:: Returns the system time with punctuation stripped (via stdout)
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

set SHORT_TIME=%TIME::=%
set SHORT_TIME=%SHORT_TIME:.=%
echo %SHORT_TIME%
endLocal
exit /b