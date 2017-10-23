@echo off
setLocal enableDelayedExpansion

set PATH=..\util;%PATH%

call interpret_file test.script

pause