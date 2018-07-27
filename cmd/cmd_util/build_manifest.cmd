@Echo Off
setLocal enableDelayedExpansion

:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: build_manifest
::
:: Usage:
::      build_manifest DIRPATH [MANIFEST]
::
:: Builds a manifest describing the contents of a specified directory,
:: outputting to the file named MANIFEST. 
::
:: MD5 functionality relies on a command named "md5" being present in PATH.
:: A script named "md5" in PATH may be used to provide a redirect if needed.
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

set "SCRIPT_NAME=%~n0"
set "SCRIPT_DIR=%~dp0"
set "ERRLEV=0"

set "DIRPATH=%~dpnx1"
set "MANIFEST=%~2"

if not defined DIRPATH (
    1>&2 echo:ERROR: invalid usage
    echo:Usage:
    echo:  !SCRIPT_NAME! DIRPATH
    set ERRLEV=2
    goto :ERR
)

if not exist "!DIRPATH!\*" (
    1>&2 echo:ERROR: invalid directory: '!DIRPATH!'
    set ERRLEV=3
    goto :ERR
)

if not defined MANIFEST call :GET_DEFAULT_MANIFEST "!DIRPATH!"

:: set up macro vars
call :INIT_MACROS

echo:Generating manifest for !DIRPATH! as !MANIFEST!.

echo:{ > "!MANIFEST!"
set "MF_INDENT=  "

!#MF!  "directories": [
for /f "tokens=* usebackq" %%A in (`dir /ad /b /on "%DIRPATH%"`) do call :ADD_DIR_TO_MANIFEST "%%A" "    "
!#MF!  ],

!#MF!  "files": [
for /f "tokens=* usebackq" %%A in (`dir /a-d-h /b /on "%DIRPATH%"`) do call :ADD_FILE_TO_MANIFEST "%%A" "    "
!#MF!  ]

set "MF_INDENT="
!#MF! }

goto :END

:: Default error handling. Ensures that error level is set to a non-success
:: value and a basic error message is displayed. Set ERRLEV to a nonzero value
:: prior to calling if default error messaging and level is not desired.
:ERR
if "!ERRLEV!"=="0" (
    set "ERRLEV=1"
    1>&2 echo:ERROR: !SCRIPT_NAME! failed
)
pause
goto :END

:: Finish the script and tidy up
:END
endLocal & set ERRLEV=%ERRLEV%
exit /b %ERRLEV%

:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: :INIT_MACROS
:: Setup macro vars.
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:INIT_MACROS

:: get tab character
if not defined ProgramFiles(x86) goto :GET_TAB_32BIT
for /F "delims=pR tokens=1,2" %%a in ('reg query hkcu\environment /v temp') do (
    set "#TAB=%%b"
)
goto :END_GET_TAB

:GET_TAB_32BIT
for /F "skip=4 delims=pR tokens=1,2" %%a in ('reg query hkcu\environment /v temp') do (
    set "#TAB=%%b"
)

:END_GET_TAB

:: get newline characters, for use with delayed expansion only
(set #NL=^
%=EMPTY=%
)

set "#MF=call :MF_OUT"

exit /b

:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: :GET_DEFAULT_MANIFEST
:: Sets MANIFEST to a default manifest name based on DIRPATH when passed
:: DIRPATH
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:GET_DEFAULT_MANIFEST
set "MANIFEST=%~nx1.manifest.json"
exit /b

:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: :ADD_DIR_TO_MANIFEST
:: Adds the specified dir from DIRPATH to the MANIFEST
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:ADD_DIR_TO_MANIFEST

setLocal enableDelayedExpansion
set "MF_INDENT=%~2"

!#MF! {
call :ADD_DIR_DATA "%~1" "!MF_INDENT!  "
!#MF! },

endLocal

exit /b

:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: :ADD_DIR_DATA
:: Builds the data fields that need to be added to the manifest for a given
:: file, then adds them.
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:ADD_DIR_DATA

setLocal enableDelayedExpansion

set "DIRNAME=%~1"
set "DIRPATH=!DIRPATH!\%~1"
set "MF_INDENT=%~2"

!#MF! "name": "!DIRNAME!"

:: call extend_param --output:FTIME "!DIRPATH!" t
:: !#MF! "modified": "!FTIME!",

endLocal

exit /b

:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: :ADD_FILE_TO_MANIFEST
:: Adds the specified file from DIRPATH to the MANIFEST
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:ADD_FILE_TO_MANIFEST

setLocal enableDelayedExpansion

set "MF_INDENT=%~2"

!#MF! {
call :ADD_FILE_DATA "%~1" "!MF_INDENT!  "
!#MF! },

endLocal

exit /b

:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: :ADD_FILE_DATA
:: Builds the data fields that need to be added to the manifest for a given
:: file, then adds them.
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:ADD_FILE_DATA

setLocal enableDelayedExpansion

set "FILENAME=%~1"
set "FILEPATH=!DIRPATH!\%~1"
set "MF_INDENT=%~2"

!#MF! "name": "!FILENAME!",

set "HASH=ERR: Hash Failed" :: default to an error message until hash succeeded

for /F "tokens=1 usebackq delims=, " %%A in (`md5 "!FILEPATH!"`) do (
    call :READ_HASH "%%A"
)

!#MF! "md5": "!HASH!",

:: call extend_param --output:FTIME "!FILEPATH!" t
:: !#MF! "modified": "!FTIME!",

call extend_param --output:FSIZE "!FILEPATH!" z
!#MF! "size": "!FSIZE!"

endLocal

exit /b

:: convenience subroutine to process md5 output and retrieve the hash
:READ_HASH
set "INPUT=%~1"
if not defined INPUT exit /b
:: one md5 tool outputs 'rc=' on a line other than the hash; disregard this line
if "!INPUT:~0,3!"=="rc=" exit /b
:: one md5 tool prefixes the hash with `md=`; strip this
if "!INPUT:~0,3!"=="md=" (
    set "HASH=!INPUT:~3!"
    exit /b
)
:: most md5 tools output the hash as the first token on the first line; use this
set "HASH=!INPUT!"
exit /b

:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: :MF_OUT
::
:: Outputs to the manifest
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:MF_OUT
echo:!MF_INDENT!%* >> "!MANIFEST!"
exit /b