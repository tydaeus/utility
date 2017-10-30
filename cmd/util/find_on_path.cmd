@Echo Off

:: returns first match of param 1 found on PATH, blank if not found on PATH
set "RET=%~$PATH:1"
if not exist "%RET%" set RET=
