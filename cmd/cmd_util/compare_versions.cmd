@Echo Off
setLocal enableDelayedExpansion
goto :INIT
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: compare_versions
::
:: Compares two version number strings to determine if the first is earlier,
:: the same, or later. Note that these strings are assumed to be numeric, with
:: dot or space separation. Other characters may cause unexpected results.
::
:: Output is a negative number if the first version is earlier, 0 if the 
:: versions are equivalent, or a positive number if the first version is later.
::
:: Output will be printed to stdout unless the "output" option is used.
:: 
:: Options:
::  --output:VAR_NAME
::      Output will be stored in VAR_NAME instead of echoed to stdout.
::
:USAGE
echo: Usage:
echo:   compare_versions [--output:VAR_NAME] VERSION_A VERSION_B
exit /b
::
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

:INIT
set "ERRLEV=0"
set "SCRIPTNAME=%~n0"
set "OUTPUT_VAR="

:: parse any command-line options
:WHILE_OPTIONS
set "CUR_PARAM=%~1"
if not defined CUR_PARAM goto :USAGE_ERR
if not "!CUR_PARAM:~0,1!"=="-" goto :READ_PARAMS
call :PARSE_OPTION "!CUR_PARAM!" || goto :USAGE_ERR
shift
goto :WHILE_OPTIONS

:: read the required params
:READ_PARAMS
set "VERSION_A=%~1"
set "VERSION_B=%~2"
set "COMPARATOR="

if not defined VERSION_A goto :USAGE_ERR
if not defined VERSION_B goto :USAGE_ERR

:: convert '.' separation to space separation
set "VERSION_A=!VERSION_A:.= !"
set "VERSION_B=!VERSION_B:.= !"

:: Loop through the numbers in the version strings
:DO_WHILE_NUMBERS
call :SHIFTV VERSION_A
call :SHIFTV VERSION_B

set "A=!VERSION_A.CURRENT!"
set "B=!VERSION_B.CURRENT!"

::----Fill in 0's if only one string still has numbers; we're equal if neither has numbers
if defined A goto :A_DEFINED
if defined B (
    set "A=0"
    goto :BOTH_DEFINED
) else (
    set "COMPARATOR=0"
    goto :END_WHILE_NUMBERS
)

:A_DEFINED
if not defined B set "B=0"
:BOTH_DEFINED

set /a "COMPARATOR=A-B"

:: we're done if A and B are not equal; must continue if they are
if !COMPARATOR! EQU 0 goto :DO_WHILE_NUMBERS

:END_WHILE_NUMBERS
if not defined OUTPUT_VAR echo:!COMPARATOR!
if defined OUTPUT_VAR set "!OUTPUT_VAR!=!COMPARATOR!"
goto :END

:USAGE_ERR
echo:ERROR:Invalid Usage 1>&2
call :USAGE
goto :ERR

:ERR
set ERRLEV=1
echo:ERROR: !SCRIPTNAME! failed 1>&2
goto :END

:END
if not defined OUTPUT_VAR (
    endLocal & set "ERRLEV=%ERRLEV%"
) else (
    endLocal & set "ERRLEV=%ERRLEV%" & set "%OUTPUT_VAR%=%COMPARATOR%"
)
exit /b %ERRLEV%

:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: SHIFTV
::
:: Usage:
::      call :SHIFTV VAR_NAME
:: Shifts a param list held in VAR_NAME. The removed value gets placed in 
:: VAR_NAME.CURRENT.
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:SHIFTV
set "VAR_NAME=%~1"

if not defined VAR_NAME (
    echo:ERROR: SHIFTV called without VAR_NAME specified 1>&2
    goto :SHIFTV_ERR
)

call :SHIFTV_CURRENT !%VAR_NAME%!
call :SHIFTV_REST !%VAR_NAME%!

goto :SHIFTV_END

:: populate !VAR_NAME!.CURRENT with the contents of the first param
:SHIFTV_CURRENT
set "!VAR_NAME!.CURRENT=%1"
exit /b

:: populate !VAR_NAME! with the contents of every param after the first
:SHIFTV_REST
setLocal
set REST=

shift
:WHILE_REST
set "CURRENT_PARAM=%1"
shift
if not defined CURRENT_PARAM goto :END_WHILE_REST

if defined REST set "REST=!REST! "
set "REST=!REST!!CURRENT_PARAM!"

goto :WHILE_REST

:END_WHILE_REST
endLocal & set "!VAR_NAME!=%REST%"
exit /b

:SHIFTV_ERR
set ERRLEV=1
echo:ERROR: failed in SHIFTV 1>&2
goto :END

:SHIFTV_END
exit /b %ERRLEV%

:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: PARSE_OPTION
::
:: Parses a command-line option. Currently only --output:VAR_NAME is supported.
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:PARSE_OPTION
set "OPTION=%~1"
if not "!OPTION:~0,9!"=="--output:" (
    echo:ERROR:Unrecognized option: !OPTION! 1>&2
    exit /b 1
)

set "OUTPUT_VAR=!OPTION:~9!"

exit /b
