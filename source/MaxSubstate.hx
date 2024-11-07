package;

import flixel.text.FlxText;
import flixel.FlxG;
import flixel.util.FlxColor;
import flixel.FlxSprite;

class MaxSubstate extends MusicBeatSubstate 
{
    var prompt:FlxSprite;
    var upgrade:HillButton;
    var titleText:FlxHillText;
    var descText:FlxHillText;

    public function new(unlock:Bool = false) 
    {
        super();
        
        var bg:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
        bg.alpha = 0.6;
        add(bg);

        prompt = new FlxSprite();
        prompt.loadGraphic(Paths.image("messagebox"));
        prompt.scale.scale(1.5);
        prompt.updateHitbox();
        prompt.screenCenter();
        add(prompt);

        var cancel = new HillButton(null, "CANCEL", 40, 80, 15);
        cancel.x = prompt.x + prompt.width / 2 + 80;
        cancel.scaleButton(1.5);
        cancel.y = prompt.y + prompt.height / 1.5 + 60;
        cancel.playSound = false;

        upgrade = new HillButton(null, "OK", 48, 120, 5); 
        upgrade.scaleButton(1.5);
        upgrade.x = cancel.x - cancel.width * 2 + 95;
        upgrade.y = cancel.y;
        upgrade.clickPress = close;
        add(upgrade);

        titleText = new FlxHillText();
        titleText.text = "MAXIMUM LEVEL";
        titleText.setPosition(230, 120);
        titleText.y -= titleText.height / 2;
        add(titleText);

        descText = new FlxHillText(80, 180);
        descText.size = 45;
        descText.text = "You have already upgraded this to the maximum level\navailable.";
        if (unlock)
        {
            descText.text = "You have already unlocked this.";
            descText.x += 60;
        }
        add(descText);
    }    

    override function update(elapsed:Float) 
    {
        super.update(elapsed);
    }
}