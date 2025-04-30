package modding;

import llua.*;
import llua.Lua.Lua_helper;

class LuaScript extends FlxBasic {
	public static var Function_Stop:Dynamic = 1;
	public static var Function_Continue:Dynamic = 0;

	public var lua:State = null;

	private var game:PlayState;

	public function new(file:String, ?execute:Bool = true) {
		super();

		this.game = PlayState.instance;

		lua = LuaL.newstate();
		LuaL.openlibs(lua);
		Lua.init_callbacks(lua);

		try {
			var result:Dynamic = LuaL.dofile(lua, file);
			var resultStr:String = Lua.tostring(lua, result);
			if (resultStr != null && result != 0) {
				trace('lua error!!! ' + resultStr);
				Lib.application.window.alert(resultStr, "Lua Error!");
				lua = null;
				return;
			}
		} catch (e) {
			trace(e.message);
			Lib.application.window.alert(e.message, "Lua Error!");
			return;
		}

		trace('Script Loaded Succesfully: $file');

		// Default Variables
		setVar('Function_Stop', Function_Stop);
		setVar('Function_Continue', Function_Continue);

		setVar('platform', PlatformUtil.getPlatform());
		setVar('version', Lib.application.meta.get('version'));

		setVar('lua', {
			version: Lua.version(),
			versionJIT: Lua.versionJIT()
		});

		// Default Functions
		setCallback('trace', function(value:Dynamic) {
			trace(value);
		});
		setCallback('print', function(value:Dynamic) {
			trace(value);
		});

		setCallback('stopScript', function() {
			this.destroy();
		});

		setCallback("setVar", function(name:String, value:Dynamic) {
			return setVar(name, value);
		});
		setCallback("getVar", function(name:String) {
			return getVar(name);
		});
		setCallback("deleteVar", function(name:String) {
			return deleteVar(name);
		});
		setCallback("callFunction", function(name:String, args:Array<Dynamic>) {
			return callFunction(name, args);
		});

		setCallback("stdInt", function(x:Int) {
			return Std.int(x);
		});

		// PlayState Stuff
		setVar("score", game.score);
		setVar("combo", game.combo);
		setVar("misses", game.misses);
		setVar("health", game.health);
		setVar("accuracy", game.accuracy);

		setVar("curBPM", Conductor.bpm);
		setVar("bpm", PlayState.song.bpm);
		setVar("crochet", Conductor.crochet);
		setVar("stepCrochet", Conductor.stepCrochet);
		setVar("songPos", Conductor.songPosition);
		setVar("curStep", game.curStep);
		setVar("curBeat", game.curBeat);

		setCallback("addScore", function(value:Int = 0) {
			game.score += value;
		});
		setCallback("addMisses", function(value:Int = 0) {
			game.misses += value;
		});

		// Screen Stuff
		setVar("screenWidth", FlxG.width);
		setVar("screenHeight", FlxG.height);

		// Main Functions
		setCallback("createObject", function(type:String, name:String, config:Dynamic) {
			switch (type) {
				case "sprite":
					var sprite:FlxSprite = new GameSprite(config.x, config.y);
					setCodeWithCheckNull(config.image, image -> sprite.loadGraphic(Paths.image(image)));
					sprite.active = true;
					PlayState.luaImages.set(name, sprite);
				case "text":
					var text:FlxText = new FlxText(config.x, config.y, config.width, config.text, config.size);
					text.active = true;
					PlayState.luaText.set(name, text);
				default:
					var object:FlxObject = new FlxObject(config.x, config.y, config.width, config.height);
					object.active = true;
					PlayState.luaObjects.set(name, object);
			}
		});
		setCallback("addObject", function(name:String) {
			if (PlayState.luaImages.exists(name))
				PlayState.instance.add(PlayState.luaImages.get(name));
			else if (PlayState.luaText.exists(name))
				PlayState.instance.add(PlayState.luaText.get(name));
			else
				PlayState.instance.add(PlayState.luaObjects.get(name));
		});
		setCallback("removeObject", function(name:String) {
			if (PlayState.luaImages.exists(name))
				PlayState.instance.remove(PlayState.luaImages.get(name));
			else if (PlayState.luaText.exists(name))
				PlayState.instance.remove(PlayState.luaText.get(name));
			else
				PlayState.instance.remove(PlayState.luaObjects.get(name));
		});
		setCallback("insertObject", function(name:String, pos:Int = 0) {
			if (PlayState.luaImages.exists(name))
				PlayState.instance.insert(pos, PlayState.luaImages.get(name));
			else if (PlayState.luaText.exists(name))
				PlayState.instance.insert(pos, PlayState.luaText.get(name));
			else
				PlayState.instance.insert(pos, PlayState.luaObjects.get(name));
		});

		setCallback("configText", function(name:String, config:Dynamic) {
			if (PlayState.luaText.exists(name)) {
				var text:FlxText = PlayState.luaText.get(name);
				setCodeWithCheckNull(config.x, x -> text.x = x);
				setCodeWithCheckNull(config.y, y -> text.y = y);
				setCodeWithCheckNull(config.width, width -> text.width = width);
				setCodeWithCheckNull(config.text, txt -> text.text = txt);
				setCodeWithCheckNull(config.size, size -> text.size = size);
				setCodeWithCheckNull(config.color, color -> text.color = getColorName(color));
				setCodeWithCheckNull(config.alignment, align -> text.alignment = getAlignmentName(align));
				setCodeWithCheckNull(config.alpha, alpha -> text.alpha = alpha);
				setCodeWithCheckNull(config.scale, scale -> text.scale.set(scale.x, scale.y));
				setCodeWithCheckNull(config.angle, angle -> text.angle = angle);
				setCodeWithCheckNull(config.visible, visible -> text.visible = visible);
				setCodeWithCheckNull(config.active, active -> text.active = active);
				setCodeWithCheckNull(config.scrollFactor, scrollFactor -> text.scrollFactor.set(scrollFactor.x, scrollFactor.y));
				setCodeWithCheckNull(config.antialiasing, antialiasing -> text.antialiasing = antialiasing);
				setCodeWithCheckNull(config.font, font -> text.font = Paths.font(font));
				setCodeWithCheckNull(config.borderSize, borderSize -> text.borderSize = borderSize);
				setCodeWithCheckNull(config.borderColor, borderColor -> text.borderColor = getColorName(borderColor));
				setCodeWithCheckNull(config.borderStyle, borderStyle -> text.borderStyle = getBorderStyleName(borderStyle));
				setCodeWithCheckNull(config.borderQuality, borderQuality -> text.borderQuality = borderQuality);
			}
		});
		setCallback("configSprite", function(name:String, config:Dynamic) {
			if (PlayState.luaImages.exists(name)) {
				var sprite:FlxSprite = PlayState.luaImages.get(name);
				setCodeWithCheckNull(config.image, img -> sprite.loadGraphic(Paths.image(img)));
				setCodeWithCheckNull(config.x, x -> sprite.x = x);
				setCodeWithCheckNull(config.y, y -> sprite.y = y);
				setCodeWithCheckNull(config.width, width -> sprite.width = width);
				setCodeWithCheckNull(config.height, height -> sprite.height = height);
				setCodeWithCheckNull(config.alpha, alpha -> sprite.alpha = alpha);
				setCodeWithCheckNull(config.scale, scale -> sprite.scale.set(scale.x, scale.y));
				setCodeWithCheckNull(config.angle, angle -> sprite.angle = angle);
				setCodeWithCheckNull(config.visible, visible -> sprite.visible = visible);
				setCodeWithCheckNull(config.active, active -> sprite.active = active);
				setCodeWithCheckNull(config.scrollFactor, scrollFactor -> sprite.scrollFactor.set(scrollFactor.x, scrollFactor.y));
			}
		});
		setCallback("configObject", function(name:String, config:Dynamic) {
			if (PlayState.luaObjects.exists(name)) {
				var object:FlxObject = PlayState.luaObjects.get(name);
				setCodeWithCheckNull(config.x, x -> object.x = x);
				setCodeWithCheckNull(config.y, y -> object.y = y);
				setCodeWithCheckNull(config.width, width -> object.width = width);
				setCodeWithCheckNull(config.height, height -> object.height = height);
				setCodeWithCheckNull(config.angle, angle -> object.angle = angle);
				setCodeWithCheckNull(config.visible, visible -> object.visible = visible);
				setCodeWithCheckNull(config.active, active -> object.active = active);
				setCodeWithCheckNull(config.scrollFactor, scrollFactor -> object.scrollFactor.set(scrollFactor.x, scrollFactor.y));
			}
		});

		setCallback("makeAnimationSprite", function(tag:String, x:Float, y:Float, paths:String) {
			if (!PlayState.luaImages.exists(tag)) {
				var sprite = new GameSprite(x, y);
				sprite.frames = Paths.spritesheet(paths, SPARROW);
				PlayState.luaImages.set(tag, sprite);
			}
		});
		setCallback("addAnimationByPrefix", function(tag:String, name:String, prefix:String, fps:Int = 24, looped:Bool = false) {
			if (PlayState.luaImages.exists(tag)) {
				var sprite = PlayState.luaImages.get(tag);
				return sprite.animation.addByPrefix(name, prefix, fps, looped);
			}
		});
		setCallback("playAnimation", function(tag:String, name:String, force:Bool = false, rev:Bool = false, frames:Int = 0) {
			if (PlayState.luaImages.exists(tag))
				return PlayState.luaImages.get(tag).animation.play(name, force, rev, frames);
		});
		setCallback("playAnim", function(tag:String, name:String, force:Bool = false, rev:Bool = false, frames:Int = 0) {
			if (PlayState.luaImages.exists(tag))
				return PlayState.luaImages.get(tag).animation.play(name, force, rev, frames);
		});

		setCallback("playSound", function(name:String, volume:Float = 1, loop:Bool = false):FlxSound {
			return FlxG.sound.play(Paths.sound(name), volume, loop);
		});
		setCallback("playMusic", function(name:String, volume:Float = 1, loop:Bool = false) {
			return FlxG.sound.playMusic(Paths.music(name), volume, loop);
		});

		setCallback("setProperty", function(name:String, property:String, value:Dynamic) {
			if (PlayState.luaImages.exists(name)) {
				var sprite = PlayState.luaImages.get(name);
				Reflect.setProperty(sprite, property, value);
			} else if (PlayState.luaText.exists(name)) {
				var text = PlayState.luaText.get(name);
				Reflect.setProperty(text, property, value);
			} else if (PlayState.luaObjects.exists(name)) {
				var object = PlayState.luaObjects.get(name);
				Reflect.setProperty(object, property, value);
			} else {
				if (game != null)
					Reflect.setProperty(game, property, value);
			}
		});
		setCallback("getProperty", function(name:String, property:String) {
			if (PlayState.luaImages.exists(name)) {
				var sprite = PlayState.luaImages.get(name);
				return Reflect.getProperty(sprite, property);
			} else if (PlayState.luaText.exists(name)) {
				var text = PlayState.luaText.get(name);
				return Reflect.getProperty(text, property);
			} else if (PlayState.luaObjects.exists(name)) {
				var object = PlayState.luaObjects.get(name);
				return Reflect.getProperty(object, property);
			} else {
				if (game != null)
					return Reflect.getProperty(game, property);
			}
			return null;
		});

		setCallback("getInputPress", function(type:String, keyName:String) {
			switch (type) {
				case "justPressed":
					return FlxG.keys.anyJustPressed([getKeyName(keyName)]);
				case "justReleased":
					return FlxG.keys.anyJustReleased([getKeyName(keyName)]);
				case "pressed":
					return FlxG.keys.anyPressed([getKeyName(keyName)]);
				default:
					return false;
			}
		});

		if (execute)
			callFunction('create', []);
	}

