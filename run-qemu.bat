@echo off
setlocal

echo BasicKernel QEMU Runner
echo ----------------------

REM Try to find QEMU in common installation paths
set QEMU_FOUND=0
set QEMU_PATHS=^
    "C:\Program Files\qemu\qemu-system-i386.exe" ^
    "C:\Program Files (x86)\qemu\qemu-system-i386.exe" ^
    "C:\qemu\qemu-system-i386.exe"

for %%Q in (%QEMU_PATHS%) do (
    if exist %%Q (
        echo Found QEMU at: %%Q
        set QEMU_PATH=%%Q
        set QEMU_FOUND=1
        goto :found
    )
)

:not_found
if %QEMU_FOUND%==0 (
    echo QEMU not found in common locations.
    echo Please enter the full path to qemu-system-i386.exe:
    set /p QEMU_PATH=
    
    if not exist "%QEMU_PATH%" (
        echo Error: The specified path does not exist.
        echo Please download and install QEMU from https://www.qemu.org/download/#windows
        exit /b 1
    )
)

:found
echo Running kernel with QEMU...
if exist "kernel.elf" (
    "%QEMU_PATH%" -kernel kernel.elf
) else (
    echo Error: kernel.elf not found. Please build the kernel first with 'make'.
    exit /b 1
)

echo.
echo Press any key to exit...
pause >nul
endlocal
