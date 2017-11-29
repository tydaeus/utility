@Echo off
setLocal enableDelayedExpansion

:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: backup
::
:: Usage:
::      backup TARGET [NAME]
::
:: Makes a copy of TARGET as [timestamp]NAME.bak. This backup will be located
:: at BACKUP_HOME if defined, target's parent directory otherwise.
::
:: Uses filename from TARGET if NAME is not specified.
::
:: BACKUP_HOME will be created, if necessary.
::
:: Does nothing if TARGET does not exist.
::
:: Depends on several of the utility commands.
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

set ERRLEVEL=0
set TARGET=%~1
set TARGET_PATH=%~dp1
set TARGET_NAME=%~nx1
set OUTPUT_NAME=%~2

call :READ_PARAMS

if defined BACKUP_HOME set "TARGET_PATH=%BACKUP_HOME%\"

call eval "short_date" SDATE
call eval "short_time" STIME
set "TIMESTAMP=[%SDATE%-%STIME%]"

if exist "%TARGET%" (
    call smart_copy "%TARGET%" "%TARGET_PATH%%TIMESTAMP%%OUTPUT_NAME%.bak" || goto :ERR
) else (
    echo:backup skipped: %TARGET% does not exist
)

goto :END

:ERR
set ERRLEVEL=1
echo:ERR: failed to backup %TARGET% 1>&2
goto :END

:END
endLocal & set ERRLEVEL=%ERRLEVEL%
exit /b %ERRLEVEL%

:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: READ_PARAMS 
::
:: Process the params to ensure they're set appropriately. Ensure our 
:: parameters are not screwy.
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:READ_PARAMS
set BAD_TARGET=0

:: if OUTPUT_NAME was not passed, set it based on TARGET_NAME
if not defined OUTPUT_NAME set "OUTPUT_NAME=!TARGET_NAME!"

:: if TARGET ends in '\', TARGET_NAME will be blank, so we'll need to strip off
:: the '\' and use the end of the path
if not defined OUTPUT_NAME (
    set BAD_TARGET=1
    set "OUTPUT_NAME=!TARGET_PATH:~0,-1!"
    call extend_param --output:OUTPUT_NAME "!OUTPUT_NAME!" nx
)

:: if TARGET ends in '\', TARGET_PATH will be the targeted dir. We don't want
:: to attempt to copy the backup into a targeted directory, so we need to go
:: up one level
if %BAD_TARGET%==1 (
    set "TARGET_PATH=!TARGET_PATH!..\"
)

exit /b
