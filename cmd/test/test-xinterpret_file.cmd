@echo off
setLocal enableDelayedExpansion

set PATH=..\util;%PATH%

call xinterpret_file test.script

pause