	/**
	 * Call a function, in script, you will be able to code in lua script like:
	 * 
	 * ```lua
	 * -- onCreate is from where you source code like `callFunction("onCreate", []);`
	 * function onCreate()
	 * -- your lua code here...
	 * end
	 * ```
	 * @param name a function to call back
	 * @param args a function args, useful for some function need to call a args like `callFunction("onUpdate", [elapsed]);`
	 */
	public function callFunction(name:String, args:Array<Dynamic>) {
		if (lua == null)
			return Function_Continue;

		Lua.getglobal(lua, name);

		for (arg in args)
			Convert.toLua(lua, arg);

		var result:Null<Int> = Lua.pcall(lua, args.length, 1, 0);
		if (result != null && resultIsAllowed(lua, result)) {
			if (Lua.type(lua, -1) == Lua.LUA_TSTRING) {
				var error:String = Lua.tostring(lua, -1);
				if (error == 'attempt to call a nil value')
					return Function_Continue;
			}
			var conv:Dynamic = Convert.fromLua(lua, result);
			return conv;
		}
		return Function_Continue;
	}

	function resultIsAllowed(leLua:State, leResult:Null<Int>) {
		switch (Lua.type(leLua, leResult)) {
			case Lua.LUA_TNIL | Lua.LUA_TBOOLEAN | Lua.LUA_TNUMBER | Lua.LUA_TSTRING | Lua.LUA_TTABLE:
				return true;
		}
		return false;
	}

