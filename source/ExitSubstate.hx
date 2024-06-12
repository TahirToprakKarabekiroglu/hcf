package;

import flixel.text.FlxText;
import flixel.FlxG;
import flixel.util.FlxColor;
import flixel.FlxSprite;

class ExitSubstate extends MusicBeatSubstate 
{
    public var destroyFunc:Void -> Void;

    var state:PauseSubState;
    var prompt:FlxSprite;
    var cancel:HillButton;
    var exitText:HillButton;
    var titleText:FlxText;
    var descText:FlxText;

    public function new(exit:Bool = true, func:Void -> Void, state:PauseSubState) 
    {
        super();

        this.state = state;
        state.active = false;

        var description:String = "Restart will discard current progress, but you get to\nkeep all the coins you have collected so far.\n\nAre you sure you want to restart?";
        if (exit)
            description = "Exit will discard current progress, but you get to\nkeep all the coins you have collected so far.\n\nAre you sure you want to exit to menu?";

        var bg:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
        bg.alpha = 0.6;
        add(bg);

        prompt = new FlxSprite();
        prompt.loadGraphic(Paths.image("messagebox"));
        prompt.scale.scale(1.5);
        prompt.updateHitbox();
        prompt.screenCenter();
        add(prompt);

        cancel = new HillButton(null, "CANCEL", 40, 80, 15);
        cancel.x = prompt.x + prompt.width / 2 + 80;
        cancel.scale.scale(1.5);
        cancel.y = prompt.y + prompt.height / 1.5 + 60;
        cancel.clickPress = close;
        add(cancel);

        exitText = new HillButton(null, exit ? "EXIT_" : "RESTART", 40, 100, 15); 
        exitText.scale.scale(1.5);
        exitText.x = cancel.x - cancel.width * 2 + 95;
        exitText.y = cancel.y;
        exitText.clickPress = () -> {
            func();
            close();
        }
        add(exitText);

        titleText = new FlxText();
        titleText.setFormat(Paths.font("vcr.ttf"), 64);
        titleText.text = (exit ? "EXIT" : "RESTART") + "?";
        titleText.setPosition(240, 120);
        titleText.y -= titleText.height / 2;
        add(titleText);

        descText = new FlxText(240, 180);
        descText.setFormat(Paths.font("vcr.ttf"), 40); 
        descText.text = description;
        add(descText);
    }    

    override function close()
    {
        if (state != null)
            state.active = true;

        if (destroyFunc != null)
            destroyFunc();

        super.close();
    }
}