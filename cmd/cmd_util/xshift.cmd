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
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
set RET=
set LIST=
set ERRLEV=0
set QUOTE="
::"

set "CUR_ARG=%1"
if not defined CUR_ARG goto :END

set "LIST=%*"

call str_len !CUR_ARG! || goto :ERR
set "LIST=!LIST:~%RET%!" || goto :ERR
set "RET=!CUR_ARG!"

:: strip leading spaces
::-----
:WHILE_LEADING_SPACE
:: quote as first char will disrupt space check
if !CUR_ARG:~0^,1!==!QUOTE! goto :END
if not "!LIST:~0,1!"==" " goto :END
set "LIST=!LIST:~1!"
goto :WHILE_LEADING_SPACE
::-----

:ERR
set ERRLEV=1
echo:ERR: xshift failed
goto :END

:END
endLocal & set "LIST=%LIST%" & set "RET=%RET%" & set ERRLEV=%ERRLEV%
exit /b %ERRLEV%