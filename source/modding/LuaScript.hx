package modding;

import llua.Convert;
import llua.Lua;
import llua.LuaL;
import llua.State;

class LuaScript extends FlxBasic {
	public static var lua:State;

	public function new(file:String) {
		super();

		lua = LuaL.newstate();
		LuaL.openlibs(lua);
		Lua.init_callbacks(lua);

		setCallback("trace", function(value:Dynamic) {
			trace(value);
		});

		try {
			var result:Dynamic = LuaL.dofile(lua, file);
			var resultStr:String = Lua.tostring(lua, result);
			if (resultStr != null && result != 0) {
				trace('Lua Error: ' + resultStr);
				Lib.application.window.alert(resultStr, "Error!");
				lua = null;
				return;
			}
		} catch (e) {
			trace(e.message);
			Lib.application.window.alert(e.message, "Error!");
			return;
		}

		trace('Script Loaded Succesfully: $file');

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
		Lua.getglobal(lua, name);
		for (arg in args)
			Convert.toLua(lua, arg);
		Lua.pcall(lua, args.length, 0, 0);
	}

	/**
	 * Set a function, in script, you will be able to code in lua script like:
	 * ```lua
	 * function onCreate()
	 *      makeAText(90, 0, "Hi", 32); -- when on source, `makeAText` is being called by `setFunction("makeAText", <your function code>);`
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
}