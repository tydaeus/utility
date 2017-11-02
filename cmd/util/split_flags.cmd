@Echo Off
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
set QUOTE="
::"

::-----
:WHILE_ARGS_REMAIN

set "CUR_ARG=%1"
if "%CUR_ARG%"=="" goto :END

:: note that we must use GOTO logic here, because file names may contain parens

:QUOTE_CHECK
:: if arg starts with quotes, it cannot be a flag, but it will disrupt the dash check
if not !CUR_ARG:~0^,1!==!QUOTE! goto :DASH_CHECK
call :ADD_ARG %CUR_ARG%
goto :CUR_ARG_PROCESSED

:DASH_CHECK
:: if arg starts with a dash, it must be a flag
if not "%CUR_ARG:~0,1%"=="-" goto :NOT_FLAG
call :ADD_FLAG %CUR_ARG%
goto :CUR_ARG_PROCESSED

:NOT_FLAG
call :ADD_ARG %CUR_ARG%
goto :CUR_ARG_PROCESSED

:CUR_ARG_PROCESSED
shift
goto :WHILE_ARGS_REMAIN
::-----

:END
endLocal & set "SIMPLE_FLAGS=%SIMPLE_FLAGS%" & set "LONG_FLAGS=%LONG_FLAGS%" & set "ARGS=%ARGS%" & set ERRLEV=%ERRLEV%
exit /b

:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: ADD_ARG
::
:: Adds an argument to the ARGS list
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:ADD_ARG
if not defined ARGS (
    set "ARGS=%*"
) else (
    set "ARGS=%ARGS% %*"
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
if not defined LONG_FLAGS (
    set PREFIX=
) else (
    set PREFIX= 
)

:: is this a long flag?
if "%FLAG:~0,2%"=="--" (
    set "LONG_FLAGS=%LONG_FLAGS%%PREFIX%%FLAG:~2%"
) else (
    set "SIMPLE_FLAGS=%SIMPLE_FLAGS%%FLAG:~1%"
)

exit /b
