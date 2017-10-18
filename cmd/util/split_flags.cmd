@Echo off
setLocal enableDelayedExpansion

:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: split_flags
::
:: Usage:
::      split_flags ARG1...
::
:: Processes through the passed parameter list. Any command line options
:: (prefixed with '-' or '--') will be separated from the argument list.
::
:: Due to limitations of cmd prompt argument processing, long flags that 
:: include their own parameters must be passed as --flag:"param1 param2...".
:: instead of using the '=' as per normal conventions.
::
:: Currently, no validation is performed on flags. This means that the same
:: flag may appear multiple times, and that symbols may get interpreted as 
:: flags, and that quoted text will get included.
::
:: Returns:
::      SIMPLE_FLAGS will be set to contain single-character flags, without the
::           '-', as a single string
::      LONG_FLAGS will be set to contain multi-character flags, without the 
::           '--', each as its own string
::      ARGS will be set to contain non-flag arguments
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
set SIMPLE_FLAGS=
set LONG_FLAGS=
set ARGS=
set ERRLEV=0

:WHILE_ARGS_REMAIN
set "CUR_ARG=%1"
if [%CUR_ARG%]==[] goto :END

echo:%CUR_ARG%| findstr /R "^-" > nul
if "%ERRORLEVEL%"=="0" (
    call :ADD_FLAG %CUR_ARG%
) else (
    call :ADD_ARG %CUR_ARG%
)

shift
goto :WHILE_ARGS_REMAIN

:END
endLocal & set "SIMPLE_FLAGS=%SIMPLE_FLAGS%" & set "LONG_FLAGS=%LONG_FLAGS%" & set "ARGS=%ARGS%" & set ERRLEV=%ERRLEV%
exit /b

:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: ADD_ARG
::
:: Adds an argument to the ARGS list
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:ADD_ARG
if [%ARGS%]==[] (
    set ARGS=%*
) else (
    set ARGS=%ARGS% %*
)
exit /b

:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: ADD_FLAG
::
:: Adds a flag to the appropriate flags list
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:ADD_FLAG
set "FLAG=%*"

:: setup prefix spacing
if [%LONG_FLAGS%]==[] (
    set PREFIX=
) else (
    set PREFIX= 
)

:: is this a long flag?
echo:%FLAG%| findstr /R "^--" > nul

if "%ERRORLEVEL%"=="0" (
    set "LONG_FLAGS=%LONG_FLAGS%%PREFIX%%FLAG:~2%"
) else (
    set "SIMPLE_FLAGS=%SIMPLE_FLAGS%%FLAG:~1%"
)

exit /b
