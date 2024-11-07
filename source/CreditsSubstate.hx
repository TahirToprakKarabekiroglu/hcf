package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.util.FlxColor;

class CreditsSubstate extends MusicBeatSubstate
{
    var credits:Array<String> = [
        "This mod is based on Hill Climb Racing.",
        "Hill Climb Racing is by Fingersoft Ltd.\n",
        "The mod is by Tahir Toprak Karabekiroglu",
        "Psych Engine 0.6.2 is by ShadowMario and RiverOaken",
        "Friday Night Funkin is by The Funkin Crew Inc.",
        "",
        "",
        "Thank you for playing!!"
    ];

    public function new() 
    {
        super();

        DiscordClient.changePresence("Checking credits");

        var bg:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
        bg.alpha = 0.6;
        add(bg);
        
        var prompt = new FlxSprite();
        prompt.loadGraphic(Paths.image("messagebox"));
        prompt.scale.scale(1.5);
        prompt.updateHitbox();
        prompt.screenCenter();
        add(prompt);

        var cancel = new HillButton(null, "CANCEL", 48, 60, 5);
        cancel.x = prompt.x + prompt.width / 2 + 80;
        cancel.scaleButton(1.5);
        cancel.y = prompt.y + prompt.height / 1.5 + 60;
        cancel.clickPress = close;
        add(cancel);

        var titleText = new FlxHillText();
        titleText.text = "HILL CLIMB FUNKIN";
        titleText.setPosition(240, 120);
        titleText.y -= titleText.height / 2;
        add(titleText);

        var descText = new FlxHillText(240, 180);
        add(descText);

        for (i in credits)
        {
            descText.text += i + "\n";
        }

        descText.size = 44;
    }

    override function update(elapsed:Float)
    {
        super.update(elapsed);
    }
}