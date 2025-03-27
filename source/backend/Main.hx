package backend;

#if desktop
import openfl.events.UncaughtErrorEvent;
import haxe.CallStack;
import haxe.io.Path;
import sys.io.Process;
import backend.ALSoftConfig;
#end
import debug.FPS;

#if (linux || mac)
import lime.graphics.Image;
#end

#if (linux && !debug)
@:cppInclude('./external/gamemode_client.h')
@:cppFileCode('#define GAMEMODE_AUTO')
#end
class Main extends openfl.display.Sprite {
	public final config:Dynamic = {
		gameDimensions: [1280, 720],
		initialState: InitialState,
		defaultFPS: 60,
		skipSplash: true,
		startFullscreen: false
	};

	public static var fpsDisplay:FPS;
	public static var toast:ToastCore;

	public static var framerate(get, set):Float;
	static function set_framerate(cap:Float):Float {
		if (FlxG.game != null) {
			var _framerate:Int = Std.int(cap);
			if (_framerate > FlxG.drawFramerate) {
				FlxG.updateFramerate = _framerate;
				FlxG.drawFramerate = _framerate;
			} else {
				FlxG.drawFramerate = _framerate;
				FlxG.updateFramerate = _framerate;
			}
		}
		return Lib.current.stage.frameRate = cap;
	}
	static function get_framerate():Float return Lib.current.stage.frameRate;

	public function new() {
		super();

		#if windows
		WindowsAPI.darkMode(true);
		#end

		framerate = 60; // default framerate
		addChild(new FlxGame(config.gameDimensions[0], config.gameDimensions[1], config.initialState, config.defaultFPS, config.defaultFPS, config.skipSplash,
			config.startFullscreen));

		#if FUTURE_DISCORD_RPC
		DiscordClient.load();
		#end

		fpsDisplay = new FPS(10, 10, 0xffffff);
		addChild(fpsDisplay);

		#if (linux || mac)
		Lib.current.stage.window.setIcon(Image.fromFile("icon.png"));
		#end

		#if desktop
		Lib.current.loaderInfo.uncaughtErrorEvents.addEventListener(UncaughtErrorEvent.UNCAUGHT_ERROR, (e:UncaughtErrorEvent) -> {
			var stack:Array<String> = [];
			stack.push(e.error);

			for (stackItem in CallStack.exceptionStack(true)) {
				switch (stackItem) {
					case CFunction:
						stack.push('C Function');
					case Module(m):
						stack.push('Module ($m)');
					case FilePos(s, file, line, column):
						stack.push('$file (line $line)');
					case Method(classname, method):
						stack.push('$classname (method $method)');
					case LocalFunction(name):
						stack.push('Local Function ($name)');
				}
			}

			e.preventDefault();
			e.stopPropagation();
			e.stopImmediatePropagation();

			final msg:String = stack.join('\n');

			#if sys
			try {
				if (!FileSystem.exists('./crash/'))
					FileSystem.createDirectory('./crash/');

				File.saveContent('./crash/'
					+ Lib.application.meta.get('file')
					+ '-'
					+ Date.now().toString().replace(' ', '-').replace(':', "'")
					+ '.txt',
					msg
					+ '\n');
			} catch (e:Dynamic) {
				Sys.println("Error!\nCouldn't save the crash dump because:\n" + e);
			}
			#end

			#if (flixel < "6.0.0")
			FlxG.bitmap.dumpCache();
			#end
			FlxG.bitmap.clearCache();

			if (FlxG.sound.music != null)
				FlxG.sound.music.stop();

			FlxG.sound.play(Paths.sound('error'));

			#if FUTURE_DISCORD_RPC
			DiscordClient.shutdown();
			#end

			#if windows
			WindowsAPI.messageBox('Error!',
				'Uncaught Error: \n' + msg +
				'\n\nIf you think this shouldn\'t have happened, report this error to GitHub repository!\nhttps://github.com/Joalor64GH/Rhythmo-SC/issues',
				MSG_ERROR);
			#else
			Lib.application.window.alert('Uncaught Error: \n'
				+ msg
				+ '\n\nIf you think this shouldn\'t have happened, report this error to GitHub repository!\nhttps://github.com/Joalor64GH/Rhythmo-SC/issues',
				'Error!');
			#end
			Sys.exit(1);
		});
		#end

		Application.current.window.onFocusOut.add(onWindowFocusOut);
		Application.current.window.onFocusIn.add(onWindowFocusIn);

		#if windows
		Lib.current.stage.addEventListener(openfl.events.KeyboardEvent.KEY_DOWN, (evt:openfl.events.KeyboardEvent) -> {
			if (evt.keyCode == openfl.ui.Keyboard.F2) {
				var sp = Lib.current.stage;
				var position = new openfl.geom.Rectangle(0, 0, Lib.current.stage.stageWidth, Lib.current.stage.stageHeight);

				var image:BitmapData = new BitmapData(Std.int(position.width), Std.int(position.height), false, 0xFEFEFE);
				image.draw(sp, true);

				if (!FileSystem.exists("./screenshots/"))
					FileSystem.createDirectory("./screenshots/");

				var bytes = image.encode(position, new openfl.display.PNGEncoderOptions());

				var curDate:String = Date.now().toString();
				curDate = StringTools.replace(curDate, " ", "_");

				File.saveBytes("screenshots/Screenshot-" + curDate + ".png", bytes);
			}
		});
		#end

		FlxG.mouse.visible = false;

		toast = new ToastCore();
		addChild(toast);
	}

	var oldVol:Float = 1.0;
	var newVol:Float = 0.3;

	var focused:Bool = true;
	var focusMusicTween:FlxTween;

	function onWindowFocusOut() {
		focused = false;

		if (Type.getClass(FlxG.state) != PlayState) {
			oldVol = FlxG.sound.volume;
			newVol = (oldVol > 0.3) ? 0.3 : (oldVol > 0.1) ? 0.1 : 0;

			trace("Game unfocused");

			if (focusMusicTween != null)
				focusMusicTween.cancel();
			focusMusicTween = FlxTween.tween(FlxG.sound, {volume: newVol}, 0.5);

			FlxG.drawFramerate = 30;
		}
	}

	function onWindowFocusIn() {
		new FlxTimer().start(0.2, (tmr:FlxTimer) -> {
			focused = true;
		});

		if (Type.getClass(FlxG.state) != PlayState) {
			trace("Game focused");

			if (focusMusicTween != null)
				focusMusicTween.cancel();

			focusMusicTween = FlxTween.tween(FlxG.sound, {volume: oldVol}, 0.5);

			FlxG.drawFramerate = Std.int(framerate);
		}
	}
}