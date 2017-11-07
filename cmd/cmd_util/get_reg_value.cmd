@Echo Off
setLocal enableDelayedExpansion
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: get_reg_value
::
:: usage:
::      get_reg_value KEY_NAME VALUE_NAME
::
:: returns:
::      V_NAME - name of value
::      V_TYPE - type
::      V_VALUE - value
:: These will all be blank if the key-value is not found.
::
:: Note that this command may take some time to run, due to the reg query
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

set KEY_NAME=%~1
set VALUE_NAME=%~2
set V_NAME=
set V_TYPE=
set V_VALUE=

if defined ProgramFiles(x86) (
    call :GET_REG_VALUE_64
) else (
    call :GET_REG_VALUE_32
)

:END
endLocal & set V_NAME=%V_NAME% & set V_TYPE=%V_TYPE% & set V_VALUE=%V_VALUE%
exit /b

:GET_REG_VALUE_64
for /F "usebackq skip=2 tokens=1-2*" %%A in (`REG QUERY "%KEY_NAME%" /v "%VALUE_NAME%" 2^>nul`) do (
    set V_NAME=%%~A
    set V_TYPE=%%~B
    set V_VALUE=%%~C
)

exit /b

:GET_REG_VALUE_32
for /F "usebackq skip=4 tokens=1-2*" %%A in (`REG QUERY "%KEY_NAME%" /v "%VALUE_NAME%" 2^>nul`) do (
    set V_NAME=%%~A
    set V_TYPE=%%~B
    set V_VALUE=%%~C
)

exit /b

