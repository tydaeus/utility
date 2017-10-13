@Echo Off
setLocal enableDelayedExpansion

:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: split_simple_flags
::
:: Usage:
::      split_simple_flags ARG1...
::
:: Processes through the passed parameter list. Any simple command line options
:: (single letters prefixed with '-', alone or grouped) will be separated from
:: the argument list.
::
:: Currently, no validation is performed on flags. This means that the same
:: flag may appear multiple times, and that symbols may get interpreted as 
:: flags, and that quoted text will get included.
::
:: Returns:
::      FLAGS will be set to contain all flags, without the '-', as a single 
::            string
::      ARGS will be set to contain non-flag arguments
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
set FLAGS=
set ARGS=
set ERRLEV=0

:LOOP
set "CUR_ARG=%1"
if [%CUR_ARG%]==[] goto :END

echo %CUR_ARG% | findstr /R "^-[^-]" > nul
if "%ERRORLEVEL%"=="0" (
    set "FLAGS=%FLAGS%%CUR_ARG:-=%"
) else (
    call :ADD_ARG %CUR_ARG%
)

shift
goto :LOOP


:END
echo FLAGS: %FLAGS%
echo ARGS: %ARGS%
endLocal & set "FLAGS=%FLAGS%" & set "ARGS=%ARGS%" & set ERRLEV=%ERRLEV%
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