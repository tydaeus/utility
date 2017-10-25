@call ..\util\init_simplescript.cmd "%~dpnx0" & exit /b

StartSimpleScript

echo SimpleScript has started!

echo ScriptHome: {ScriptHome}
echo ScriptName: {ScriptName}
echo UtilHome: {UtilHome}
echo Root: {Root}

copy foo