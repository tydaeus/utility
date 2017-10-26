@Echo Off

call :RQDC %1
call :SQCD %1
call :DELAYED_EXPANSION %1

echo:Brackets:
if [%1]==[] (
	echo:  empty
) else (
	echo:  not empty
)

echo:Quotes:
if "%1"=="" (
	echo:  empty
) else (
	echo:  not empty
)

echo:Quotes in brackets:
if ["%1"]==[""] (
	echo:  empty
) else (
	echo:  not empty
)


echo:Defined
set "VAR=%1"
if not defined VAR (
	echo:  empty
) else (
	echo:  not empty
)

echo:~Quotes:
if "%~1" == "" (
	echo:  empty
) else (
	echo:  not empty
)

echo:Replace Quotes:
set "VAR=%1"
set "VAR=%VAR:"=%"
::"
if "%VAR%"=="" (
	echo:  empty
) else (
	echo:  not empty
)

:RQDC
echo:Replace Quotes with defined check
set "VAR=%1"
if not defined VAR (
	echo:  empty
	exit /b
)
set "VAR=%VAR:"=%"
::"
if "%VAR%"=="" (
	echo:  empty
) else (
	echo:  not empty
)
exit /b

:SQCD
echo:Strip quotes and check if defined
set "VAR=%~1"
if not defined VAR (
	echo:  empty
) else (
	echo:  not empty
)
exit /b

:DELAYED_EXPANSION
echo:Delayed Expansion
set "param1=%~1"
setlocal EnableDelayedExpansion
if "!param1!"=="" (
	echo:  empty
) else (
	echo: not empty
)
endLocal
exit /b
