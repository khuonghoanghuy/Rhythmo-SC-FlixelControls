package modding;

import crowplexus.iris.Iris;
import crowplexus.iris.IrisConfig.RawIrisConfig;
import crowplexus.hscript.Interp.LocalVar;

class Hscript extends Iris {
	public var locals(get, set):Map<String, LocalVar>;

	function get_locals():Map<String, crowplexus.hscript.LocalVar> {
		var result:Map<String, crowplexus.hscript.LocalVar> = new Map();
		@:privateAccess
		for (key in interp.locals.keys()) {
			result.set(key, {r: interp.locals.get(key).r, const: interp.locals.get(key).const});
		}
		return result;
	}

	function set_locals(local:Map<String, crowplexus.hscript.LocalVar>) {
		@:privateAccess
		interp.locals = local;
		return local;
	}

	public static var Function_Stop:Dynamic = 1;
	public static var Function_Continue:Dynamic = 0;

	public function new(file:String) {
		final rawConfig:RawIrisConfig = {
			name: file,
			autoPreset: true,
			autoRun: true
		}
		super(Paths.getText(file), rawConfig);

		// Default Variables
		set('this', this);

		set('Function_Stop', Function_Stop);
		set('Function_Continue', Function_Continue);

		set('platform', PlatformUtil.getPlatform());
		set('version', Lib.application.meta.get('version'));

		// Default Functions
		set('import', function(daClass:String, ?asDa:String) { // For backwards compatibility
			final splitClassName:Array<String> = [for (e in daClass.split('.')) e.trim()];
			final className:String = splitClassName.join('.');
			final daClass:Class<Dynamic> = Type.resolveClass(className);
			final daEnum:Enum<Dynamic> = Type.resolveEnum(className);

			if (daClass == null && daEnum == null)
				Lib.application.window.alert('Class / Enum at $className does not exist.', 'Hscript Error!');
			else {
				if (daEnum != null) {
					var daEnumField = {};
					for (daConstructor in daEnum.getConstructors())
						Reflect.setField(daEnumField, daConstructor, daEnum.createByName(daConstructor));

					if (asDa != null && asDa != '')
						set(asDa, daEnumField);
					else
						set(splitClassName[splitClassName.length - 1], daEnumField);
				} else {
					if (asDa != null && asDa != '')
						set(asDa, daClass);
					else
						set(splitClassName[splitClassName.length - 1], daClass);
				}
			}
		});

		set('trace', function(value:Dynamic) {
			trace(value);
		});

		set('importScript', function(source:String) {
			var name:String = StringTools.replace(source, '.', '/');
			var script:Hscript = new Hscript(Paths.script(name));
			script.execute();
			return script.getAll();
		});

		set('stopScript', function() {
			this.destroy();
		});

		// Haxe
		set('Array', Array);
		set('Bool', Bool);
		set('Date', Date);
		set('DateTools', DateTools);
		set('Dynamic', Dynamic);
		set('EReg', EReg);
		#if sys
		set('File', File);
		set('FileSystem', FileSystem);
		#end
		set('Float', Float);
		set('Int', Int);
		set('Json', Json);
		set('Lambda', Lambda);
		set('Math', Math);
		set('Path', Path);
		set('Reflect', Reflect);
		set('Std', Std);
		set('StringBuf', StringBuf);
		set('String', String);
		set('StringTools', StringTools);
		#if sys
		set('Sys', Sys);
		#end
		set('TJSON', TJSON);
		set('Type', Type);
		set('Xml', Xml);

		set('createThread', function(func:Void->Void) {
			#if sys
			sys.thread.Thread.create(() -> {
				func();
			});
			#else
			func();
			#end
		});

		// OpenFL
		set('Assets', Assets);
		set('BitmapData', BitmapData);
		set('Lib', Lib);
		set('ShaderFilter', ShaderFilter);
		set('Sound', Sound);

		// Flixel
		set('FlxAxes', getFlxAxes());
		set('FlxBackdrop', FlxBackdrop);
		set('FlxBasic', FlxBasic);
		set('FlxCamera', FlxCamera);
		set('FlxCameraFollowStyle', getFlxCameraFollowStyle());
		set('FlxColor', getFlxColor());
		set('FlxEase', FlxEase);
		set('FlxG', FlxG);
		set('FlxGroup', FlxGroup);
		set('FlxKey', getFlxKey());
		set('FlxMath', FlxMath);
		set('FlxObject', FlxObject);
		set('FlxRuntimeShader', FlxRuntimeShader);
		set('FlxSound', FlxSound);
		set('FlxSprite', FlxSprite);
		set('FlxSpriteGroup', FlxSpriteGroup);
		set('FlxText', FlxText);
		set('FlxTextAlign', getFlxTextAlign());
		set('FlxTextBorderStyle', getFlxTextBorderStyle());
		set('FlxTimer', FlxTimer);
		set('FlxTween', FlxTween);
		set('FlxTypedGroup', FlxTypedGroup);
		set('createTypedGroup', function(?variable) {
			return variable = new FlxTypedGroup<Dynamic>();
		});
		set('createSpriteGroup', function(?variable) {
			return variable = new FlxSpriteGroup();
		});

		// State Stuff
		set('add', FlxG.state.add);
		set('remove', FlxG.state.remove);
		set('insert', FlxG.state.insert);
		set('members', FlxG.state.members);
		set('state', FlxG.state);

		// Rhythmo
		set('Achievements', Achievements);
		set('Bar', Bar);
		set('Conductor', Conductor);
		#if FUTURE_DISCORD_RPC
		set('DiscordClient', DiscordClient);
		#end
		set('ExtendableState', ExtendableState);
		set('ExtendableSubState', ExtendableSubState);
		set('GameSprite', GameSprite);
		set('HighScore', HighScore);
		set('Input', Input);
		set('Localization', Localization);
		set('Main', Main);
		#if FUTURE_POLYMOD
		set('ModHandler', ModHandler);
		#end
		set('Note', Note);
		set('Paths', Paths);
		set('PlayState', PlayState);
		set('Rating', Rating);
		set('SaveData', SaveData);
		set('ScriptedState', ScriptedState);
		set('ScriptedSubState', ScriptedSubState);
		set('Song', Song);
		set('Utilities', Utilities);

		set('game', PlayState.instance);

		execute();
	}

