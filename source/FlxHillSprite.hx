package;

import flixel.FlxG;
import flixel.FlxCamera;
import flixel.math.FlxPoint;
import flixel.FlxSprite;

class FlxHillSprite extends FlxSprite
{
    @:noCompletion
    override public function overlapsPoint(point:FlxPoint, inScreenSpace = false, ?camera:FlxCamera):Bool
	{
        var width = Math.abs(scale.x) * frameWidth;
        var height = Math.abs(scale.y) * frameHeight;
        var ogPoint = point;
        var point = point.clone();
        var offset = FlxPoint.weak(-0.5 * (width - frameWidth), -0.5 * (height - frameHeight));
        point.x -= (offset.x - this.offset.x);
        point.y -= (offset.y - this.offset.y);

		if (!inScreenSpace)
		{
			return (point.x >= x) && (point.x < x + width) && (point.y >= y) && (point.y < y + height);
		}

		if (camera == null)
		{
			camera = FlxG.camera;
		}
		var xPos:Float = point.x - camera.scroll.x;
		var yPos:Float = point.y - camera.scroll.y;
		getScreenPosition(_point, camera);
        ogPoint.putWeak();
        offset.putWeak();
		point.putWeak();
		return (xPos >= _point.x) && (xPos < _point.x + width) && (yPos >= _point.y) && (yPos < _point.y + height);
	}    
}