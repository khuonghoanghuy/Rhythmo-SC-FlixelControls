package modding;

import llua.Convert;
import llua.Lua;
import llua.LuaL;
import llua.State;

class LuaScript extends FlxBasic {
	public static var Function_Stop:Dynamic = 1;
	public static var Function_Continue:Dynamic = 0;

	public static var lua:State = null;

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
		setVar("bpm", game.song.bpm);
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

		// Text Functions
		setCallback("makeText", function(tag:String, x:Float = 0, y:Float = 0, fieldWidth:Int = 0, text:String = "", size:Int = 8) {
			if (!PlayState.luaText.exists(tag)) {
				var text = new FlxText(x, y, fieldWidth, text, size);
				text.active = true;
				PlayState.luaText.set(tag, text);
			}
		});
		setCallback("setTextSize", function(tag:String, size:Int = 8) {
			if (PlayState.luaText.exists(tag))
				return PlayState.luaText.get(tag).size = size;
			return PlayState.luaText.get(tag).size = size;
		});
		setCallback("setTextFont", function(tag:String, font:String) {
			if (PlayState.luaText.exists(tag))
				return PlayState.luaText.get(tag).font = Paths.font(font);
			return null;
		});
		setCallback("setFormat", function(tag:String, font:String, size:Int, color:Int, reAliAsText:String, reBorAsText:String, borColor:Int) {
			if (PlayState.luaText.exists(tag)) {
				var reAli:FlxTextAlign;
				switch (reAliAsText) {
					case "left":
						reAli = LEFT;
					case "center":
						reAli = CENTER;
					case "right":
						reAli = RIGHT;
					default:
						reAli = LEFT;
				}
				var reBor:FlxTextBorderStyle;
				switch (reBorAsText) {
					case "outline":
						reBor = OUTLINE;
					case "outline_fast":
						reBor = OUTLINE_FAST;
					default:
						reBor = OUTLINE;
				}
				PlayState.luaText.get(tag).setFormat(Paths.font(font), size, color, reAli, reBor, borColor);
			}
		});
		setCallback("setTextProperty", function(tag:String, property:String, value:Dynamic) {
			if (PlayState.luaText.exists(tag)) {
				var text = PlayState.luaText.get(tag);
				var propertyParts:Array<String> = property.split(".");
				if (propertyParts.length > 1) {
					var subProperty:String = propertyParts[0];
					var subValue:String = propertyParts[1];
					Reflect.setProperty(Reflect.getProperty(text, subProperty), subValue, value);
				} else
					Reflect.setProperty(text, property, value);
			}
		});
		setCallback("getTextProperty", function(tag:String, property:String) {
			var splitDot:Array<String> = property.split('.');
			var getText:Dynamic = null;
			if (splitDot.length > 1) {
				if (PlayState.luaText.exists(splitDot[0]))
					getText = PlayState.luaText.get(splitDot[0]);
				for (i in 1...splitDot.length - 1)
					getText = Reflect.getProperty(getText, splitDot[i]);
				return Reflect.getProperty(getText, splitDot[splitDot.length - 1]);
			}
			return Reflect.getProperty(getText, splitDot[splitDot.length - 1]);
		});
		setCallback("addText", function(tag:String) {
			if (PlayState.luaText.exists(tag))
				return PlayState.instance.add(PlayState.luaText.get(tag));
			return null;
		});

