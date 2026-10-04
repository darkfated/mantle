@echo off
setlocal

set "SRC=%~dp0"
set "DST=%~dp0mantle-clear"

if not exist "%SRC%LICENSE" (
    echo [ERROR] Source repo not found at "%SRC%"
    exit /b 1
)

if exist "%DST%" rmdir /s /q "%DST%"
mkdir "%DST%"

copy /y "%SRC%LICENSE" "%DST%\" >nul
copy /y "%SRC%README.md" "%DST%\" >nul

xcopy /e /i /q /y "%SRC%sound" "%DST%\sound" >nul
xcopy /e /i /q /y "%SRC%materials" "%DST%\materials" >nul
xcopy /e /i /q /y "%SRC%lua" "%DST%\lua" >nul

echo Done. Clean mantle created at "%DST%".
pause
