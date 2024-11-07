package;

import sys.io.File;
import flixel.text.FlxText;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.tweens.*;

typedef Upgrade = {
    public var saveName:String;

    public var ?unlockCost:Int;

    public var ?level:Int;
    public var ?costs:Array<Null<Int>>;
}

class UpgradeMenuState extends MusicBeatState 
{
    public static var options:Map<String, Upgrade> = [
        "battery" => {level: 1, costs: [
            0, 7700, 9900, 12600, 13900
        ], saveName: "batteryLevel"},
        "input" => {level: 1, costs: [
            0, 4500, 6500, 7000, 7500, 8500, 10500, 11500, 13500, 15500, 25000
        ], saveName: "inputLevel"},
        "coinUp" => {level: 1, costs: [
            0, 3400, 5500, 6750, 6800, 7500, 9000, 11000, 12500, 14500, 16950, 17000, 17500, 18500, 20000, 21000,
            22500, 24000, 25000, 26500, 27000
        ], saveName: "coinUpLevel"},
        "random" => {unlockCost: 45000, saveName: "randomUnlocked"},
    ];

    public static var optionDesc:Map<String, Array<String>> = [
        "battery" => ["BATTERY", "-20", "Upgrading your mic's battery will extend\nyour mic's battery life so you can finish the game.\nEvery upgrade extends battery life by 7.5s."],
        "random" => ["RANDOM MODE", "-40", "Random mode is a mode that randomizes coins.\nGame will try not to generate jacks.\nYou can adjust this on options menu."],
        "input" => ["INPUT", "10", "Upgrading your input system will decrease drops\nand increase the range you can hit notes from.\nEvery upgrade decreases drops by 0.4%."],
        "coinUp" => ["COINS", "0", "Upgrading coins will increase the chances\nof getting higher coins than 5.\nEvery upgrade increases the chance by 1%."]
    ];

    var offsetX:Array<Float> = [35, 22.5, 25, 18];
    
    var optionsButton:HillButton;
    var playButton:HillButton;
    var creditsButton:HillButton;

    var costTexts:Map<String, FlxHillText> = [];
    var levelTexts:Map<String, FlxHillText> = [];

    var coinText:FlxHillText;
    var coinTween:FlxTween;

    var soundButton:SoundButton;
    var musicButton:SoundButton;

    var stageText:FlxHillText;
    
    override function create()
    {
        DiscordClient.changePresence("In the upgrade menu", null);

        reloadOptions();

        if (SoundButton.musicEnabled && FlxG.sound.music != null && !FlxG.sound.music.playing)
            FlxG.sound.playMusic(Paths.music("bgmusic00"));

        var bg:FlxSprite = new FlxSprite();
        bg.loadGraphic(Paths.image("bg"));
        add(bg);

        var column:FlxSprite = new FlxSprite();
        column.loadGraphic(Paths.image("column"));
        add(column);

        var coin:FlxSprite = new FlxSprite();
        coin.loadGraphic(Paths.image("coin"));
        coin.x = 20;
        coin.y = 30;
        add(coin);

        coinText = new FlxHillText();
        coinText.text = Std.string(FlxG.save.data.coin);
        coinText.x = coin.x + coin.width + 10;
        coinText.y = 30;
        add(coinText);

        optionsButton = new HillButton("left", "STAGE", 52, 70, 12.5);
        optionsButton.scaleButton(1.25);
        optionsButton.screenCenter();
        optionsButton.clickPress = () -> {
            MusicBeatState.switchState(new MenuState());
        }
        optionsButton.y += FlxG.height / 3 - 40;
        optionsButton.x -= 310;
        add(optionsButton);

        playButton = new HillButton("right", "START", 52, 80, 12.5);
        playButton.scaleButton(1.25);
        playButton.screenCenter();
        playButton.y = optionsButton.y;
        playButton.x += 370;
        playButton.clickPress = () -> {
            var song = "bgmusic01" + "-" + PlayState.curStage.toLowerCase();
            PlayState.SONG = Song.loadFromJson(song, song);
            MusicBeatState.switchState(new PlayState());
        };
        add(playButton);

        creditsButton = new HillButton(null, "OPTIONS", 52, 40, 12.5);
        creditsButton.scaleButton(1.25);
        creditsButton.screenCenter();
        creditsButton.clickPress = () -> {
            openSubState(new OptionsSubstate());
        }
        creditsButton.y = optionsButton.y;
        creditsButton.x += 30;
        add(creditsButton);

        var l:Int = 0;
        for (i => k in options)
        {
            var button:UpgradeButton = new UpgradeButton(i);
            button.scale.scale(1.5);
            button.ID = l;
            button.clickPress = () -> {
                function open()
                {
                    var sub = new UnlockSubstate(k.unlockCost != null, optionDesc[i][0], optionDesc[i][2], k.unlockCost != null ? k.unlockCost : null, k.saveName, reloadOptions, k.unlockCost == null, i);
                    sub.offsetX = offsetX[button.ID];
                    sub.offsetY = 10;
                    openSubState(sub);
                }

                if (k.unlockCost != null)
                {
                    if (Reflect.field(FlxG.save.data, k.saveName) != true)
                        open();
                    else 
                        openSubState(new MaxSubstate(true));
                }
                else 
                {
                    var lv:Null<Int> = Reflect.field(FlxG.save.data, k.saveName);
                    if (lv == null || lv < k.costs.length)
                        open();
                    else 
                        openSubState(new MaxSubstate());
                }
            }
            button.screenCenter(Y);
            button.x = 200 + (l * 250);
            button.y -= 60;
            add(button);

            var text:FlxHillText = new FlxHillText();
            text.size = 56;
            text.text = optionDesc[i][0];
            text.y = button.y - button.height + 32;
            text.x = button.x;
            text.x += Std.parseFloat(optionDesc[i][1]);
            if (text.text == "RANDOM MODE")
            {
                text.scale.x *= .8;
                text.updateHitbox();
            }
            add(text);

            if (k.unlockCost != null)
            {
                var unlocked = Reflect.field(FlxG.save.data, k.saveName);

                var cost:FlxHillText = new FlxHillText();
                cost.size = 56;
                cost.x = text.x;
                cost.y = text.y + button.height * 2;
                add(cost);

                if (unlocked == true)
                {
                    cost.text = "MAX LEVEL";
                }
                else 
                {
                    cost.text = "COST " + k.unlockCost;
                    cost.x += 10;
                }
                levelTexts.set(i, cost);
            }
            else
            {
                var level:FlxHillText = new FlxHillText();
                level.size = 56;
                level.x = text.x - text.width / 2;
                level.y = text.y + button.height * 2 - 10;
                level.text = "LEVEL " + k.level + " / " + (k.costs.length);
                add(level);
                levelTexts.set(i, level);

                var cost:FlxHillText = new FlxHillText();
                cost.size = 56;
                cost.x = level.x;
                cost.y = level.y + level.height;
                cost.text = "COST " + k.costs[k.level];
                add(cost);
                costTexts.set(i, cost);
                if (text.text == "BATTERY")
                {
                    level.x += 35;
                    cost.x += 35;
                }
            }

            l++;
        }   

        updateTexts();

        soundButton = new SoundButton();
        soundButton.scale.scale(1.25);
        soundButton.x = FlxG.width - soundButton.width * 2.5;
        soundButton.y = 20;
        add(soundButton);

        musicButton = new SoundButton(true);
        musicButton.scale.scale(1.25);
        musicButton.x = FlxG.width - soundButton.width * 1.25;
        musicButton.y = soundButton.y;
        add(musicButton);

        stageText = new FlxHillText();
        stageText.text = PlayState.curStage.toUpperCase();
        stageText.y = soundButton.y + 10;
        stageText.x = soundButton.x - stageText.width - 15;
        add(stageText);

        super.create();
    }