	public function callFunction(funcName:String, funcArgs:Array<Dynamic>) {
		if (funcName == null || !exists(funcName))
			return null;
		return call(funcName, funcArgs);
	}

	public function getAll():Dynamic {
		var balls:Dynamic = {};

		for (i in locals.keys())
			Reflect.setField(balls, i, get(i));
		for (i in interp.variables.keys())
			Reflect.setField(balls, i, get(i));

		return balls;
	}

	public function getFlxColor() {
		return {
			// colors
			"BLACK": FlxColor.BLACK,
			"BLUE": FlxColor.BLUE,
			"BROWN": FlxColor.BROWN,
			"CYAN": FlxColor.CYAN,
			"GRAY": FlxColor.GRAY,
			"GREEN": FlxColor.GREEN,
			"LIME": FlxColor.LIME,
			"MAGENTA": FlxColor.MAGENTA,
			"ORANGE": FlxColor.ORANGE,
			"PINK": FlxColor.PINK,
			"PURPLE": FlxColor.PURPLE,
			"RED": FlxColor.RED,
			"TRANSPARENT": FlxColor.TRANSPARENT,
			"WHITE": FlxColor.WHITE,
			"YELLOW": FlxColor.YELLOW,

			// functions
			"add": FlxColor.add,
			"fromCMYK": FlxColor.fromCMYK,
			"fromHSB": FlxColor.fromHSB,
			"fromHSL": FlxColor.fromHSL,
			"fromInt": FlxColor.fromInt,
			"fromRGB": FlxColor.fromRGB,
			"fromRGBFloat": FlxColor.fromRGBFloat,
			"fromString": FlxColor.fromString,
			"interpolate": FlxColor.interpolate,
			"to24Bit": function(color:Int) {
				return color & 0xffffff;
			}
		};
	}

