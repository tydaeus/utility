@Echo Off

goto :INIT
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: dev note: this script relies on many environment variables that persist
:: between calls, so global scope is the default.
:DISPLAY_HELP
echo:props
echo:
call :USAGE
echo:
echo: A set of commands for reading, writing, and interacting with a set of 
echo: properties (key-value pairs). This set of commands uses a large number of
echo: environment variables that begin with PROPS and relies on them persisting 
echo: across invocations if in-memory persistence is desired.
echo:
echo: Available commands:
echo:   help    displays this message.
echo:
exit /b
:USAGE
echo: Usage:
echo:   props COMMAND ARGUMENTS
exit /b
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:INIT
setLocal
set "ERRLEV=0"

set "SUBCOMMAND=%~1"

if not defined SUBCOMMAND (
    echo:ERROR: Invalid usage 1>&2
    call :USAGE
    echo:Use `props help` for more info.
    set "ERRLEV=2"
    goto :ERR
)
endLocal & set "ERRLEV=%ERRLEV%"

if not "%PROPS.INITIALIZED%"=="TRUE" call :SUBCMD_INIT

call :PROCESS_SUBCOMMAND %* || goto :ERR

goto :END

:: provide default error messaging and error level, if errlev hasn't already been set
:ERR
if "%ERRLEV%"=="0" (
    echo:ERROR: props failed 1>&2
    set "ERRLEV=1"
)
goto :END

:END
exit /b %ERRLEV%

:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: PROCESS_SUBCOMMAND
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:PROCESS_SUBCOMMAND
set "SUBCOMMAND=%*"

call vshift SUBCOMMAND

call :SUBCMD_%SUBCOMMAND.CURRENT% %SUBCOMMAND% 2>nul && goto :END_PROCESS_SUBCOMMAND
echo:ERROR: unknown subcommand '%SUBCOMMAND%. Use `props help` for help. 1>&2
set "ERRLEV=3"
goto :END_PROCESS_SUBCOMMAND


:END_PROCESS_SUBCOMMAND
exit /b %ERRLEV%

:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: SUBCMD_HELP
::
:: Displays the general help message. In future, may also provide additional
:: help for the different subcommands.
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:SUBCMD_HELP
call :DISPLAY_HELP
exit /b

:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: SUBCMD_INIT
::
:: Initializes the property set to blank status. Used internally prior to load
:: operations, and prior to any subcommand if PROPS.INITIALIZED is not
:: TRUE.
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:SUBCMD_INIT
set PROPS.LENGTH=0
set PROPS.INITIALIZED=TRUE
:: TODO: clear out PROPS.MAP
exit /b

:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: SUBCMD_LIST
::
:: Lists the contents of the property set.
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:SUBCMD_LIST
set PROPS.I=0

echo:
echo:%PROPS.LENGTH% Properties:

::For each property
:LIST_EACH_PROPERTY
if not %PROPS.I% LSS %PROPS.LENGTH% goto :END_LIST_EACH_PROPERTY

setLocal enableDelayedExpansion
echo:  %PROPS.I%: !PROPS[%PROPS.I%]!
endLocal

set /a "PROPS.I+=1"
goto :LIST_EACH_PROPERTY

:END_LIST_EACH_PROPERTY

exit /b

:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: SUBCMD_SET
::
:: props set X "123456"
:: Sets the named property to the stated value. Either updates the existing
:: listing or creates a new one.
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:SUBCMD_SET
setLocal enableDelayedExpansion
set "PROPERTY_NAME=%~1"
set "PROPERTY_VALUE=%~2"

:: detect whether we're creating a new property or updating an existing one
if not defined PROPS.MAP[%PROPERTY_NAME%] goto :SET_CREATE
goto :SET_UPDATE

:: create a new property
:SET_CREATE
echo:creating new property !PROPERTY_NAME!
:: add a new line for the property
set "LINE_NUM=!PROPS.LENGTH!"
set /a "PROPS.LENGTH+=1"
goto :END_SUBCMD_SET

:: update an existing property
:SET_UPDATE
echo:updating property !PROPERTY_NAME!
:: lookup existing line value
set "LINE_NUM=!PROPS.MAP[%PROPERTY_NAME%]!"
goto :END_SUBCMD_SET

:END_SUBCMD_SET

endLocal & ^
set "PROPS[%LINE_NUM%]=%PROPERTY_VALUE%" & ^
set "PROPS[%LINE_NUM%].NAME=%PROPERTY_NAME%" & ^
set "PROPS.MAP[%PROPERTY_NAME%]=%LINE_NUM%" & ^
set "PROPS.LENGTH=%PROPS.LENGTH%"

exit /b