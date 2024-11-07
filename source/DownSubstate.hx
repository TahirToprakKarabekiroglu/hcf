package;

import flixel.sound.FlxSound;
import flixel.util.FlxStringUtil;
import flixel.util.FlxTimer;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.FlxSprite;

enum DownType
{
    DIED;
    OUT_OF_BATTERY;
    SUCCESS;
}

class DownSubstate extends MusicBeatSubstate
{
    public var down:DownSprite;
    var onClick:Void -> Void;
    var music:FlxSound;
    var canClick:Bool = false;

    public function new(downType:DownType, distance:Float = 0, coinsGot:Int = 99999, totalNotesHit:Int = 0, score:Float = 0, misses:Int = 0, accuracy:Int = 0, ?onClick:Void -> Void, endingSong:Bool = true) 
    {
        super();
        
        var bg:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
        bg.alpha = 0;
        add(bg);

        var title = switch downType
        {
            case DIED: "DRIVER DOWN";
            case SUCCESS: "SONG FINISHED";
            case OUT_OF_BATTERY: "OUT OF BATTERY";
            case _: "null";
        }

        var alt = switch downType
        {
            case DIED: "neck";
            case OUT_OF_BATTERY: "idle";
            case _: "hey";
        }

        var onFinish:Void -> Void = () -> {
            down = new DownSprite(alt);
            add(down);

            new FlxTimer().start(0.4, (tmr) -> {
                var text:DownText = new DownText(FlxG.width / 2 + 75, 50, title, 2, 96);
                add(text);

                FlxG.sound.play(Paths.sound("splash"));

                new FlxTimer().start(0.4, (tmr) -> {
                    var text:DownText = new DownText(FlxG.width / 2 + 25, 200, "DISTANCE: " + FlxStringUtil.formatTime(distance / 1000), -2, 80);
                    add(text);

                    FlxG.sound.play(Paths.sound("splash-add"));

                    new FlxTimer().start(0.4, (tmr) -> {
                        var text:DownText = new DownText(FlxG.width / 2 + 200, 270, "+" + coinsGot + " COINS", 2, 80);
                        add(text);

                        FlxG.sound.play(Paths.sound("splash-add"));

                        new FlxTimer().start(0.2, (tmr) -> {
                            var text:DownText = new DownText(FlxG.width / 2 + 20, 340, totalNotesHit + "xNOTES HIT", -2, 64);
                            add(text);

                            FlxG.sound.play(Paths.sound("splash-add"));

                            new FlxTimer().start(0.2, (tmr) -> {
                                var text:DownText = new DownText(FlxG.width / 2 + 350, 360, score + "KxSCORE", 2, 64);
                                add(text);
    
                                FlxG.sound.play(Paths.sound("splash-add"));

                                new FlxTimer().start(0.2, (tmr) -> {
                                    var text:DownText = new DownText(FlxG.width / 2 + 45, 420, misses + "xMISSES", -2, 64);
                                    add(text);
        
                                    FlxG.sound.play(Paths.sound("splash-add"));

                                    new FlxTimer().start(0.2, (tmr) -> {
                                        var text:DownText = new DownText(FlxG.width / 2 + 320, 450, accuracy + "xACCURACY", 1, 64);
                                        add(text);
            
                                        FlxG.sound.play(Paths.sound("splash-add"));

                                        new FlxTimer().start(0.4, (tmr) -> {
                                            var text:DownText = new DownText(FlxG.width / 2 + 60, 525, "TOUCH TO CONTINUE", 0, 80, true);
                                            add(text);
                
                                            FlxG.sound.play(Paths.sound("splash"));
                                            canClick = true;
                                        });
                                    });
                                });
                            });
                        });
                    });
                });
            });
        }

        FlxTween.tween(bg, {alpha: 0.6}, 0.8);
        new FlxTimer().start(0.4, (tmr) -> onFinish());

        cameras = [FlxG.cameras.list[FlxG.cameras.list.length - 1]];
        this.onClick = onClick;
        trace(endingSong, FlxG.sound.music.time);
        if (!endingSong)
        {
            music = new FlxSound();
            music.loadEmbedded(Paths.inst(PlayState.SONG.song), true);
            music.play();
            music.time = FlxG.sound.music.time;
        }

        var state = switch downType
        {
            case DIED: "DRIVER DOWN";
            case SUCCESS: PlayState.curStage.toUpperCase() + " FINISHED";
            case OUT_OF_BATTERY: "OUT OF BATTERY";
            case _: "null";
        }

        DiscordClient.changePresence("Hill Climb Funkin", state);
    }

    override function update(elapsed:Float)
    {
        super.update(elapsed);
        
        if (FlxG.mouse.justPressed && canClick)
        {
            if (onClick != null)
                onClick();
        }
    }

    override function destroy()
    {
        if (music != null)
        {
            music.kill();
            music.destroy();
            music = null;
        }
        super.destroy();
    }
}