package;

import flixel.tweens.FlxTween;
import flixel.FlxSprite;

class DownSprite extends FlxSprite
{
    public function new(extra:String = "idle")
    {
        super();

        loadGraphic(Paths.image("share/share-result-button-" + PlayState.curStage.toLowerCase() + "-" + extra));
        screenCenter();
        x -= width + 25;
        y -= 60;
        scale.set();
        //updateHitbox();
        angle = -200;

        FlxG.sound.play(Paths.sound("camera-shutter"));
        FlxTween.tween(this, {angle: -2}, 0.2);
        FlxTween.tween(this.scale, {x: 2.25, y: 2.25}, 0.2, {onUpdate: (twn) -> {
            //updateHitbox();
        }});
    }
}