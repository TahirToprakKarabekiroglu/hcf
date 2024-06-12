package;

import haxe.ds.StringMap;
import flixel.FlxCamera;
import flixel.util.FlxTimer;
import flixel.text.FlxText;
import flixel.FlxG;
import flixel.group.FlxSpriteGroup;

class UpgradeButton extends FlxSpriteGroup 
{
    var option:String;

    var button:FlxHillSprite;
    var button2:FlxHillSprite;    

    public var playSound:Bool = true;
    public var clickPress:Void -> Void;

    public function new(?type:String) 
    {
        super();

        this.option = type;

        button = new FlxHillSprite();
        button.loadGraphic(Paths.image(type));
        add(button);

        button2 = new FlxHillSprite();
        button2.loadGraphic(Paths.image(type + "Pressed"));
        button2.visible = false;
        add(button2);
    }

    var timer:FlxTimer;
    override function update(elapsed:Float)
    {
        super.update(elapsed);

        if (FlxG.mouse.overlaps(this) && active)
        {
            if (FlxG.mouse.pressed)
            {
                button.visible = false;
                button2.visible = true;
            }
            else if (FlxG.mouse.justReleased)
            {
                button.visible = true;
                button2.visible = false;
            }

            if (FlxG.mouse.justPressed)
            {
                if (playSound)
                    FlxG.sound.play(Paths.sound("click"));

                if (clickPress != null && button2.visible)
                {
                    if (timer != null)
                        timer.cancel();

                    timer = new FlxTimer().start(0.1, (tmr) -> {
                        clickPress();
                        timer.destroy();
                        timer = null;
                    });
                }
            }
        }
        else 
        {
            button.visible = true;
            button2.visible = false;
        }
    }
}