	/**
	 * Set a function, in script, you will be able to code in lua script like:
	 * ```lua
	 * function onCreate()
	 *      makeAText(90, 0, "Hi", 32); -- when on source, `makeAText` is being called by `setCallback("makeAText", <your function code>);`
	 * end
	 * ```
	 * @param name a function name
	 * @param func make them how is gonna work, like how `FlxG.resizeWindow(640, 480);`
	 * @return Lua_helper.add_callback(lua, name, func)
	 */
	public function setCallback(name:String, func:Dynamic)
		return Lua_helper.add_callback(lua, name, func);

	/**
	 * Set a variable, in script, you will be able to code in lua script like:
	 * ```lua
	 * print("version" ... VERSION) -- when `VERSION` is on source, it will be like `setVar("VERSION", "v999");`
	 * ```
	 * @param name a variable name
	 * @param value how is gonna be?, like `var version:String = "v999";`
	 */
	public function setVar(name:String, value:Dynamic) {
		if (lua == null)
			return;

		Convert.toLua(lua, value);
		Lua.setglobal(lua, name);
	}

	/**
	 * Get a variable if that exists
	 * @param name a variable you think that already exists
	 * @return return Lua.getglobal(lua, name)
	 */
	public function getVar(name:String)
		return Lua.getglobal(lua, name);

