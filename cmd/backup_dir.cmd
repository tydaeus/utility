@Echo off
setLocal enableDelayedExpansion

:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: BACKUP_DIR
::
:: Usage:
::      BACKUP_DIR TARGET_DIR
::
:: Renames TARGET_DIR to TARGET_DIR.bak, removing any pre-existing 
:: TARGET_DIR.bak. TARGET_DIR must be named with full filepath, wrapped in
:: quotes if any spaces exist in path or dirname.
::
:: This can be easily modified to use %DATE% and %TIME% to create timestamped
:: backups instead of keeping just one .bak backup.
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

set ERRLEVEL=0
set TARGET_DIR=%~1
set TARGET_NAME=%~nx1

if exist "%TARGET_DIR%.bak" (
    rd /S /Q "%TARGET_DIR%.bak" || goto :BACKUP_DIR_ERR
)

if exist "%TARGET_DIR%" (
    move "%TARGET_DIR%" "%TARGET_DIR%.bak" > nul || goto :BACKUP_DIR_ERR
)

goto :BACKUP_DIR_END

:BACKUP_DIR_ERR
set ERRLEVEL=1
echo ERROR: failed to backup %TARGET_DIR%
:BACKUP_DIR_END
endLocal & set ERRLEVEL=%ERRLEVEL%
exit /b %ERRLEVEL%