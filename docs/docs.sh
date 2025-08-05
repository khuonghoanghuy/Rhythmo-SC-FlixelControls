#! /bin/sh

haxe docs/docs.hxml
haxelib run dox -i docs -o pages --title "Rhythmo Documentation" -D source-path https://github.com/JoaTH-Team/Rhythmo-SC/tree/main/source