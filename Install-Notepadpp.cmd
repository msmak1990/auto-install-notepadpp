@echo off
rem 2020-11-16 Sukri Created.

rem script name.
set "script_name=Install-Notepadpp.ps1"

rem script directory.
set "script_directory=%~dp0"

rem execute PS1 script.
powershell -executionpolicy bypass -file "%script_directory%%script_name%"

rem pause, press any key to exit.
pause