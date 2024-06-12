package;

import flixel.text.FlxText;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.tweens.*;

class MenuState extends MusicBeatState 
{
    var optionsButton:HillButton;
    var playButton:HillButton;
    var creditsButton:HillButton;

    var coinText:FlxText;

    var stages:Array<FlxSprite> = [];
    var lockedStages:Array<FlxSprite> = [];
    var currentIndex:Int = 0;
    var centerX:Float;

    var stageNames = [
        "COUNTRYSIDE",
        "DESERT",
        "ARCTIC",
        "MOON"
    ];

    var unlockcost:Array<Int> = [
        0,
        35000,
        50000,
        75000
    ];

    var stageText:Array<FlxText> = [];

    var stageDescs:Array<String> = [
        "",
        "Climbing hills in the desert is a must have experience\nfor any hillbilly. In order to travel the desert you need\na trailer and a towing car that can carry your vehicle.",
        "Experience the slippery snow conditions! In order to\nget to the northern parts of Finland you need a cargo\nplane that carries the car.",
        "Go to the place no hillbilly has ever been before.\nDifferent gravity allows a whole new set of tricks to\nexperience!"
    ];

    override function create()
    {
        DiscordClient.changePresence("In the main menu", null);

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

        optionsButton = new HillButton(null, "OPTIONS", 48, 60, 12.5);
        optionsButton.screenCenter();
        optionsButton.clickPress = () -> {
            openSubState(new OptionsSubstate());
        }
        optionsButton.y += FlxG.height / 3 - 40;
        optionsButton.x -= 400;
        add(optionsButton);

        playButton = new HillButton("right", "NEXT", 48, 80, 10);
        playButton.screenCenter();
        playButton.y = optionsButton.y;
        playButton.x += 400;
        playButton.clickPress = switchUpgrade;
        add(playButton);

        creditsButton = new HillButton(null, "CREDITS", 48, 80, 10);
        creditsButton.screenCenter();
        creditsButton.clickPress = () -> {
            openSubState(new CreditsSubstate());
        }
        creditsButton.y = optionsButton.y;
        add(creditsButton);

        stages = [];

        for (i in 0...4)
        {
            var sprite:FlxSprite = new FlxSprite();
            sprite.loadGraphic(Paths.image("stage" + (i + 1)));
            stages.push(sprite);
        }

        centerX = FlxG.width / 2;

        for (i in 0...stages.length)
        {
            stages[i].setPosition(centerX + (i - currentIndex) * (FlxG.width * 0.5), FlxG.height / 2);
            stages[i].scale.set((i == currentIndex) ? 1 : 0.5, (i == currentIndex) ? 1 : 0.5);
            stages[i].screenCenter(Y);
            add(stages[i]);

            var stageText:FlxText = new FlxText();
            stageText.setFormat(Paths.font("vcr.ttf"), 64);
            stageText.text = stageNames[i];
            stageText.visible = false;
            add(stageText);
            this.stageText.push(stageText);

            var sprite:FlxSprite = new FlxSprite();
            if (i != 0)
            {
                sprite.loadGraphic(Paths.image("lockedstage" + i));
                sprite.setPosition(stages[i].x, stages[i].y);
                sprite.scale.set(stages[i].scale.x, stages[i].scale.y);
                sprite.visible = false;
                add(sprite);
            }
            lockedStages.push(sprite);
        }

        updateStagePositions();

        super.create();
    }

    override function update(elapsed:Float)
    {
        super.update(elapsed);

        var key = -1;
        if (FlxG.keys.justPressed.LEFT)
            key = 0;
        else if (FlxG.keys.justPressed.RIGHT)
            key = 1;

        onKeyPress(key != -1, key);

        if (FlxG.keys.justPressed.ENTER && !getUnlocked(currentIndex))
        {
            openSubState(new UnlockSubstate(true, stageNames[currentIndex], stageDescs[currentIndex], unlockcost[currentIndex], "stage_unlocked_" + currentIndex, updateStagePositions));
        }

        for (i in 0...stages.length)
        {
            var text = stageText[i];

            //text.x = stages[i].x + text.width / 2;
            text.y = stages[i].y - stages[i].height / 2 + 30;

            var lockedSprite = lockedStages[i];
            lockedSprite.setPosition(stages[i].x, stages[i].y);
        }
    }

    private function onKeyPress(pressed:Bool, keyCode:Int):Void
    {
        if (!pressed) 
            return;

        if (keyCode == 0)
        {
            previousStage();
        }
        else if (keyCode == 1)
        {
            nextStage();
        }
    }

    private function previousStage():Void
    {
        if (currentIndex > 0)
        {
            currentIndex--;
            updateStagePositions();
        }
        else
        { 
            currentIndex = stages.length - 1;
            updateStagePositions();
        }
    }

    private function nextStage():Void
    {
        if (currentIndex < stages.length - 1)
        {
            currentIndex++;
            updateStagePositions();
        }
        else
        {
            currentIndex = 0;
            updateStagePositions();
        }
    }

    public function updateStagePositions():Void
    {
        for (i in 0...stages.length)
        {
            var text = stageText[i];
            text.visible = true;

            var lockedSprite = lockedStages[i];

            FlxTween.cancelTweensOf(lockedSprite.scale);

            FlxTween.cancelTweensOf(text);
            FlxTween.cancelTweensOf(text.scale);

            FlxTween.cancelTweensOf(stages[i]);
            FlxTween.cancelTweensOf(stages[i].scale);

            var targetX:Float = centerX - (currentIndex - i) * (512);
            targetX -= stages[i].width / 2 - 10;
            var targetScale:Float = (i == currentIndex) ? 1 : 0.5;

            FlxTween.tween(stages[i], {x: targetX}, 0.5, {ease: FlxEase.quadInOut});
            FlxTween.tween(stages[i].scale, {x: targetScale, y: targetScale}, 0.5, {ease: FlxEase.quadInOut});

            FlxTween.tween(text, {x: targetX + 256 - (text.width / 2)}, 0.5, {ease: FlxEase.quadInOut});
            FlxTween.tween(text.scale, {x: targetScale, y: targetScale}, 0.5, {ease: FlxEase.quadInOut});
            
            FlxTween.tween(lockedSprite.scale, {x: targetScale, y: targetScale}, 0.5, {ease: FlxEase.quadInOut});

            lockedSprite.visible = !getUnlocked(i);
        }
        coinText.text = Std.string(FlxG.save.data.coin);
    }

    function getUnlocked(i:Int):Bool
    {
        var data:String = "stage_unlocked_";
        data += i;
        
        var unlocked:Null<Dynamic> = Reflect.field(FlxG.save.data, data);
        return unlocked != null && unlocked == true;
    }

    function switchUpgrade():Void 
    {
        if (!getUnlocked(currentIndex))
        {
            openSubState(new UnlockSubstate(true, stageNames[currentIndex], stageDescs[currentIndex], unlockcost[currentIndex], "stage_unlocked_" + currentIndex, updateStagePositions));
        }
        else 
        {
            PlayState.curStage = stageNames[currentIndex];
            MusicBeatState.switchState(new UpgradeMenuState());
        }
    }
}