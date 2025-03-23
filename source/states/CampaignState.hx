package states;

import flixel.addons.ui.FlxUIInputText;

class CampaignState extends ExtendableState {
	public static var songList:Array<String> = [];
	public static var curSongIndex:Int = 0;

	var input:FlxUIInputText;

	var isResetting:Bool = false;
	var lockInputs:Bool = false;

	override function create() {
		super.create();

		Paths.clearStoredMemory();
		Paths.clearUnusedMemory();

		#if FUTURE_DISCORD_RPC
		DiscordClient.changePresence("Campaign Menu", null);
		#end

		var bg:FlxSprite = new GameSprite().loadGraphic(Paths.image('menu/backgrounds/campaign_bg'));
		bg.scrollFactor.set();
		bg.screenCenter();
		add(bg);

		var grid:FlxBackdrop = new FlxBackdrop(FlxGridOverlay.createGrid(80, 80, 160, 160, true, 0x33FFFFFF, 0x0));
		grid.velocity.set(40, 40);
		add(grid);

		var text:FlxText = new FlxText(0, 180, 0, "Enter the songs you want to play.\n(Be sure to separate them with a comma.)", 32);
		text.setFormat(Paths.font('vcr.ttf'), 40, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		text.screenCenter(X);
		add(text);

		input = new FlxUIInputText(10, 10, FlxG.width, '', 8);
		input.setFormat(Paths.font('vcr.ttf'), 75, FlxColor.WHITE, FlxTextAlign.CENTER);
		input.alignment = CENTER;
		input.setBorderStyle(OUTLINE, 0xFF000000, 5, 1);
		input.screenCenter(XY);
		input.y += 50;
		input.backgroundColor = 0xFF000000;
		input.lines = 1;
		input.caretColor = 0xFFFFFFFF;
		add(input);

		var scoreDisplay = ((FlxG.save.data.campaignScoreSave == 0 || FlxG.save.data.campaignScoreSave == null) ? 0 : FlxG.save.data.campaignScoreSave);
		var campScoreTxt:FlxText = new FlxText(5, FlxG.height - 24, 0, 'Campaign Score: ${scoreDisplay} // Press R to reset your score.', 12);
		campScoreTxt.setFormat(Paths.font('vcr.ttf'), 20, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(campScoreTxt);
	}

	override function update(elapsed:Float) {
		super.update(elapsed);

		input.hasFocus = true;

		if (Input.justPressed('accept') && input.text != '') {
			FlxG.sound.play(Paths.sound('select'));
			startCampaignMode(input.text);
		}

		if (Input.justPressed('exit')) {
			ExtendableState.switchState(new MenuState());
			FlxG.sound.play(Paths.sound('cancel'));
		}
	}

	function startCampaignMode(songs:String) {
		songList = songs.split(",").map(s -> StringTools.trim(s));
		PlayState.campaignMode = true;
		PlayState.song = Song.loadSongfromJson(Paths.formatToSongPath(songList[curSongIndex]));
		ExtendableState.switchState(new PlayState());
		if (FlxG.sound.music != null)
			FlxG.sound.music.stop();
	}
}