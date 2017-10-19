@Echo off
setLocal enableDelayedExpansion
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: install
::
:: Provides simple installer utility, by using util scripts. Modify install.cmd
:: to configure the desired installation. Typical installations can be
:: performed only by modifying the script file and the vars in install.cmd,
:: without any need to modify any of the helper scripts.
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
set SCRIPT_DIR=%~dp0
set "INSTALLER_DIR=%SCRIPT_DIR%"
set ERRLEV=0
::-----------------------------------------------------------------------------
:: Ensure that PATH points to any necessary utility scripts
::
:: precedence:
::  1. in script's dir
::  2. in script's \util subdir
::  3. in script's parent dir's \util subdir
::  4. at CMD_UTIL_HOME
::  5. elsewhere in PATH
::-----------------------------------------------------------------------------
if not "%CMD_UTIL_HOME%"=="" set PATH=%CMD_UTIL_HOME%;%PATH%
set PATH=%SCRIPT_DIR%;%SCRIPT_DIR%util\;%SCRIPT_DIR%..\util\;%PATH%

::-----------------------------------------------------------------------------
:: Config Vars - Use these to configure how the install should run
::-----------------------------------------------------------------------------

:: Identifier for subsection of log file
set "LOG_NAME=Installer Log"
:: where to save the log
set "LOG_PATH=C:\temp\installer.log"
:: name/location of script file to be interpreted
set "SCRIPT_FILE=install.cfg"
:: base path for where files will manipulated; e.g. target path for copy
set DEST_PATH=
:: base path for where files will be retrieved from; e.g. src path for copy
set RSRC_PATH=

::-----------------------------------------------------------------------------
:: Init Script Vars: these variables will be accessible and modifiable from
:: within the script as it is interpreted.
::
:: These must be named in format CMD[VAR_NAME], and can be accessed within the
:: script via {VAR_NAME}
::-----------------------------------------------------------------------------
set "CMD[DEST_PATH]=%DEST_PATH%"
set "CMD[RSRC_PATH]=%RSRC_PATH%"
set "CMD[INSTALLER_DIR]=%INSTALLER_DIR%"

::-----------------------------------------------------------------------------

echo Interpreting script %INSTALLER_DIR%%SCRIPT_FILE%

call interpret_install "%INSTALLER_DIR%%SCRIPT_FILE%"
set ERRLEV=%ERRORLEVEL%

if not "%ERRLEV%"=="0" (
    echo Install failed.
) else (
    echo Install complete.
)

pause
endLocal and set ERRLEV=%ERRLEV%
exit /b %ERRLEV%