package rhythmo.util;

/**
 * Utility used to return a specific platform for conditional pusposes.
 * @author Joalor64
 */
class PlatformUtil
{
	/**
	 * Returns the currrent platform the game is running on.
	 * @return The current platform.
	 */
	public static function getPlatform():String
	{
		#if windows
		return 'windows';
		#elseif linux
		return 'linux';
		#elseif mac
		return 'mac';
		#elseif neko
		return 'neko';
		#elseif html5
		return 'browser';
		#elseif android
		return 'android';
		#elseif hl
		return 'hl';
		#elseif ios
		return 'ios';
		#elseif flash
		return 'flash';
		#else
		return 'unknown';
		#end
	}
}
