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
            if (FlxG.mouse.justPressed)
            {
                if (playSound && SoundButton.soundEnabled)
                    FlxG.sound.play(Paths.sound("click"));
            }
            if (FlxG.mouse.justReleased)
            {
                button.visible = true;
                button2.visible = false;

                if (clickPress != null)
                    clickPress();
            }
        }
        else 
        {
            button.visible = true;
            button2.visible = false;
        }
    }
}