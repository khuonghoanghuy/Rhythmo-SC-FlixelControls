@echo off
color 0a

echo Press anything to build the game.
pause >nul
cd ..
@echo on
echo Installing dependencies
haxe -cp ./actions/libs-installer -D analyzer-optimize -main Main --interp
echo Finished!
pause