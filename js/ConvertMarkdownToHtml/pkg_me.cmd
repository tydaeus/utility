:: convenience script to package via pkg
@set "SCRIPT_DIR=%~dp0"

:: pkg doesn't like the trailing backslash, so we must cut it off
pkg -t node8.16.0-win-x64 "%SCRIPT_DIR%package.json"