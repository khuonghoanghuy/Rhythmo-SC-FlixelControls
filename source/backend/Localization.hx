package backend;

#if openfl
import openfl.system.Capabilities;
#end

import hx_arabic_shaper.ArabicReshaper;
import hx_arabic_shaper.bidi.UBA;

/**
 * A simple localization system.
 * Please credit me if you use it!
 * @author Joalor64GH
 */
class Localization {
	private static final DEFAULT_DIR:String = "languages";

	private static var data:Map<String, Dynamic>;
	private static var currentLanguage:String;

	public static var DEFAULT_FONT:String = "vcr";

	public static var DEFAULT_LANGUAGE:String = "en";
	public static var directory:String = DEFAULT_DIR;

	public static var systemLanguage(get, never):String;

	public static function get_systemLanguage() {
		#if openfl
		return Capabilities.language;
		#else
		return throw "This Variable is for OpenFl only!";
		#end
	}

	public static function loadLanguages() {
		data = new Map<String, Dynamic>();

		var path:String = Paths.txt("languages/languagesList");
		if (Paths.exists(path)) {
			var listContent:String = Paths.getText(path);
			var languages:Array<String> = listContent.split('\n');

			for (language in languages) {
				var languageData:Dynamic = loadLanguageData(language.trim());
				data.set(language, languageData);
			}
		}

		var config = ArabicReshaper.getDefaultConfig();
		config.delete_harakat = true;
		ArabicReshaper.init(config);
	}

	private static function loadLanguageData(language:String):Dynamic {
		var jsonContent:String;

		try {
			jsonContent = Paths.getText(path(language));
		} catch (e:Dynamic) {
			trace('language file not found: $e');
			jsonContent = Paths.getText(path(DEFAULT_LANGUAGE));
		}

		return TJSON.parse(jsonContent);
	}

	public static function switchLanguage(newLanguage:String) {
		if (newLanguage == currentLanguage)
			return;

		var languageData:Dynamic = loadLanguageData(newLanguage);

		currentLanguage = newLanguage;
		data.set(newLanguage, languageData);
		trace('Language changed to $currentLanguage');
	}

	public static function get(key:String, ?language:String):String {
		var targetLanguage:String = language != null ? language : currentLanguage;
		var languageData = data.get(targetLanguage);

		if (data != null && data.exists(targetLanguage)) {
			if (languageData != null && Reflect.hasField(languageData, key)) {
				var field:String = Reflect.field(languageData, key);
				return (targetLanguage == "ar") ? shapeArabicText(field) : field;
			}
		}

		return 'missing key: $key';
	}

	public static function getFont():String {
		if (data != null && data.exists(currentLanguage)) {
			var languageData = data.get(currentLanguage);

			if (Reflect.hasField(languageData, "customFont")) {
				var font = Reflect.field(languageData, "customFont");
				if (font != null && font != "")
					return font;
			}
		}

		return DEFAULT_FONT;
	}

	private static function path(language:String) {
		var localDir = Path.join([directory, language + ".json"]);
		var path:String = Paths.file(localDir);
		return path;
	}

	// for arabic text
	private static function shapeArabicText(text:String):String {
		var shaped = ArabicReshaper.reshape(text);
		return UBA.display(shaped);
	}

	public static function dispose() {
		ArabicReshaper.dispose();
	}
}

class Locale {
	public var lang:String;
	public var code:String;

	public function new(lang:String, code:String) {
		this.lang = lang;
		this.code = code;
	}
}