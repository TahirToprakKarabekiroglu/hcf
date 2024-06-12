package;

import flixel.text.FlxText;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.util.FlxColor;

class OptionsSubstate extends MusicBeatSubstate 
{
    var curSelected:Int = 0;
    var keybinds:Array<Array<String>> = [
        ["Left Coin: ", "coin5"],
        ["Down Coin: ", "coin25"],
        ["Up Coin: ", "coin100"], 
        ["Right Coin: ", "coin500"],
    ];

    var keys = [for (i in 0...4) 
    {
        [
            'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 
            'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z'
        ];
    }];

    var settings:Array<Array<String>> = [];

    var settingsOg:Array<Array<String>> = [
        ["Downscroll: ", "downscroll"],
        ["Random Mode: ", "random"],
    ];

    var maxSelected:Int;

    var descText:FlxText;
    public function new() 
    {
        DiscordClient.changePresence("In options menu");

        for (i in keybinds)
        {
            if (Reflect.field(FlxG.save.data, i[1]) == null)
            {
                var key = switch i[1] {
                    case "coin5": "A";
                    case "coin25": "S";
                    case "coin100": "W";
                    case "coin500": "D";
                    case _: null;
                }

                if (key != null)
                {
                    Reflect.setField(FlxG.save.data, i[1], key);
                    FlxG.save.flush();
                }
            }
            maxSelected++;
        }

        for (i in settingsOg)
        {
            if (Reflect.field(FlxG.save.data, i[1] + "Unlocked") == true)
            {
                maxSelected++;
                settings.push(i);

                if (Reflect.field(FlxG.save.data, i[1]) == null)
                {
                    Reflect.setField(FlxG.save.data, i[1], false);
                    FlxG.save.flush();
                }
            }
        }

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
        titleText.text = "SETTINGS";
        titleText.setPosition(240, 120);
        titleText.y -= titleText.height / 2;
        add(titleText);

        descText = new FlxText(240, 180);
        descText.setFormat(Paths.font("vcr.ttf"), 36); 
        add(descText);

        changeSelection();
    }
    
    override function update(elapsed:Float) 
    {
        super.update(elapsed);

        if (FlxG.keys.justPressed.DOWN)
        {
            changeSelection(1);
        }
        else if (FlxG.keys.justPressed.UP)
        {
            changeSelection(-1);
        }
        else if (FlxG.keys.justPressed.LEFT || FlxG.keys.justPressed.RIGHT)
        {
            if (curSelected < 4)
            {
                changeKey(FlxG.keys.justPressed.LEFT ? -1 : 1);
            }
            else 
            {
                changeOption();
            }
        }
    }

    function changeOption()
    {
        if (maxSelected < 5)
            return;

        var curOption:Bool = Reflect.field(FlxG.save.data, settings[curSelected - 4][1]);
        curOption = !curOption;

        Reflect.setField(FlxG.save.data, settings[curSelected - 4][1], curOption);
        FlxG.save.flush();

        updateTexts();
    }

    function changeKey(selection:Int = 0)
    {
        var curKey:String = Reflect.field(FlxG.save.data, keybinds[curSelected][1]);
        var index:Int = keys[curSelected].indexOf(curKey);
        index += selection;
        
        if (index > keys[curSelected].length - 1)
            index = 0;
        else if (index < 0)
            index = keys[curSelected].length - 1;

        Reflect.setField(FlxG.save.data, keybinds[curSelected][1], keys[curSelected][index]);
        FlxG.save.flush();

        PlayerSettings.player1.controls.setKeyboardScheme();
        updateTexts();
    }

    function changeSelection(selection:Int = 0)
    {
        curSelected += selection;

        if (curSelected > maxSelected - 1)
            curSelected = 0;
        else if (curSelected < 0)
            curSelected = maxSelected - 1;

        updateTexts();
    }

    function updateTexts()
    {
        descText.text = "";

        for (i in keybinds)
        {
            var index = keybinds.indexOf(i);

            if (index == curSelected)
                descText.text += i[0] + "< " + Reflect.field(FlxG.save.data, i[1]) + " >" + "\n";
            else 
                descText.text += i[0] + Reflect.field(FlxG.save.data, i[1]) + "\n";
        }

        for (i in settings)
        {
            var index = settings.indexOf(i) + 4;
            var on:Bool = Reflect.field(FlxG.save.data, i[1]);

            var text = "\n" + i[0] + (on ? "ON" : "OFF");
            if (index == curSelected)
                descText.text += text + " <";
            else 
                descText.text += text;
        }
    }
}