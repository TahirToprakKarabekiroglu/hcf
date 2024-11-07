package;

import openfl.display.BitmapData;
import flixel.graphics.FlxGraphic;
import sys.io.File;
import flixel.graphics.frames.FlxBitmapFont;
import flixel.text.FlxBitmapText;

class FlxHillText extends FlxBitmapText 
{
    public var size(default, set):Int = 0;
    
    var firstSetSize:Bool = true;
    
    public function new(x:Float = 0, y:Float = 0, text:String = "")
    {
        super(x, y);

        font = FlxBitmapFont.fromAngelCode(FlxGraphic.fromBitmapData(BitmapData.fromFile(Paths.font("gamefont.png"))), Xml.parse(File.getContent(Paths.font("gamefont.fnt"))));
        letterSpacing = 4;
        size = font.size;
        firstSetSize = false;
        this.text = text;
    }

    function set_size(value:Int):Int 
    {
        if (firstSetSize)
        {
            return size = value;
        }

        scale.set(value / 64, value / 64);
        updateHitbox();
        return size = value;
    }

    function get_size():Int 
    {
        throw new haxe.exceptions.NotImplementedException();
    }
}