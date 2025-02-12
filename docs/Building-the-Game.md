Before doing anything else, make sure to install [Haxe](https://haxe.org/download/) and [HaxeFlixel](https://haxeflixel.com/documentation/install-haxeflixel/).

## Windows
1. Download and install Microsoft Visual Studio Community.
2. On the Visual Studio installation screen, go to "Individual Components" and select the following:
    * MSVC v143 VS 2022 C++ x64/x86 build tools
    * Windows 10/11 SDK
        * You can skip this by running `msvc.bat`
        * ⚠ These will take up 4-5GB of available space on your computer.
3. Download and install [Git](https://git-scm.com/download).
4. Download the dependencies by running `setup-windows.bat`.
5. Use `haxelib run lime test windows` to build.

> [!CAUTION]
> Linux and Mac builds have not been tested! <br>
> So if something goes wrong, report it in the issues tab!

## Linux
1. Install `g++`.
2. Download and Install [Git](https://git-scm.com/download).
3. Download the dependencies by running `setup-linux-mac.sh`.
4. Use `haxelib run lime test linux` to build.

## Mac
1. Install `Xcode` to allow C++ building.
2. Download and Install [Git](https://git-scm.com/download).
3. Download the dependencies by running `setup-linux-mac.sh`.
4. Use `haxelib run lime test mac` to build.