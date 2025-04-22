package modding;

import llua.Convert;
import llua.Lua;
import llua.LuaL;
import llua.State;

class LuaScript extends FlxBasic {
	public static var lua:State = null;

	public function new(file:String, ?execute:Bool = true) {
		super();

		lua = LuaL.newstate();
		LuaL.openlibs(lua);
		Lua.init_callbacks(lua);

		var result:Int = LuaL.dofile(lua, file);
		if (result != 0) {
			Lib.application.window.alert(Lua.tostring(lua, result), "Lua Error!");
			lua = null;
			return;
		}

		trace('Script Loaded Succesfully: $file');

		// Default Variables
		setVar('this', this);

		setVar('platform', PlatformUtil.getPlatform());
		setVar('version', Lib.application.meta.get('version'));

		setVar('lua', {
			version: Lua.version(),
			versionJIT: Lua.versionJIT()
		});

		// Default Functions
		setCallback('import', function(name:String, ?packagePath:String = '') {
			try {
				var str:String = '';
				if (packagePath.length > 0)
					str = packagePath + ".";

				setVar(name, Type.resolveClass(str + name));
			} catch (e:Dynamic)
				Lib.application.window.alert('Class at $name does not exist.', 'Lua Error!');
		});

		setCallback('trace', function(value:Dynamic) {
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

		// Text Functions
		setCallback("createText", function(tag:String, x:Float = 0, y:Float = 0, width:Int = 0, text:String = "", size:Int = 8) {
			var text = new FlxText(x, y, width, text, size);
			text.active = true;
			PlayState.luaText.set(tag, text);
			return FlxG.state.add(text);
		});
		setCallback("removeText", function(tag:String, splice:Bool = false) {
			var text:FlxText = getTagObject("luaText", tag);
			text.kill();
			return FlxG.state.remove(text, splice);
		});
		setCallback("reviveText", function(tag:String) {
			var text:FlxText = getTagObject("luaText", tag);
			return text.revive();
		});
		setCallback("destroyText", function(tag:String) {
			var text:FlxText = getTagObject("luaText", tag);
			return text.destroy();
		});
		setCallback("setTextColor", function(tag:String, color:String = "") {
			var text:FlxText = getTagObject("luaText", tag);
			return text.color = FlxColor.fromString("0xFF" + color.toUpperCase());
		});
		setCallback("setTextActive", function(tag:String, active:Bool) {
			var text:FlxText = getTagObject("luaText", tag);
			return text.active = active;
		});
		setCallback("setTextVisible", function(tag:String, visible:Bool) {
			var text:FlxText = getTagObject("luaText", tag);
			return text.visible = visible;
		});
		setCallback("setTextPosition", function(tag:String, x:Float, y:Float) {
			var text:FlxText = getTagObject("luaText", tag);
			return text.setPosition(x, y);
		});
		setCallback("setTextSize", function(tag:String, size:Int) {
			var text:FlxText = getTagObject("luaText", tag);
			return text.size = size;
		});
		setCallback("setTextString", function(tag:String, content:String) {
			var text:FlxText = getTagObject("luaText", tag);
			return text.text = content;
		});
		setCallback("setTextFont", function(tag:String, font:String) {
			var text:FlxText = getTagObject("luaText", tag);
			var fonts:String = font;
			if (!fonts.endsWith(".ttf") && !fonts.endsWith(".otf"))
				fonts += ".ttf";
			return text.font = Paths.font(fonts);
		});
		setCallback("setTextAlignment", function(tag:String, alignment:String) {
			var text:FlxText = getTagObject("luaText", tag);
			return text.alignment = alignment;
		});
		setCallback("setTextProperty", function(tag:String, property:String, value:Dynamic) {
			var text:FlxText = getTagObject("luaText", tag);
			Reflect.setProperty(text, property, value);
			return value;
		});
		setCallback("getTextProperty", function(tag:String, property:String) {
			var text:FlxText = getTagObject("luaText", tag);
			return Reflect.getProperty(text, property);
		});

		// Image Functions
		setCallback("createSprite", function(tag:String, x:Float = 0, y:Float = 0, image:String = "") {
			var sprite = new FlxSprite(x, y, Paths.image(image));
			sprite.active = true;
			PlayState.luaImages.set(tag, sprite);
			return FlxG.state.add(sprite);
		});
		setCallback("removeSprite", function(tag:String, splice:Bool = false) {
			var sprite:FlxSprite = getTagObject("luaImages", tag);
			sprite.kill();
			return FlxG.state.remove(sprite, splice);
		});
		setCallback("reviveSprite", function(tag:String) {
			var sprite:FlxSprite = getTagObject("luaImages", tag);
			return sprite.revive();
		});
		setCallback("destroySprite", function(tag:String) {
			var sprite:FlxSprite = getTagObject("luaImages", tag);
			return sprite.destroy();
		});
		setCallback("setSpriteActive", function(tag:String, active:Bool) {
			var sprite:FlxSprite = getTagObject("luaImages", tag);
			return sprite.active = active;
		});
		setCallback("setSpriteVisible", function(tag:String, visible:Bool) {
			var sprite:FlxSprite = getTagObject("luaImages", tag);
			return sprite.visible = visible;
		});
		setCallback("setSpritePosition", function(tag:String, x:Float, y:Float) {
			var sprite:FlxSprite = getTagObject("luaImages", tag);
			return sprite.setPosition(x, y);
		});
		setCallback("setSpriteImage", function(tag:String, image:String) {
			var sprite:FlxSprite = getTagObject("luaImages", tag);
			return sprite.loadGraphic(Paths.image(image));
		});
		setCallback("setSpriteAlpha", function(tag:String, alpha:Float) {
			var sprite:FlxSprite = getTagObject("luaImages", tag);
			return sprite.alpha = alpha;
		});
		setCallback("setSpriteColor", function(tag:String, color:String) {
			var sprite:FlxSprite = getTagObject("luaImages", tag);
			return sprite.color = FlxColor.fromString("0xFF" + color.toUpperCase());
		});
		setCallback("getSpritePosition", function(tag:String) {
			var sprite:FlxSprite = getTagObject("luaImages", tag);
			return [sprite.x, sprite.y];
		});
		setCallback("getSpriteScale", function(tag:String) {
			var sprite:FlxSprite = getTagObject("luaImages", tag);
			return sprite.scale;
		});
		setCallback("getSpriteAlpha", function(tag:String) {
			var sprite:FlxSprite = getTagObject("luaImages", tag);
			return sprite.alpha;
		});
		setCallback("getSpriteColor", function(tag:String) {
			var sprite:FlxSprite = getTagObject("luaImages", tag);
			return sprite.color;
		});
		setCallback("getSpriteFrame", function(tag:String) {
			var sprite:FlxSprite = getTagObject("luaImages", tag);
			return sprite.frame;
		});
		setCallback("getSpriteActive", function(tag:String) {
			var sprite:FlxSprite = getTagObject("luaImages", tag);
			return sprite.active;
		});
		setCallback("getSpriteVisible", function(tag:String) {
			var sprite:FlxSprite = getTagObject("luaImages", tag);
			return sprite.visible;
		});
		setCallback("makeAnim", function(tag:String, name:String, frames:Array<Int>, frameRate:Int, loop:Bool) {
			var sprite:FlxSprite = getTagObject("luaImages", tag);
			return sprite.animation.add(name, frames, frameRate, loop);
		});
		setCallback("makeAnimByPrefix", function(tag:String, name:String, prefix:String, frameRate:Int, loop:Bool) {
			var sprite:FlxSprite = getTagObject("luaImages", tag);
			return sprite.animation.addByPrefix(name, prefix, frameRate, loop);
		});
		setCallback("playAnim", function(tag:String, name:String) {
			var sprite:FlxSprite = getTagObject("luaImages", tag);
			return sprite.animation.play(name);
		});
		setCallback("stopAnim", function(tag:String) {
			var sprite:FlxSprite = getTagObject("luaImages", tag);
			return sprite.animation.stop();
		});
		setCallback("getAnimName", function(tag:String) {
			var sprite:FlxSprite = getTagObject("luaImages", tag);
			return sprite.animation.name;
		});
		setCallback("setAnimProperty", function(tag:String, property:String, value:Dynamic) {
			var sprite:FlxSprite = getTagObject("luaImages", tag);
			Reflect.setProperty(sprite.animation, property, value);
			return value;
		});
		setCallback("getAnimProperty", function(tag:String, property:String) {
			var sprite:FlxSprite = getTagObject("luaImages", tag);
			return Reflect.getProperty(sprite.animation, property);
		});
		setCallback("setSpriteProperty", function(tag:String, property:String, value:Dynamic) {
			var sprite:FlxSprite = getTagObject("luaImages", tag);
			Reflect.setProperty(sprite, property, value);
			return value;
		});
		setCallback("getSpriteProperty", function(tag:String, property:String) {
			var sprite:FlxSprite = getTagObject("luaImages", tag);
			return Reflect.getProperty(sprite, property);
		});

		// Object/Misc. Functions
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
		Lua.getglobal(lua, name);
		for (arg in args)
			Convert.toLua(lua, arg);
		Lua.pcall(lua, args.length, 0, 0);
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
		}
	}
}