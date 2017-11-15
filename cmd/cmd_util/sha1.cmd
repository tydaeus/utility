@Echo Off
:: wrap FCIV's sha1 command for easier use
:: usage: sha1 FILE1 [FILE2...]
setLocal enableDelayedExpansion
set ERRLEV=0

call find_on_path "fciv.exe"

if not defined RET (
    echo:ERR: sha1: required FCIV utility not found on path 1>&2
    goto :ERR
)

:WHILE_FILE
set "FILE=%~1"

if not defined FILE goto :END
if not exist "!FILE!" (
    echo:ERR: sha1: file !FILE! does not exist 1>&2
    goto :ERR
)

for /f "skip=3 tokens=* useBackQ" %%A in (`fciv -sha1 "!FILE!"`) do (
    echo:sha1: %%A
)

shift
goto :WHILE_FILE

:ERR
set ERRLEV=1
goto :END

:END
endLocal & set ERRLEV=%ERRLEV%
exit /b %ERRLEV%