	/**
	 * Delete a variable if that exists
	 * @param name a variable you think that already exists
	 */
	public function deleteVar(name:String) {
		Lua.pushnil(lua);
		Lua.setglobal(lua, name);
	}

	function setCodeWithCheckNull<T>(value:Null<T>, setter:T->Void) {
		if (value != null)
			setter(value);
	}

	public static function getColorName(name:String) {
		switch (name) {
			case "white":
				return FlxColor.WHITE;
			case "black":
				return FlxColor.BLACK;
			case "red":
				return FlxColor.RED;
			case "green":
				return FlxColor.GREEN;
			case "blue":
				return FlxColor.BLUE;
			case "yellow":
				return FlxColor.YELLOW;
			case "purple":
				return FlxColor.PURPLE;
			case "cyan":
				return FlxColor.CYAN;
			case "gray":
				return FlxColor.GRAY;
			case "orange":
				return FlxColor.ORANGE;
			case "lime":
				return FlxColor.LIME;
			case "magenta":
				return FlxColor.MAGENTA;
			case "pink":
				return FlxColor.PINK;
			case "brown":
				return FlxColor.BROWN;
			case "transparent":
				return FlxColor.TRANSPARENT;
			case "":
				return FlxColor.WHITE;
		}
		return FlxColor.fromString(name) ?? FlxColor.WHITE;
	}

	public static function getAlignmentName(name:String) {
		switch (name) {
			case "left":
				return FlxTextAlign.LEFT;
			case "center":
				return FlxTextAlign.CENTER;
			case "right":
				return FlxTextAlign.RIGHT;
		}
		return FlxTextAlign.LEFT;
	}

	public static function getBorderStyleName(name:String) {
		switch (name) {
			case "none":
				return FlxTextBorderStyle.NONE;
			case "shadow":
				return FlxTextBorderStyle.SHADOW;
			case "outline":
				return FlxTextBorderStyle.OUTLINE;
			case "outlineFast":
				return FlxTextBorderStyle.OUTLINE_FAST;
		}
		return FlxTextBorderStyle.NONE;
	}

	public static function getKeyName(name:String) {
		switch (name.toUpperCase()) {
			case "A":
				return FlxKey.A;
			case "B":
				return FlxKey.B;
			case "C":
				return FlxKey.C;
			case "D":
				return FlxKey.D;
			case "E":
				return FlxKey.E;
			case "F":
				return FlxKey.F;
			case "G":
				return FlxKey.G;
			case "H":
				return FlxKey.H;
			case "I":
				return FlxKey.I;
			case "J":
				return FlxKey.J;
			case "K":
				return FlxKey.K;
			case "L":
				return FlxKey.L;
			case "M":
				return FlxKey.M;
			case "N":
				return FlxKey.N;
			case "O":
				return FlxKey.O;
			case "P":
				return FlxKey.P;
			case "Q":
				return FlxKey.Q;
			case "R":
				return FlxKey.R;
			case "S":
				return FlxKey.S;
			case "T":
				return FlxKey.T;
			case "U":
				return FlxKey.U;
			case "V":
				return FlxKey.V;
			case "W":
				return FlxKey.W;
			case "X":
				return FlxKey.X;
			case "Y":
				return FlxKey.Y;
			case "Z":
				return FlxKey.Z;
			case "ZERO":
				return FlxKey.ZERO;
			case "ONE":
				return FlxKey.ONE;
			case "TWO":
				return FlxKey.TWO;
			case "THREE":
				return FlxKey.THREE;
			case "FOUR":
				return FlxKey.FOUR;
			case "FIVE":
				return FlxKey.FIVE;
			case "SIX":
				return FlxKey.SIX;
			case "SEVEN":
				return FlxKey.SEVEN;
			case "EIGHT":
				return FlxKey.EIGHT;
			case "NINE":
				return FlxKey.NINE;
			case "SPACE":
				return FlxKey.SPACE;
			case "ENTER":
				return FlxKey.ENTER;
			case "ESCAPE":
				return FlxKey.ESCAPE;
			case "UP":
				return FlxKey.UP;
			case "DOWN":
				return FlxKey.DOWN;
			case "LEFT":
				return FlxKey.LEFT;
			case "RIGHT":
				return FlxKey.RIGHT;
		}

		return FlxKey.NONE;
	}

	override public function destroy() {
		if (lua != null) {
			Lua.close(lua);
			lua = null;
		} else
			return;
	}
}