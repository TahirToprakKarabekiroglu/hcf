package;

import flixel.util.FlxTimer;
import flixel.addons.transition.FlxTransitionableState;
import lime.app.Application;
import Discord.DiscordClient;
import flixel.FlxG;
import flixel.text.FlxText;
import flixel.ui.FlxBar;
import flixel.FlxSprite;
import flixel.util.FlxColor;

class FirstState extends MusicBeatState 
{
    var progress:Float = 0;
    var progressBar:FlxSprite;

    var started:Bool = true;

    override function create()
    {
        Paths.clearStoredMemory();
		Paths.clearUnusedMemory();

        PlayerSettings.init();

        FlxG.fixedTimestep = false;
        FlxG.save.bind('hillclimbfunkin', 'tahirtoprakkarabekiroglu');

        PlayerSettings.player1.setKeyboardScheme(Solo);

        if (FlxG.save.data.coin == null)
        {
            FlxG.save.data.coin = 0;
            FlxG.save.flush();
        }
        if (FlxG.save.data.stage_unlocked_0 == null)
        {
            FlxG.save.data.stage_unlocked_0 = true;
            FlxG.save.flush();
        }

        if (!DiscordClient.isInitialized)
		{
			DiscordClient.initialize();
			Application.current.onExit.add (function (exitCode) {
				DiscordClient.shutdown();
			});
		}

        super.create();

        var bg:FlxSprite = new FlxSprite();
        bg.loadGraphic(Paths.image("bg"));
        add(bg);

        var loading:FlxSprite = new FlxSprite();
        loading.loadGraphic(Paths.image("logotrans"));
        loading.scale.scale(0.5, 0.5);
        loading.updateHitbox();
        loading.screenCenter();
        //loading.y += 80;
        add(loading);

        Conductor.changeBPM(90);

        progressBar = new FlxSprite();
        progressBar.makeGraphic(1, 40, FlxColor.WHITE);
        progressBar.screenCenter(Y);
        progressBar.x = 200;
        progressBar.y += 200;
        add(progressBar);
    }    

    override function update(elapsed:Float)
    {
        super.update(elapsed);

        if (started)
            FlxG.sound.playMusic(Paths.music('theme'));

        if (FlxG.random.bool(95))
            progress += elapsed * FlxG.random.int(100, 800);

        if (progress > 100)
        {
            progress = 100;
            new FlxTimer().start(.5, (tmr) -> MusicBeatState.switchState(new MenuState()));
        }

        progressBar.setGraphicSize(progress * 10, progressBar.height);
        progressBar.updateHitbox();
        progressBar.x = progressBar.width - (progress * 10) + 140; 

        started = false;
    }
}