		// Image Functions
		setCallback("makeSprite", function(tag:String, x:Float, y:Float, paths:String) {
			if (!PlayState.luaImages.exists(tag)) {
				var sprite = new GameSprite(x, y);
				sprite.loadGraphic(Paths.image(paths));
				sprite.active = true;
				PlayState.luaImages.set(tag, sprite);
			}
		});
		setCallback("makeAnimationSprite", function(tag:String, x:Float, y:Float, paths:String) {
			if (!PlayState.luaImages.exists(tag)) {
				var sprite = new GameSprite(x, y);
				sprite.frames = Paths.spritesheet(paths, SPARROW);
				PlayState.luaImages.set(tag, sprite);
			}
		});
		setCallback("setSpriteOffset", function(tag:String, x:Float = 0, y:Float = 0) {
			if (PlayState.luaImages.exists(tag))
				return PlayState.luaImages.get(tag).offset.set(x, y);
			return null;
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
		setCallback("setSpriteProperty", function(tag:String, property:String, value:Dynamic) {
			if (PlayState.luaImages.exists(tag)) {
				var sprite = PlayState.luaImages.get(tag);
				var propertyParts:Array<String> = property.split(".");
				if (propertyParts.length > 1) {
					var subProperty:String = propertyParts[0];
					var subValue:String = propertyParts[1];
					Reflect.setProperty(Reflect.getProperty(sprite, subProperty), subValue, value);
				} else
					Reflect.setProperty(sprite, property, value);
			}
		});
		setCallback("getSpriteProperty", function(tag:String, property:String) {
			var splitDot:Array<String> = property.split('.');
			var getSprite:Dynamic = null;
			if (splitDot.length > 1) {
				if (PlayState.luaImages.exists(splitDot[0]))
					getSprite = PlayState.luaImages.get(splitDot[0]);
				for (i in 1...splitDot.length - 1)
					getSprite = Reflect.getProperty(getSprite, splitDot[i]);
				return Reflect.getProperty(getSprite, splitDot[splitDot.length - 1]);
			}
			return Reflect.getProperty(getSprite, splitDot[splitDot.length - 1]);
		});
		setCallback("addSprite", function(tag:String) {
			if (PlayState.luaImages.exists(tag))
				return PlayState.instance.add(PlayState.luaImages.get(tag));
			return null;
		});

		// Sound Functions
		setCallback("playSound", function(name:String, volume:Float = 1, loop:Bool = false):FlxSound {
			return FlxG.sound.play(Paths.sound(name), volume, loop);
		});

		setCallback("playMusic", function(name:String, volume:Float = 1, loop:Bool = false) {
			return FlxG.sound.playMusic(Paths.music(name), volume, loop);
		});

		// Object Functions
		setCallback("mouseOverlap", function(tag:String):Bool {
			var gameTag:Dynamic = null;
			if (PlayState.luaImages.exists(tag))
				gameTag = PlayState.luaImages.get(tag);
			else if (PlayState.luaText.exists(tag))
				gameTag = PlayState.luaText.get(tag);
			return FlxG.mouse.overlaps(gameTag);
		});
		setCallback("setProperty", function(tag:String, property:String, value:Dynamic) {
			var gameTag:Dynamic = null;
			if (PlayState.luaImages.exists(tag))
				gameTag = PlayState.luaImages.get(tag);
			else if (PlayState.luaText.exists(tag))
				gameTag = PlayState.luaText.get(tag);
			Reflect.setProperty(gameTag, property, value);
			return value;
		});
		setCallback("getProperty", function(tag:String, property:String) {
			var gameTag:Dynamic = null;
			if (PlayState.luaImages.exists(tag))
				gameTag = PlayState.luaImages.get(tag);
			else if (PlayState.luaText.exists(tag))
				gameTag = PlayState.luaText.get(tag);
			return Reflect.getProperty(gameTag, property);
		});
		setCallback("getTagObject", function(tagVer:String, name:String) {
			return getTagObject(tagVer, name);
		});

		// Misc. Functions
		setCallback("getPropertyFromClass", function(classes:String, value:String) {
			var splitDot:Array<String> = value.split(".");
			var getClassProperty:Dynamic = Type.resolveClass(classes);
			if (splitDot.length > 1) {
				for (i in 1...splitDot.length)
					getClassProperty = Reflect.getProperty(getClassProperty, splitDot[i - 1]);
				return Reflect.getProperty(getClassProperty, splitDot[splitDot.length - 1]);
			}
			return Reflect.getProperty(getClassProperty, value);
		});
		setCallback("setPropertyFromClass", function(classes:String, variable:String, value:Dynamic) {
			var splitDot:Array<String> = variable.split('.');
			var getClassProperty:Dynamic = Type.resolveClass(classes);
			if (splitDot.length > 1) {
				for (i in 1...splitDot.length - 1)
					getClassProperty = Reflect.getProperty(getClassProperty, splitDot[i - 1]);
				return Reflect.setProperty(getClassProperty, splitDot[splitDot.length - 1], value);
			}
			return Reflect.setProperty(getClassProperty, variable, value);
		});

		setCallback("getKeyPress", function(keyName:String) {
			return FlxG.keys.checkStatus(keyName, PRESSED);
		});
		setCallback("getKeyJustPress", function(keyName:String) {
			return FlxG.keys.checkStatus(keyName, JUST_RELEASED);
		});
		setCallback("getKeyJustRelease", function(keyName:String) {
			return FlxG.keys.checkStatus(keyName, JUST_RELEASED);
		});
		setCallback("getMousePress", function() {
			return FlxG.mouse.pressed;
		});
		setCallback("getMouseJustPress", function() {
			return FlxG.mouse.justPressed;
		});
		setCallback("getMouseJustRelease", function() {
			return FlxG.mouse.justReleased;
		});
		setCallback("setSaveData", function(name:String, value:Dynamic) {
			FlxG.save.data.set(name, value);
			FlxG.save.flush();
		});
		setCallback("getSaveData", function(name:String) {
			return FlxG.save.data.get(name);
		});
		setCallback("colorFromHex", function(color:String) {
			if (!color.startsWith('0x'))
				color = '0xff' + color;
			return Std.parseInt(color);
		});

		if (execute)
			callFunction('create', []);
	}

	function getTagObject(tagVer:String = "luaText", name:String) {
		var obj:Dynamic = null;
		switch (tagVer) {
			case "luaText":
				obj = PlayState.luaText.get(name);
			case "luaImages":
				obj = PlayState.luaImages.get(name);
		}
		return obj;
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

	override public function destroy() {
		if (lua != null) {
			Lua.close(lua);
			lua = null;
		} else
			return;
	}
}