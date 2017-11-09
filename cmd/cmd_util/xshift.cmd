@Echo off
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
:: arguments), and retrieve the previous first element and the modified list.
::
:: Note that because '=' is a delineator, it will be dropped from the resulting
:: list unless enclosed in quotes(").
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
set RET=
set LIST=
set ERRLEV=0

:: verify invocation
set "CUR_ARG=%1"
if not defined CUR_ARG goto :END

set "RET=%1"

:: set first LIST elem without a space in front of it
shift
set "CUR_ARG=%1"
if not defined CUR_ARG goto :END
set "LIST=%1"

:: loop through remaining elements (if any)----------------
:WHILE_LIST_HAS_ITEMS
shift
set "CUR_ARG=%1"
if not defined CUR_ARG goto :END

set "LIST=%LIST% %1"
goto :WHILE_LIST_HAS_ITEMS
::/WHILE_LIST_HAS_ITEMS----------------------------------------------------

:END

endLocal & set "LIST=%LIST%" & set "RET=%RET%" & set ERRLEV=%ERRLEV%
exit /b %ERRLEV%