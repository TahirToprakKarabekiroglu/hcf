package;

import flixel.text.FlxText;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.util.FlxColor;

class CreditsSubstate extends MusicBeatSubstate
{
    var credits:Array<String> = [
        "This mod is based on Hill Climb Racing.",
        "Hill Climb Racing is by Fingersoft Ltd.\n",
        "The mod is by Tahir Toprak Karabekiroglu",
        "Unholywanderer04 is by Unholywanderer04",
        "Psych Engine 0.6.2 is by ShadowMario and RiverOaken",
        "Friday Night Funkin is by The Funkin Crew",
        "",
        "",
        "Thank you for playing!!"
    ];

    public function new() 
    {
        super();

        var bg:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
        bg.alpha = 0.6;
        add(bg);
        
        var prompt = new FlxSprite();
        prompt.loadGraphic(Paths.image("messagebox"));
        prompt.scale.scale(1.5);
        prompt.updateHitbox();
        prompt.screenCenter();
        add(prompt);

        var cancel = new HillButton(null, "CLOSE", 40, 80, 15);
        cancel.x = prompt.x + prompt.width / 2 + 80;
        cancel.scale.scale(1.5);
        cancel.y = prompt.y + prompt.height / 1.5 + 60;
        cancel.clickPress = close;
        add(cancel);

        var titleText = new FlxText();
        titleText.setFormat(Paths.font("vcr.ttf"), 64);
        titleText.text = "HILL CLIMB FUNKIN";
        titleText.setPosition(240, 120);
        titleText.y -= titleText.height / 2;
        add(titleText);

        var descText = new FlxText(240, 180);
        descText.setFormat(Paths.font("vcr.ttf"), 36); 
        add(descText);

        for (i in credits)
        {
            descText.text += i + "\n";
        }
    }

    override function update(elapsed:Float)
    {
        super.update(elapsed);
    }
}