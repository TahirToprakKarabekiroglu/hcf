package;

import flixel.text.FlxText;
import flixel.FlxG;
import flixel.util.FlxColor;
import flixel.FlxSprite;

class UnlockSubstate extends MusicBeatSubstate 
{
    var prompt:FlxSprite;
    var cancel:HillButton;
    var upgrade:HillButton;
    var titleText:FlxText;
    var descText:FlxText;
    var unlock:String;

    public function new(unlock:Bool = true, title:String, desc:String, coins:Null<Int>, ?unlocks:String, ?updateP:Void -> Void, ?levelled:Bool = false, ?option:String) 
    {
        super();

        this.unlock = unlocks;
        
        var bg:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
        bg.alpha = 0.6;
        add(bg);

        prompt = new FlxSprite();
        prompt.loadGraphic(Paths.image("messagebox"));
        prompt.scale.scale(1.5);
        prompt.updateHitbox();
        prompt.screenCenter();
        add(prompt);

        cancel = new HillButton(null, "CANCEL", 40, 80, 15);
        cancel.x = prompt.x + prompt.width / 2 + 80;
        cancel.scale.scale(1.5);
        cancel.y = prompt.y + prompt.height / 1.5 + 60;
        cancel.clickPress = close;
        add(cancel);

        upgrade = new HillButton(null, unlock ? "UNLOCK" : "UPGRADE", 40, 80, 15); 
        upgrade.scale.scale(1.5);
        upgrade.x = cancel.x - cancel.width * 2 + 95;
        upgrade.y = cancel.y;
        upgrade.playSound = false;
        upgrade.clickPress = () -> {
            if (FlxG.save.data.coin < coins)
                return;

            FlxG.sound.play(Paths.sound("purchase"));
            if (coins != null && !levelled)
            {
                FlxG.save.data.coin -= coins;
                FlxG.save.flush();
            }

            if (unlocks != null)
            {
                if (!levelled)
                {
                    Reflect.setField(FlxG.save.data, unlocks, true);
                    FlxG.save.flush();
                    close();
                }
                else 
                {
                    var level:Null<Int> = Reflect.field(FlxG.save.data, unlocks);
                    if (level == null)
                        level = 1;
                    FlxG.save.data.coin -= UpgradeMenuState.options[option].costs[level];
                    FlxG.save.flush();
                    level++;

                    UpgradeMenuState.options[option].level = level;

                    Reflect.setField(FlxG.save.data, unlocks, level); 
                    FlxG.save.flush();
                    close();
                }
            }
            if (updateP != null)
                updateP();
        }
        add(upgrade);

        if (option != null && levelled)
        {
            var level:Null<Int> = Reflect.field(FlxG.save.data, unlocks);
            if (level == null)
                level = 1;
            coins = UpgradeMenuState.options[option].costs[level];
        }

        titleText = new FlxText();
        titleText.setFormat(Paths.font("vcr.ttf"), 64);
        titleText.text = (unlock ? "UNLOCK" : "UPGRADE") + " " + title + "?";
        titleText.setPosition(240, 120);
        titleText.y -= titleText.height / 2;
        add(titleText);

        descText = new FlxText(240, 180);
        descText.setFormat(Paths.font("vcr.ttf"), 40); 
        descText.text = desc;
        descText.text += "\n\nUnlock cost: " + coins + " coins"; 

        if (FlxG.save.data.coin < coins)
            descText.text += "\nYou need " + (coins - FlxG.save.data.coin) + " more coins";
        add(descText);
    }    

    override function update(elapsed:Float) 
    {
        super.update(elapsed);
    }
}