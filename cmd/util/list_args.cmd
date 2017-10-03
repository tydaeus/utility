@Echo off
setLocal enableDelayedExpansion
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: list_args
::
:: Usage:
::      list_args ARG1...
::
:: Returns:
::      LIST - a copy of the argument list
::
:: Useful for capturing all arguments for a command minus %0, via:
::      list_args %*
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

:: verify invocation
if [%1]==[] (
    echo ERR: list_args invalid invocation 1>&2
    echo Usage: list_args ARG1...
    exit /b 1
)

:: set first LIST elem without a space in front of it
set "LIST=%1"

:: loop through remaining elements (if any)----------------
:LOOP
shift
if [%1]==[] goto :END

set "LIST=%LIST% %1"
goto :LOOP
::/LOOP----------------------------------------------------

:END
endLocal & set "LIST=%LIST%"
exit /b