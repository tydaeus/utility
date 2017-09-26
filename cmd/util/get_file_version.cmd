@echo off
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: get_file_version
::
:: usage:
::      get_file_version EXE_PATH
::
:: Echoes the version number of the named file (if it exists) to stdout.
::
:: Note that this command may take some time to run, due to the wmic query
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

setLocal enableDelayedExpansion
set "EXE_PATH=%~1"
set "EXE_PATH=%EXE_PATH:\=\\%"


for /f "usebackq delims=" %%a in (`"WMIC DATAFILE WHERE name='%EXE_PATH%' get Version /format:Textvaluelist"`) do (
    for /f "delims=" %%# in ("%%a") do set "%%#"
)

echo %version%

endLocal