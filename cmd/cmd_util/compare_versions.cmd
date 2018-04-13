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
:: Missing positions will be treated as zeros; e.g. 1.2 is equivalent to 1.2.0.
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
call vshift VERSION_A
call vshift VERSION_B

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