    override function update(elapsed:Float)
    {
        super.update(elapsed);
    }

    var firstTime:Bool = true;
    function updateTexts()
    {
        if (firstTime)
        {
            firstTime = false;
            return;
        }

        coinText.text = Std.string(FlxG.save.data.coin);
        coinBop();

        for (i => k in levelTexts)
        {
            var o = options[i];
            k.offset.set();
            
            if (o.unlockCost != null)
            {
                var unlocked = Reflect.field(FlxG.save.data, o.saveName);
                if (unlocked == true)
                {
                    k.text = "MAX LEVEL";
                    k.offset.x = 0;
                }
                else 
                {
                    k.text = "COST " + o.unlockCost;
                    k.offset.set();
                    k.offset.x = 30;
                }
                k.offset.y = 10;
            }
            else 
            {
                k.text = "LEVEL " + o.level + " / " + (o.costs.length);
                var cost = costTexts[i];
                if (o.level == o.costs.length)
                {
                    cost.text = "MAX LEVEL";
                    //cost.offset.x = -18;
                }
                else
                {
                    cost.offset.x = -10;
                    cost.text = "COST " + o.costs[o.level];
                }

                k.offset.y = 5;
                cost.offset.y = 24;
                
                //k.offset.x = 10;
                //cost.offset.x = 10;

                if (i == "battery")
                {
                    k.offset.x = -22.5;
                    cost.offset.x = -20;
                }
                else if (i == "coinUp")
                {
                    k.offset.x = 0;
                    cost.offset.x = -7.5;
                }
                else if (i == "input")
                {
                    k.offset.x = -2.5;
                    cost.offset.x = -2.5;
                }
                if (cost.text == "MAX LEVEL")
                {
                    switch i 
                    {
                        case "coinUp":
                            cost.offset.x = -25;
                        case "battery":
                            cost.offset.x -= 15;
                        case "input":
                            cost.offset.x -= 15;
                    }
                }
            }
        }
    }

    function reloadOptions()
    {
        for (i => k in options)
        {
            var option:Dynamic = Reflect.field(FlxG.save.data, k.saveName);
            if (option == null)
            {
                if (k.unlockCost != null)
                {
                    option = false;
                }
                else 
                    option = 1;

                Reflect.setField(FlxG.save.data, k.saveName, option);
                FlxG.save.flush();
            }
            else 
            {
                if (k.unlockCost == null)
                {
                    var k = k;
                    k.level = option;
                    options[i] = k;
                }
            }
        }

        updateTexts();
    }

    function coinBop():Void {
		if(coinTween != null)
			coinTween.cancel();

		coinText.scale.x = coinText.size / 64 * 1.075;
		coinText.scale.y = coinText.size / 64 * 1.075;
		coinTween = FlxTween.tween(coinText.scale, {x: coinText.size / 64, y: coinText.size / 64}, 0.2, {
			onComplete: function(twn:FlxTween) {
				coinTween = null;
			}
		});
	}

    override function closeSubState()
    {
        DiscordClient.changePresence("In the upgrade menu", null);
        super.closeSubState();
    }
}