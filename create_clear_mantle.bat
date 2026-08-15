@echo off
setlocal

set "SRC=%~dp0."
set "DST=%~dp0mantle-clear"

if not exist "%SRC%\LICENSE" (
    echo [ERROR] Source repo not found at "%SRC%"
    exit /b 1
)

if exist "%DST%" (
    echo Deleting old "%DST%"...
    rmdir /s /q "%DST%"
)

echo Creating "%DST%"...
mkdir "%DST%"

echo Copying LICENSE...
copy /y "%SRC%\LICENSE" "%DST%\LICENSE" >nul

echo Copying README.md...
copy /y "%SRC%\README.md" "%DST%\README.md" >nul

echo Copying sound...
xcopy /e /i /q /y "%SRC%\sound" "%DST%\sound" >nul

echo Copying materials...
xcopy /e /i /q /y "%SRC%\materials" "%DST%\materials" >nul

echo Copying lua...
xcopy /e /i /q /y "%SRC%\lua" "%DST%\lua" >nul

echo.
echo Done. Clean mantle created at "%DST%".
echo.
pause
endlocal
