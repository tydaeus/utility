@call "%~dp0..\cmd_util\init_simplescript.cmd" "%~dpnx0" & exit /b

StartSimpleScript

echo SimpleScript has started!

echo ScriptHome: {ScriptHome}
echo ScriptName: {ScriptName}
echo UtilHome: {UtilHome}
echo Root: {Root}

export BACKUP_HOME {ScriptHome}
backup cmd_foo.cmd

filter file.txt --omit:".*\.xml" filtered_file.txt

echo SimpleScript Complete
