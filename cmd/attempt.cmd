::-----------------------------------------------------------------------------
:: attempt
:: 
:: This helper cmd wraps the specified command to:
::      1. echo that the command is being performed before beginning
::      2. call the command
::      3. echo that the command has succeeded or failed
::      4. exit with the command's ERRORLEVEL as its exit code, and with 
::         ERRORLEVEL copied into env var ERRCODE
::
:: Use to "attempt" to run a specified command, echo its success or failure,
:: then continue with script execution (optionally branching for error)
::
:: Options start with dash, and must be specified prior to command to attempt:
::      -n specify a name for what is being attempted (as next argument). 
::         Defaults to the first word of the command.
::
:: Sample Usage
::      call attempt -n "Do Something" do_something.cmd || goto :END
::-----------------------------------------------------------------------------
@ECHO off

:: cannot perform this within a local scope, b/c we may want the results of the
:: script to exist in the environment

set ERRCODE=0

::-----------------------------------------------------------------------------
:: Determine what the proper name for the attempted command is
::-----------------------------------------------------------------------------
:getCommandName
set commandName=%~nx1

:: check for the -n flag
if not ["%commandName%"]==["-n"] goto getCommandContent
:: use the first argument after the -n as the commandName
shift
set commandName=%~1
:: can't use manually specified commandName as part of the command
shift

::-----------------------------------------------------------------------------
:: Extract the content of the command to attempt
::-----------------------------------------------------------------------------
:getCommandContent

set params=%1

:beginCommandContentLoop
shift
if [%1]==[] goto :endCommandContentLoop
set params=%params% %1
goto :beginCommandContentLoop

:endCommandContentLoop

::-----------------------------------------------------------------------------
:: Attempt the command
::-----------------------------------------------------------------------------
echo attempting "%commandName%"
call %params%
set ERRCODE=%ERRORLEVEL%

if %ERRCODE% NEQ 0 (
    echo Failed to perform step "%commandName%"
) else (
    echo "%commandName%" complete
)

::-----------------------------------------------------------------------------
:: Exit Appropriately
::-----------------------------------------------------------------------------

exit /B %ERRCODE%