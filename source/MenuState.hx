package;

import flixel.group.FlxSpriteGroup;
import flixel.math.FlxMath;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.tweens.*;

class MenuState extends MusicBeatState 
{
    var optionsButton:HillButton;
    var playButton:HillButton;
    var creditsButton:HillButton;

    var coinText:FlxHillText;
    var coinTween:FlxTween;

    var stages:Array<FlxSprite> = [];
    var stageGroup:FlxSpriteGroup = new FlxSpriteGroup();
    var lockedStages:Array<FlxSprite> = [];
    static var currentIndex:Int = 0;
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

    var stageText:Array<FlxHillText> = [];

    var stageDescs:Array<String> = [
        "",
        "Climbing hills in the desert is a must have experience\nfor any hillbilly. In order to travel the desert you need\na trailer and a towing car that can carry your vehicle.",
        "Experience the slippery snow conditions! In order to\nget to the northern parts of Finland you need a cargo\nplane that carries the car.",
        "Go to the place no hillbilly has ever been before.\nDifferent gravity allows a whole new set of tricks to\nexperience!"
    ];

    var dragging:Bool = false;
    var dragStartX:Float = 0;
    var initialStageX:Array<Float> = [];
    var maxDragDistance:Float = 200;

    var soundButton:SoundButton;
    var musicButton:SoundButton;

    override function create()
    {
        DiscordClient.changePresence("In the main menu", null);

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

        optionsButton = new HillButton(null, "OPTIONS", 52, 40, 12.5);
        optionsButton.scaleButton(1.25);
        optionsButton.screenCenter();
        optionsButton.clickPress = () -> {
            openSubState(new OptionsSubstate());
        }
        optionsButton.y += FlxG.height / 3 - 40;
        optionsButton.x -= 310;
        add(optionsButton);

        playButton = new HillButton("right", "NEXT", 52, 70, 10);
        playButton.scaleButton(1.25);
        playButton.screenCenter();
        playButton.y = optionsButton.y;
        playButton.x += 370;
        playButton.clickPress = switchUpgrade;
        add(playButton);

        creditsButton = new HillButton(null, "CREDITS", 52, 70, 10);
        creditsButton.scaleButton(1.25);
        creditsButton.screenCenter();
        creditsButton.clickPress = () -> {
            openSubState(new CreditsSubstate());
        }
        creditsButton.y = optionsButton.y;
        creditsButton.x += 30;
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
            stageGroup.add(stages[i]);

            var stageText:FlxHillText = new FlxHillText();
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

        var select:FlxHillText = new FlxHillText();
        select.text = "SELECT STAGE";
        select.y = 30;
        select.screenCenter(X);
        select.x += select.width - 10;
        select.updateHitbox();
        add(select);

        super.create();
    }

    override function update(elapsed:Float)
    {
        super.update(elapsed);

        /*if (FlxG.keys.justPressed.F)
            openSubState(new DownSubstate());*/

        if (FlxG.mouse.pressed && FlxG.mouse.overlaps(stageGroup))
        {
            if (!dragging)
            {
                dragging = true;
                dragStartX = FlxG.mouse.screenX;
                initialStageX = [];
                
                for (stage in stages)
                {
                    initialStageX.push(stage.x);
                }
            }
            else
            {
                var deltaX:Float = Math.min(Math.max(FlxG.mouse.screenX - dragStartX, -maxDragDistance), maxDragDistance);
                for (i in 0...stages.length)
                {
                    stages[i].x = initialStageX[i] + deltaX;
                    stageText[i].x = stages[i].x + 256 - (stageText[i].width / 2);
                    lockedStages[i].x = stages[i].x;

                    var distance:Float = Math.abs(stages[i].x + stages[i].width / 2 - centerX);
                    var targetScale:Float = 1 - Math.min(distance / (FlxG.width * 0.5), 1) * 0.5;
                    stages[i].scale.set(FlxMath.lerp(stages[i].scale.x, targetScale, 0.025), FlxMath.lerp(stages[i].scale.y, targetScale, 0.025));
                    stageText[i].scale.set(stages[i].scale.x, stages[i].scale.y);
                    lockedStages[i].scale.set(stages[i].scale.x, stages[i].scale.y);
                }
            }
        }
        else if (dragging)
        {
            dragging = false;
            var deltaX:Float = FlxG.mouse.screenX - dragStartX;
            var first:Bool = currentIndex == 0;
            var last:Bool = currentIndex == stageNames.length - 1;

            if (deltaX < -50 && !last)
            {
                nextStage();
            }
            else if (deltaX > 50 && !first)
            {
                previousStage();
            }

            updateStagePositions();
        }

        var key = -1;
        if (FlxG.keys.justPressed.LEFT)
            key = 0;
        else if (FlxG.keys.justPressed.RIGHT)
            key = 1;

        onKeyPress(key != -1, key);

        if (FlxG.keys.justPressed.ENTER)
        {
            switchUpgrade();
        }

        for (i in 0...stages.length)
        {
            var text = stageText[i];
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
            var x:Float = switch "stage_unlocked_" + currentIndex
            {
                case "stage_unlocked_1": -20;
                case "stage_unlocked_2": -15;
                case "stage_unlocked_3": -12.5;
                case _: 0;
            }
            var sub = new UnlockSubstate(true, stageNames[currentIndex], stageDescs[currentIndex], unlockcost[currentIndex], "stage_unlocked_" + currentIndex, 
            () -> {
                updateStagePositions();
                coinBop();
            }, false, null, 45);
            sub.offsetX = x;
            openSubState(sub);
        }
        else 
        {
            PlayState.curStage = stageNames[currentIndex];
            MusicBeatState.switchState(new UpgradeMenuState());
        }
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
        DiscordClient.changePresence("In the main menu", null);
        super.closeSubState();
    }
}
