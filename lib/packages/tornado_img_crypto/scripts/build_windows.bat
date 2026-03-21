@echo off
echo Building Tornado Crypto for Windows...

REM Create build directory
if not exist "build_windows" mkdir build_windows
cd build_windows

echo Configuring with CMake...
cmake .. ^
    -DCMAKE_BUILD_TYPE=Release ^
    -DCMAKE_TOOLCHAIN_FILE=C:\dev\downloaded\vcpkg\scripts\buildsystems\vcpkg.cmake ^
    -DVCPKG_TARGET_TRIPLET=x64-windows

if %ERRORLEVEL% neq 0 (
    echo CMake configuration failed!
    pause
    exit /b 1
)

echo Building...
cmake --build . --config Release

if %ERRORLEVEL% neq 0 (
    echo Build failed!
    pause
    exit /b 1
)

echo Build successful!
echo Copying DLL to parent directory...
copy Release\tornado_crypto.dll ..\tornado_crypto.dll

echo Build completed successfully!
pause