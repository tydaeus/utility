@Echo Off
setLocal enableDelayedExpansion
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: xshift
::
:: Usage:
::      xshift ARG1...
::
:: Returns:
::      RET - the first item from the original list
::      LIST - a copy of the original list with its first item removed
::
:: Extended shift. Use to perform a shift on a space-separated list (ie 
:: arguments), and retrieve the previous first element and the modified list
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
set RET=
set LIST=

:: verify invocation
if [%1]==[] (
    echo ERR: xshift invalid invocation 1>&2
    echo Usage: xshift ARG1...
    exit /b 1
)

set "RET=%1"

:: set first LIST elem without a space in front of it
shift
if [%1]==[] goto :END
set "LIST=%1"

:: loop through remaining elements (if any)----------------
:LOOP
shift
if [%1]==[] goto :END

set "LIST=%LIST% %1"
goto :LOOP
::/LOOP----------------------------------------------------

:END
endLocal & set "LIST=%LIST%" & set "RET=%RET%"
exit /b