package backend;

/**
 * @author Leather128
 * @see https://github.com/Leather128/FabricEngine/
 */
class Log {
	public static var ascii_colors:Map<String, String> = [
		'black' => '\033[0;30m',
		'red' => '\033[31m',
		'green' => '\033[32m',
		'yellow' => '\033[33m',
		'blue' => '\033[1;34m',
		'magenta' => '\033[1;35m',
		'cyan' => '\033[0;36m',
		'grey' => '\033[0;37m',
		'white' => '\033[1;37m',
		'default' => '\033[0;37m' // grey apparently
	];

	public static function haxe_print(value:Dynamic, ?pos_infos:haxe.PosInfos):Void {
		if (pos_infos.customParams == null)
			print(value, null, pos_infos);
		else {
			var type:PrintType = pos_infos.customParams.copy()[0];
			pos_infos.customParams = null;
			print(Std.string(value), type, pos_infos);
		}
	}

	public static function print(message:String, ?type:PrintType = DEBUG, ?pos_infos:haxe.PosInfos):Void {
		switch (type) {
			case LOG:
				haxe_trace('${ascii_colors['default']}[   LOG   ] $message', pos_infos);
			case DEBUG: #if debug haxe_trace('${ascii_colors['green']}[  DEBUG  ] ${ascii_colors['default']}$message', pos_infos); #end
			case WARNING:
				haxe_trace('${ascii_colors['yellow']}[ WARNING ] ${ascii_colors['default']}$message', pos_infos);
			case ERROR:
				haxe_trace('${ascii_colors['red']}[  ERROR  ] ${ascii_colors['default']}$message', pos_infos);
			case SCRIPT:
				haxe_trace('${ascii_colors['cyan']}[ SCRIPTS ] ${ascii_colors['default']}$message', pos_infos);
			default:
				haxe_trace(message, pos_infos);
		}
	}

	public static var haxe_trace:haxe.Constraints.Function;
}

enum PrintType {
	LOG;
	DEBUG;
	WARNING;
	ERROR;
	SCRIPT;
}