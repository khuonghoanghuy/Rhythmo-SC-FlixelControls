#if !macro
// Default Imports
import flixel.*;
import flixel.util.*;
import flixel.math.*;
import flixel.addons.display.FlxBackdrop;
import flixel.addons.display.FlxGridOverlay;
import flixel.addons.display.FlxRuntimeShader;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.group.FlxSpriteGroup;
import flixel.input.gamepad.*;
import flixel.input.keyboard.*;
import flixel.sound.FlxSound;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.ui.FlxButton;

import openfl.Lib;
import openfl.Assets;
import openfl.media.Sound;
import openfl.system.System;
import openfl.display.BitmapData;
import openfl.filters.ShaderFilter;
import lime.app.Application;

import haxe.*;
import haxe.io.Path;
import tjson.TJSON;

#if sys
import sys.*;
import sys.io.*;
#end

// Game Imports
import rhythmo.api.*;
import rhythmo.api.native.WindowsAPI;
import rhythmo.backend.*;
import rhythmo.input.Input;
import rhythmo.locale.Localization;
import rhythmo.modding.*;
import rhythmo.objects.*;
import rhythmo.objects.game.*;
import rhythmo.options.*;
import rhythmo.shaders.*;
import rhythmo.states.*;
import rhythmo.states.editors.*;
import rhythmo.states.menus.*;
import rhythmo.substates.*;
import rhythmo.util.*;

import rhythmo.Paths;
import rhythmo.SaveData;

using StringTools;
using rhythmo.util.Util;

#if !debug
@:noDebug
#end
#end