package;

import flixel.group.FlxSpriteGroup;
import flixel.util.FlxColor;

class SoundButton extends FlxSpriteGroup
{
    public static var soundEnabled:Bool = true;
    public static var musicEnabled:Bool = true;

    var button1:FlxHillSprite;
    var button2:FlxHillSprite;
    var music:Bool = false;

    public function new(music:Bool = false)
    {
        super(x, y);

        this.music = music;

        var sound = music ? "music" : "sound";
        button1 = new FlxHillSprite();
        button1.loadGraphic(Paths.image("button-" + sound + "-enabled"));
        add(button1);

        button2 = new FlxHillSprite();
        button2.loadGraphic(Paths.image("button-" + sound + "-disabled"));
        add(button2);

        button1.visible = music ? musicEnabled : soundEnabled;
        button2.visible = !button1.visible;
    }

    override function update(elapsed:Float) 
    {
        super.update(elapsed);
        
        if (FlxG.mouse.overlaps(this))
        {
            if (FlxG.mouse.justPressed)
            {
                if (soundEnabled)
                    FlxG.sound.play(Paths.sound("click"));
            }
            if (FlxG.mouse.pressed)
            {
                button1.color = FlxColor.fromHSB(button1.color.hue, button1.color.saturation, 0.7);
                button2.color = FlxColor.fromHSB(button1.color.hue, button1.color.saturation, 0.7);
            }
            if (FlxG.mouse.justReleased)
            {
                button1.color = FlxColor.fromHSB(button1.color.hue, button1.color.saturation, 1);
                button2.color = FlxColor.fromHSB(button1.color.hue, button1.color.saturation, 1);

                music ? musicEnabled = !musicEnabled : soundEnabled = !soundEnabled;
                button1.visible = music ? musicEnabled : soundEnabled;
                button2.visible = !button1.visible;

                if (music)
                {
                    if (!musicEnabled)
                    {
                        FlxG.sound.music.stop();
                    }
                    else
                    {
                        FlxG.sound.playMusic(Paths.music("bgmusic00"));
                    }
                }

                FlxG.save.data.musicEnabled = musicEnabled;
                FlxG.save.data.soundEnabled = soundEnabled;
                FlxG.save.flush();
            }
        }
        else
        {
            button1.color = FlxColor.fromHSB(button1.color.hue, button1.color.saturation, 1);
            button2.color = FlxColor.fromHSB(button1.color.hue, button1.color.saturation, 1);
        }
    }
}