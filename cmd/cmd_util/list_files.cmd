@Echo Off
setLocal enableDelayedExpansion
goto :INIT

:DISPLAY_USAGE
echo: Usage:
echo:   %SCRIPT_NAME% DIR_PATH
exit /b

:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: list_files
::
:: Converts the output from `dir` into a more concise format for purposes of
:: exportability.
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

:INIT
set "SCRIPT_NAME=%~n0"
set "TARGET_DIR=%~dpnx1"
set "TARGET_DIR_NAME=%~nx1"
set ERRLEV=0
set USAGE_ERR=0
set LINE_COUNT=0
set LINE_NUM=0

if not defined TARGET_DIR (
    echo:ERR: %SCRIPT_NAME%: invalid usage 1>&2
    call :DISPLAY_USAGE
    goto :ERR
)

if not exist "!TARGET_DIR!\*" (
    echo:ERR: list_files TARGET_DIR '!TARGET_DIR!' does not exist as dir 1>&2
    goto :ERR
)

set "OUTPUT_FILE=.\!TARGET_DIR_NAME!.dir.txt"

:: count significant lines
for /f "usebackq skip=7 eol=# tokens=*" %%A in (`dir "!TARGET_DIR!" ^| findstr /n "^^"`) do (
    set /a "LINE_COUNT=!LINE_COUNT! + 1"
)
:: omit final line (directory count) as not very useful and as containing system data
set /a "LINE_COUNT=!LINE_COUNT! - 1"

echo:Directory of !TARGET_DIR_NAME!>"!OUTPUT_FILE!"
echo:>>"!OUTPUT_FILE!"

for /f "usebackq skip=7 eol=# tokens=*" %%A in (`dir "!TARGET_DIR!" ^| findstr /n "^^"`) do (
    set "LINE=%%A"
    set "LINE=!LINE:*:=!"
    if !LINE_NUM! LSS !LINE_COUNT! echo:!LINE!>>"!OUTPUT_FILE!"
    set /a "LINE_NUM=!LINE_NUM! + 1"
)

goto :END

:ERR
set ERRLEV=1
goto :END

:END
endLocal & set ERRLEV=%ERRLEV%
exit /b %ERRLEV%
