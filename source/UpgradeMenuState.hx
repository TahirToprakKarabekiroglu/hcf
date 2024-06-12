package;

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
        "downscroll" => {unlockCost: 25000, saveName: "downscrollUnlocked"},
        "random" => {unlockCost: 45000, saveName: "randomUnlocked"},
        "input" => {level: 1, costs: [
            0, 2500, 4500, 5000, 5500, 6500, 7500, 8500, 9500, 12500, 20000
        ], saveName: "inputLevel"},
        "coinUp" => {level: 1, costs: [
            0, 2400, 4500, 5750, 6500, 7500, 9000, 1000, 12500, 13500, 14950, 16500, 17500, 18500, 20000, 21000,
            22500, 24000, 25000, 26500, 27000
        ], saveName: "coinUpLevel"}
    ];

    public static var optionDesc:Map<String, Array<String>> = [
        "downscroll" => ["DOWNSCROLL", "-32.5", "This is the classic downscroll!\nYou can adjust this on options menu."],
        "random" => ["RANDOM MODE", "-40", "Random mode is a mode where the coins get randomized.\nGame will try not to generate jacks.\nYou can adjust this on options menu."],
        "input" => ["INPUT", "20", "Improving your input system will decrease\ndrops and increase the range you can hit notes from.\nEvery upgrade decreases the chance of drops by 0.5%."],
        "coinUp" => ["COINS", "20", "Upgrading coins will increase the chances\nof getting higher coins than 5.\nEvery upgrade increases the chance by 1%."]
    ];
    
    var optionsButton:HillButton;
    var playButton:HillButton;
    var creditsButton:HillButton;

    var costTexts:Map<String, FlxText> = [];
    var levelTexts:Map<String, FlxText> = [];

    var coinText:FlxText;

    override function create()
    {
        DiscordClient.changePresence("In the upgrade menu", null);

        reloadOptions();

        if (FlxG.sound.music != null && !FlxG.sound.music.playing)
            FlxG.sound.playMusic(Paths.music("theme"));

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

        coinText = new FlxText();
        coinText.setFormat(Paths.font("vcr.ttf"), 64);
        coinText.text = Std.string(FlxG.save.data.coin);
        coinText.x = coin.x + coin.width + 5;
        coinText.y = 20;
        add(coinText);

        optionsButton = new HillButton("left", "STAGE", 48, 80, 12);
        optionsButton.screenCenter();
        optionsButton.clickPress = () -> {
            MusicBeatState.switchState(new MenuState());
        }
        optionsButton.y += FlxG.height / 3 - 40;
        optionsButton.x -= 400;
        add(optionsButton);

        playButton = new HillButton("right", "START", 48);
        playButton.screenCenter();
        playButton.y = optionsButton.y;
        playButton.x += 400;
        playButton.clickPress = () -> {
            PlayState.SONG = Song.loadFromJson("racing", "racing");
            MusicBeatState.switchState(new PlayState());
        };
        add(playButton);

        creditsButton = new HillButton(null, "OPTIONS", 48, 60, 12.5);
        creditsButton.screenCenter();
        creditsButton.clickPress = () -> {
            openSubState(new OptionsSubstate());
        }
        creditsButton.y = optionsButton.y;
        add(creditsButton);

        var l:Int = 0;
        for (i => k in options)
        {
            var button:UpgradeButton = new UpgradeButton(i);
            button.scale.scale(1.5);
            button.clickPress = () -> {
                function open()
                    openSubState(new UnlockSubstate(k.unlockCost != null, optionDesc[i][0], optionDesc[i][2], k.unlockCost != null ? k.unlockCost : null, k.saveName, reloadOptions, k.unlockCost == null, i));
            
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

            var text:FlxText = new FlxText();
            text.setFormat(Paths.font("vcr.ttf"), 48, CENTER);
            text.text = optionDesc[i][0];
            text.y = button.y - button.height + 32;
            text.x = button.x;
            text.x += Std.parseFloat(optionDesc[i][1]);
            add(text);

            if (k.unlockCost != null)
            {
                var unlocked = Reflect.field(FlxG.save.data, k.saveName);

                var cost:FlxText = new FlxText();
                cost.setFormat(Paths.font("vcr.ttf"), 48, CENTER);
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
                var level:FlxText = new FlxText();
                level.setFormat(Paths.font("vcr.ttf"), 48, CENTER);
                level.x = text.x - text.width / 2;
                level.y = text.y + button.height * 2 - 10;
                level.text = "LEVEL " + k.level + " / " + (k.costs.length);
                add(level);
                levelTexts.set(i, level);

                var cost:FlxText = new FlxText();
                cost.setFormat(Paths.font("vcr.ttf"), 48, CENTER);
                cost.x = level.x;
                cost.y = level.y + level.height;
                cost.text = "COST " + k.costs[k.level];
                add(cost);
                costTexts.set(i, cost);
            }

            l++;
        }   

        updateTexts();
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

        for (i => k in levelTexts)
        {
            var o = options[i];
            if (o.unlockCost != null)
            {
                var unlocked = Reflect.field(FlxG.save.data, o.saveName);
                if (unlocked == true)
                {
                    k.text = "MAX LEVEL";
                    k.offset.x = -20;
                    if (i == "random")
                        k.offset.x -= 6;
                    else
                        k.offset.y -= 1;
                }
                else 
                {
                    k.text = "COST " + o.unlockCost;
                    k.offset.set();
                }
                k.offset.y = 10;
            }
            else 
            {
                k.text = "LEVEL " + o.level + " / " + (o.costs.length);
                k.offset.x = -7.5;
                if (i == "coinUp")
                    k.offset.x += 7.5;

                var cost = costTexts[i];
                if (o.level == o.costs.length)
                {
                    cost.text = "MAX LEVEL";
                    cost.offset.x = -18;
                }
                else
                {
                    cost.offset.x = -10;
                    cost.text = "COST " + o.costs[o.level];
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
}