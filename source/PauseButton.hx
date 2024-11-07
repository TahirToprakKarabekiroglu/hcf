package;

import flixel.FlxCamera;
import flixel.group.FlxSpriteGroup;
import flixel.util.FlxColor;

class PauseButton extends FlxSpriteGroup
{
    var button1:FlxHillSprite;
    public var pause:Void -> Void;
    public var thiscamera:FlxCamera;

    public function new()
    {
        super(x, y);

        button1 = new FlxHillSprite();
        button1.loadGraphic(Paths.image("CloseNormal"));
        add(button1);
    }

    override function update(elapsed:Float) 
    {
        super.update(elapsed);
        
        if (FlxG.mouse.overlaps(this, thiscamera))
        {
            if (FlxG.mouse.justPressed)
            {
                if (SoundButton.soundEnabled)
                    FlxG.sound.play(Paths.sound("click"));
            }
            if (FlxG.mouse.pressed)
            {
                button1.color = FlxColor.fromHSB(button1.color.hue, button1.color.saturation, 0.7);
            }
            if (FlxG.mouse.justReleased)
            {
                button1.color = FlxColor.fromHSB(button1.color.hue, button1.color.saturation, 1);
                if (pause != null)
                    pause();
            }
        }
        else
        {
            button1.color = FlxColor.fromHSB(button1.color.hue, button1.color.saturation, 1);
        }
    }
}