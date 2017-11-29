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

if defined BACKUP_HOME set "TARGET_PATH=%BACKUP_HOME%\"

call :BUILD_OUTPUT_NAME

call eval "short_date" SDATE
call eval "short_time" STIME
set "TIMESTAMP=[%SDATE%-%STIME%]"

if exist "%TARGET%" (
    call smart_copy "%TARGET%" "%TARGET_PATH%%TIMESTAMP%%OUTPUT_NAME%.bak" > nul || goto :ERR
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
:: ensure we have a good name for the output backup file
:BUILD_OUTPUT_NAME

if not defined OUTPUT_NAME set "OUTPUT_NAME=!TARGET_NAME!"
:: if TARGET_PATH ends in '\', TARGET_NAME will be blank, so we'll need to 
:: strip that off and use the end of the path
if not defined OUTPUT_NAME (
    set OUTPUT_NAME=!TARGET_PATH:~0,-1!
    call extend_param --output:OUTPUT_NAME "!OUTPUT_NAME!" nx
)
exit /b
