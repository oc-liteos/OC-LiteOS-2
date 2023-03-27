@echo off

pushd %~dp0
if not exist "build" mkdir build
cd build
if not exist "users" mkdir users
if not exist "mount" mkdir mount
cd ..
echo Coping files and directories
robocopy src\bin\ build\bin > NUL
robocopy src\system\ build\system > NUL

robocopy src\system\kernel build\system\kernel >NUL
robocopy src\system\kernel\modules build\system\kernel\modules > NUL
robocopy src\system\keyboards build\system\keyboards >NUL
robocopy src\system\Lib build\system\Lib >NUL
robocopy src\system\services build\system\services >NUL

robocopy src\Lib\ build\Lib > NUL
robocopy src\config\ build\config > NUL
copy src\init.lua build\init.lua > NUL
copy README.md build\README.md > NUL
copy LICENSE build\LICENSE > NUL
echo DONE
popd
pause