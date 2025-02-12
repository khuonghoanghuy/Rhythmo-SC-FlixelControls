#!/bin/sh
# Setup for Linux/Mac devices
# Make you've installed Haxe prior to running this file
echo "Installing dependencies"
haxe -cp ./actions/libs-installer -D analyzer-optimize -main Libraries --interp
echo "Done!"