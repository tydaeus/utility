@call "%~dp0..\cmd_util\init_simplescript.cmd" "%~dpnx0" & exit /b

StartSimpleScript

StartLog "{ScriptHome}test.log"

echo SimpleScript has started!

echo ScriptHome: {ScriptHome}
echo ScriptName: {ScriptName}
echo UtilHome: {UtilHome}
echo Root: {Root}
echo Something with (parentheses)
echo Something with (parentheses-colon):

config ERROR_MODE RETRY
call "{ScriptHome}fail-toggle.test"
config ERROR_MODE DEFAULT

export BACKUP_HOME {ScriptHome}
backup cmd_foo.cmd

filter file.txt filtered_file.tmp.txt --omit:"foo.txt"

wait 5

ResolvePath "." ".*\.cmd"
set R {ReturnValue}
echo ReturnValue: {R}

echo SimpleScript Complete

StopLog