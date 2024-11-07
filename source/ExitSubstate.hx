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
    var titleText:FlxHillText;
    var descText:FlxHillText;

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

        cancel = new HillButton(null, "CANCEL", 48, 60, 5);
        cancel.x = prompt.x + prompt.width / 2 + 80;
        cancel.scaleButton(1.5);
        cancel.y = prompt.y + prompt.height / 1.5 + 60;
        cancel.clickPress = close;
        add(cancel);

        exitText = new HillButton(null, exit ? "EXIT_" : "RESTART_", 48, exit ? 100 : 60, 5); 
        exitText.scaleButton(1.5);
        exitText.x = cancel.x - cancel.width * 2 + 95;
        exitText.y = cancel.y;
        exitText.clickPress = () -> {
            func();
            close();
        }
        add(exitText);

        titleText = new FlxHillText();
        titleText.text = (exit ? "EXIT" : "RESTART") + "?";
        titleText.setPosition(230, 120);
        titleText.y -= titleText.height / 2;
        add(titleText);

        descText = new FlxHillText(75, 160);
        descText.size = 45;
        descText.text = description;
        add(descText);

        if (exit)
            descText.x += 15;
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