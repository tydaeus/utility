@call "%~dp0..\cmd_util\init_simplescript.cmd" "%~dpnx0" & exit /b

StartSimpleScript

StartLog "{ScriptHome}test.log"

echo SimpleScript has started!

echo ScriptHome: {ScriptHome}
echo ScriptName: {ScriptName}
echo UtilHome: {UtilHome}
echo Root: {Root}
echo Something with (parentheses)

export BACKUP_HOME {ScriptHome}
backup cmd_foo.cmd

filter file.txt filtered_file.tmp.txt --omit:"foo.txt"

wait 5

set R {ReturnValue}
echo ReturnValue: {R}

echo SimpleScript Complete

StopLog