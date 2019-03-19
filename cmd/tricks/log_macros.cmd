:: this should be added to a script with setLocal EnableDelayedExpansion

:: replace OUTPUT_LOG value with desired logging location
set "OUTPUT_LOG=C:\temp\output.log"
set "#ERROR=call :ERROR_OUT "
set "#WARN=call :WARN_OUT "
set "#LOG=call :LOG_OUT "

:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: ERROR_OUT
:: Convenience function to display and log error messages
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:ERROR_OUT
echo:ERROR: %* >> "!OUTPUT_LOG!"
echo:ERROR: %* 1>&2
exit /b

:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: WARN_OUT
:: Convenience function to display and log warning messages
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:WARN_OUT
echo:WARN: %* >> "!OUTPUT_LOG!"
echo:WARN: %* 1>&2
exit /b


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: LOG_OUT
:: Convenience function to display and log messages
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:LOG_OUT
echo:%* >> "!OUTPUT_LOG!"
echo:%*
exit /b