	public static function getFlxKey() {
		return {
			'ANY': -2,
			'NONE': -1,
			'A': 65,
			'B': 66,
			'C': 67,
			'D': 68,
			'E': 69,
			'F': 70,
			'G': 71,
			'H': 72,
			'I': 73,
			'J': 74,
			'K': 75,
			'L': 76,
			'M': 77,
			'N': 78,
			'O': 79,
			'P': 80,
			'Q': 81,
			'R': 82,
			'S': 83,
			'T': 84,
			'U': 85,
			'V': 86,
			'W': 87,
			'X': 88,
			'Y': 89,
			'Z': 90,
			'ZERO': 48,
			'ONE': 49,
			'TWO': 50,
			'THREE': 51,
			'FOUR': 52,
			'FIVE': 53,
			'SIX': 54,
			'SEVEN': 55,
			'EIGHT': 56,
			'NINE': 57,
			'PAGEUP': 33,
			'PAGEDOWN': 34,
			'HOME': 36,
			'END': 35,
			'INSERT': 45,
			'ESCAPE': 27,
			'MINUS': 189,
			'PLUS': 187,
			'DELETE': 46,
			'BACKSPACE': 8,
			'LBRACKET': 219,
			'RBRACKET': 221,
			'BACKSLASH': 220,
			'CAPSLOCK': 20,
			'SEMICOLON': 186,
			'QUOTE': 222,
			'ENTER': 13,
			'SHIFT': 16,
			'COMMA': 188,
			'PERIOD': 190,
			'SLASH': 191,
			'GRAVEACCENT': 192,
			'CONTROL': 17,
			'ALT': 18,
			'SPACE': 32,
			'UP': 38,
			'DOWN': 40,
			'LEFT': 37,
			'RIGHT': 39,
			'TAB': 9,
			'PRINTSCREEN': 301,
			'F1': 112,
			'F2': 113,
			'F3': 114,
			'F4': 115,
			'F5': 116,
			'F6': 117,
			'F7': 118,
			'F8': 119,
			'F9': 120,
			'F10': 121,
			'F11': 122,
			'F12': 123,
			'NUMPADZERO': 96,
			'NUMPADONE': 97,
			'NUMPADTWO': 98,
			'NUMPADTHREE': 99,
			'NUMPADFOUR': 100,
			'NUMPADFIVE': 101,
			'NUMPADSIX': 102,
			'NUMPADSEVEN': 103,
			'NUMPADEIGHT': 104,
			'NUMPADNINE': 105,
			'NUMPADMINUS': 109,
			'NUMPADPLUS': 107,
			'NUMPADPERIOD': 110,
			'NUMPADMULTIPLY': 106,

			'fromStringMap': FlxKey.fromStringMap,
			'toStringMap': FlxKey.toStringMap,
			'fromString': FlxKey.fromString,
			'toString': function(key:Int) {
				return FlxKey.toStringMap.get(key);
			}
		};
	}

	public function getFlxCameraFollowStyle() {
		return {
			"LOCKON": FlxCamera.FlxCameraFollowStyle.LOCKON,
			"PLATFORMER": FlxCamera.FlxCameraFollowStyle.PLATFORMER,
			"TOPDOWN": FlxCamera.FlxCameraFollowStyle.TOPDOWN,
			"TOPDOWN_TIGHT": FlxCamera.FlxCameraFollowStyle.TOPDOWN_TIGHT,
			"SCREEN_BY_SCREEN": FlxCamera.FlxCameraFollowStyle.SCREEN_BY_SCREEN,
			"NO_DEAD_ZONE": FlxCamera.FlxCameraFollowStyle.NO_DEAD_ZONE
		};
	}

	public function getFlxTextAlign() {
		return {
			"LEFT": FlxTextAlign.LEFT,
			"CENTER": FlxTextAlign.CENTER,
			"RIGHT": FlxTextAlign.RIGHT,
			"JUSTIFY": FlxTextAlign.JUSTIFY
		};
	}

	public function getFlxTextBorderStyle() {
		return {
			"NONE": FlxTextBorderStyle.NONE,
			"SHADOW": FlxTextBorderStyle.SHADOW,
			"OUTLINE": FlxTextBorderStyle.OUTLINE,
			"OUTLINE_FAST": FlxTextBorderStyle.OUTLINE_FAST
		};
	}

	public function getFlxAxes() {
		return {
			"X": FlxAxes.X,
			"Y": FlxAxes.Y,
			"XY": FlxAxes.XY
		};
	}
}