package;

import flixel.util.FlxColor;
import flixel.FlxSprite;
import flixel.FlxG;

class PauseSubState extends MusicBeatSubstate 
{
	var pressed:Bool = false;

	public function new()
	{
		super();

		cameras = [FlxG.cameras.list[FlxG.cameras.list.length - 1]];
		HillButton._camera = cameras[0];

		var bg:FlxSprite = new FlxSprite();
		bg.makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		bg.alpha = 0.6;
		add(bg);

		var pause:FlxSprite = new FlxSprite();
		pause.loadGraphic(Paths.image("pause"));
		pause.scale.scale(1.35);
		pause.updateHitbox();
		pause.screenCenter();
		pause.y -= 100;
		add(pause);

		var buttons = [];

		var restart:HillButton = new HillButton(null, "RESTART", 48, 80, 10);
		restart.scale.scale(1.25);
		restart.screenCenter();
		restart.y -= 50;
		restart.clickPress = () -> {
			if (pressed)
				return;

			var res = () -> {
				FlxG.sound.music.volume = 0;
				PlayState.instance.vocals.volume = 0;
				MusicBeatState.resetState();
			}
			pressed = true;
			for (i in buttons)
				i.playSound = false;
			var substate = new ExitSubstate(false, res, this);
			substate.destroyFunc = () -> {
				pressed = false;
				for (i in buttons)
					i.playSound = true;
				remove(substate);
			}
			add(substate);
		}
		buttons.push(restart);
		add(restart);

		var resume:HillButton = new HillButton(null, "RESUME", 48, 80, 10);
		resume.scale.scale(1.25);
		resume.screenCenter();
		resume.y -= restart.height * 1.25 + 60;
		resume.clickPress = () -> if (!pressed) close();
		buttons.push(resume);
		add(resume);

		var exit:HillButton = new HillButton(null, "EXIT", 48, 100, 10);
		exit.scale.scale(1.25);
		exit.screenCenter();
		exit.y += restart.height - 15;
		exit.clickPress = () -> {
			if (pressed)
				return;

			var res = () -> {
				PlayState.instance.vocals.stop();
				FlxG.camera.followLerp = 0;
				HillButton._camera = null;

				MusicBeatState.switchState(new MenuState());
			}
			pressed = true;
			for (i in buttons)
				i.playSound = false;
			var substate = new ExitSubstate(true, res, this);
			substate.destroyFunc = () -> {
				for (i in buttons)
					i.playSound = true;
				pressed = false;
				remove(substate);
			}
			add(substate);
		}
		buttons.push(exit);
		add(exit);
	}	

	override function update(elapsed:Float)
	{
		super.update(elapsed);
	}

	override function destroy()
	{
		HillButton._camera = null;

		super.destroy();
	}
}