package;

import flixel.tweens.FlxTween;

class DownText extends FlxHillText
{
    var sine:Float = 0;
    var flashes:Bool = false;
    var flashEnded:Bool = false;

    public function new(x:Float = 0, y:Float = 0, text:String = "", angle:Float = 0, size:Int = 64, flashes:Bool = false)
    {
        super(x, y, text);
        this.size = size;

        var oldScale = {x: scale.x, y: scale.y}
        scale.set();
        alpha = 0;
        this.angle = -180;
        
        FlxTween.tween(this, {alpha: 1}, 0.2);
        FlxTween.tween(this, {angle: angle}, 0.2);
        FlxTween.tween(this.scale, {x: oldScale.x, y: oldScale.y}, 0.2, {onComplete: (tmr) -> {
            flashEnded = true;
        }});

        this.flashes = flashes;
    }

    override function update(elapsed:Float) 
    {
        super.update(elapsed);
        
        if (flashes && flashEnded)
        {
            sine += 360 * elapsed;
            alpha = 1 - Math.sin((Math.PI * sine) / 150);
        }
    }
}