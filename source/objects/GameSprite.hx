package objects;

class GameSprite extends FlxSprite
{
	public function new(x:Float = 0, y:Float = 0):Void
	{
		super(x, y);
		antialiasing = SaveData.settings.antialiasing;
	}
}
