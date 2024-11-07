package;

import flixel.FlxCamera;
import flixel.FlxG;
import flixel.group.FlxSpriteGroup;

class HillButton extends FlxSpriteGroup 
{
    var button:FlxHillSprite;
    var button2:FlxHillSprite;    
    var text:FlxHillText;

    public var playSound:Bool = true;
    public var clickPress:Void -> Void;

    public static var _camera:FlxCamera;

    public function new(?type:String, ?texts:String, ?size:Int = 32, ?offx:Float = 0, ?offy:Float = 0) 
    {
        super();    

        if (_camera != null)
            cameras = [_camera];

        var buttonstr = switch type.toLowerCase()
        {
            case "left": "button-bg-left";
            case "right": "button-bg-right";
            case _: "button-bg";
        }

        button = new FlxHillSprite();
        button.loadGraphic(Paths.image(buttonstr));
        add(button);

        button2 = new FlxHillSprite();
        button2.loadGraphic(Paths.image(buttonstr + "-pressed"));
        button2.visible = false;
        add(button2);

        if (texts != null)
        {
            text = new FlxHillText();
            text.text = texts.split('_').join('');
            text.x += offx;
            text.y += offy;
            text.size = size;
            add(text);
        }

        if (texts == "CANCEL" || texts == "CLOSE" || texts == "EXIT")
        {
            var x:FlxHillSprite = new FlxHillSprite();
            x.loadGraphic(Paths.image("discard"));
            x.offset.set(25, -15);
            if (texts == "EXIT")
                x.offset.x -= 15;
            add(x);
        }
        else if (texts == "UNLOCK" || texts == "UPGRADE" || texts == "RESUME" || texts == "EXIT_" || texts == "OK" || texts == "RESTART_")
        {
            var x:FlxHillSprite = new FlxHillSprite();
            x.loadGraphic(Paths.image("accept"));
            x.offset.set(25, -15);
            if (texts == "RESUME")
                x.offset.x -= 15;
            add(x);
        }
        else if (texts == "CREDITS")
        {
            var coin:FlxHillSprite = new FlxHillSprite();
            coin.loadGraphic(Paths.image("coin"));
            coin.offset.set(8, -10);
            add(coin);
        }
        else if (texts == "RESTART")
        {
            var coin:FlxHillSprite = new FlxHillSprite();
            coin.loadGraphic(Paths.image("restart"));
            coin.offset.x -= -10;
            coin.offset.y -= 15;
            add(coin);
        }
        else if (texts == "START")
        {
            var coin:FlxHillSprite = new FlxHillSprite();
            coin.loadGraphic(Paths.image("icon-start"));
            coin.offset.x -= -10;
            coin.offset.y -= 20;
            add(coin);
        }
    }

    override function update(elapsed:Float)
    {
        super.update(elapsed);

        if (FlxG.mouse.overlaps(this, _camera) && active)
        {
            if (FlxG.mouse.justPressed)
            {
                if (playSound && SoundButton.soundEnabled)
                    FlxG.sound.play(Paths.sound("click"));
            }
            if (FlxG.mouse.pressed)
            {
                button.visible = false;
                button2.visible = true;
            }
            if (FlxG.mouse.justReleased)
            {
                button.visible = true;
                button2.visible = false;

                if (clickPress != null)
                {
                    clickPress();
                }
            }
        }
        else 
        {
            button.visible = true;
            button2.visible = false;
        }
    }

    public function scaleButton(scale:Float = 1.0)
    {
        for (i in members)
        {
            if ((i is FlxHillText))
            {
                var i = cast(i, FlxHillText);
                i.size = Std.int(i.size * scale);
                continue;
            }

            i.scale.scale(scale);
        }
    }
}