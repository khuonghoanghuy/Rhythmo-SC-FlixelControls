package modding;

import cpp.RawPointer;
import hxluajit.LuaJIT;
import hxluajit.Lua;
import hxluajit.LuaL;
import hxluajit.Types.Lua_State;
import hxluajit.wrapper.LuaUtils;

// UNFINISHED!!
// i have no idea if this works
class LuaScript {
    public static var vm:Null<RawPointer<Lua_State>> = LuaL.newstate();

    public function new(file:String):Void {
        LuaL.openLibs(vm);
        LuaUtils.doString(vm, Paths.getText(Paths.lua(file)));

        LuaUtils.addFunction(vm, 'trace', function(value:Dynamic) {
            trace(value);
        });

        Lua.close(vm);
        vm = null;
    }

    public static function callFunction(funcName:String, args:Array<Dynamic>) {
        return LuaUtils.callFunctionByName(vm, funcName, args);
    }
}