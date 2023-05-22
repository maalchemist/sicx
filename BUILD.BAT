@cd /d "%~dp0"

cd .\x32
call BUILD.BAT 0
call LIB.BAT 0
cd ..\

cd .\x64
call BUILD.BAT 0
call LIB.BAT 0
cd ..\

call COPY_TEST_LIST.BAT 0

pause
