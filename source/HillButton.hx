package;

import flixel.FlxCamera;
import flixel.util.FlxTimer;
import flixel.text.FlxText;
import flixel.FlxG;
import flixel.group.FlxSpriteGroup;

class HillButton extends FlxSpriteGroup 
{
    var button:FlxHillSprite;
    var button2:FlxHillSprite;    
    var text:FlxText;

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
            text = new FlxText();
            text.setFormat(Paths.font("vcr.ttf"), size);
            text.alignment = FlxTextAlign.CENTER;
            text.offset.x -= offx;
            text.offset.y -= offy;
            text.text = texts.split('_').join('');

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
        else if (texts == "UNLOCK" || texts == "UPGRADE" || texts == "RESUME" || texts == "EXIT_" || texts == "OK")
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
            coin.offset.set(-10, -10);
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
    }

    var timer:FlxTimer;
    override function update(elapsed:Float)
    {
        super.update(elapsed);

        if (FlxG.mouse.overlaps(this, _camera) && active)
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