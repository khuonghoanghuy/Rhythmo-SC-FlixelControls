package rhythmo.options;

class OptionsState extends ExtendableState
{
	final options:Array<String> = ['prefTxt', 'ctrlTxt', 'langTxt', 'notesTxt'];
	var opGrp:FlxTypedGroup<FlxText>;
	var curSelected:Int = 0;

	var fromPlayState:Bool = false;

	public function new(?fromPlayState:Bool = false):Void
	{
		super();
		this.fromPlayState = fromPlayState;
	}

	override public function create():Void
	{
		#if FUTURE_DISCORD_RPC
		DiscordClient.changePresence('Options Menu', null);
		#end

		var bg:FlxSprite = new GameSprite().loadGraphic(Paths.image('menu/backgrounds/options_bg'));
		bg.scrollFactor.set();
		bg.screenCenter();
		add(bg);

		var grid:FlxBackdrop = new FlxBackdrop(FlxGridOverlay.createGrid(80, 80, 160, 160, true, 0x33FFFFFF, 0x0));
		grid.velocity.set(40, 40);
		add(grid);

		opGrp = new FlxTypedGroup<FlxText>();
		add(opGrp);

		for (i in 0...options.length)
		{
			var text:FlxText = new FlxText(0, 255 + (i * 70), 0, Localization.get(options[i]), 32);
			text.setFormat(Paths.font(Localization.getFont()), 80, FlxColor.WHITE, FlxTextAlign.CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
			text.scrollFactor.set();
			text.screenCenter(X);
			text.ID = i;
			opGrp.add(text);
		}

		var resetControlsTxt:FlxText = new FlxText(5, FlxG.height - 30, 0, Localization.get('ctrlResetGuide'), 12);
		resetControlsTxt.setFormat(Paths.font(Localization.getFont()), 26, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		resetControlsTxt.scrollFactor.set();
		add(resetControlsTxt);

		changeSelection(0, false);

		super.create();
	}

	override public function update(elapsed:Float):Void
	{
		if (Input.justPressed('up') || Input.justPressed('down'))
			changeSelection(Input.justPressed('up') ? -1 : 1);

		if (Input.justPressed('reset'))
		{
			Input.resetControls();
			FlxG.sound.play(Paths.sound('select'));
		}

		if (Input.justPressed('accept'))
		{
			switch (curSelected)
			{
				case 0:
					openSubState(new OptionsSubState());
					persistentUpdate = persistentDraw = false;
				case 1:
					openSubState(new ControlsSubState());
					persistentUpdate = persistentDraw = false;
				case 2:
					ExtendableState.switchState(new LanguageState(fromPlayState));
				case 3:
					ExtendableState.switchState(new NoteColorState(fromPlayState));
			}
		}

		if (Input.justPressed('exit'))
		{
			if (fromPlayState)
			{
				ExtendableState.switchState(new PlayState());
				if (FlxG.sound.music != null)
					FlxG.sound.music.stop();
			}
			else
				ExtendableState.switchState(new MenuState());
			FlxG.sound.play(Paths.sound('cancel'));
		}

		super.update(elapsed);
	}

	private function changeSelection(change:Int = 0, ?playSound:Bool = true):Void
	{
		if (playSound)
			FlxG.sound.play(Paths.sound('scroll'));
		curSelected = FlxMath.wrap(curSelected + change, 0, options.length - 1);
		opGrp.forEach(function(txt:FlxText)
		{
			txt.color = (txt.ID == curSelected) ? FlxColor.LIME : FlxColor.WHITE;
		});
	}
}
