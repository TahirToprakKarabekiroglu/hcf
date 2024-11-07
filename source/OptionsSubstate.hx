package;

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
        ["Random Mode: ", "random"],
    ];

    var maxSelected:Int;

    var descText:FlxHillText;
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

        maxSelected++;
        settings.push(["Downscroll: ", "downscroll"]);

        maxSelected++;
        settings.push(["Antialiasing: ", "antialiasing"]);
                
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

        maxSelected++;
        settings.push(["FPS Limit: ", "fps"]);

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

        var cancel = new HillButton(null, "CANCEL", 48, 60, 5);
        cancel.x = prompt.x + prompt.width / 2 + 80;
        cancel.scaleButton(1.5);
        cancel.y = prompt.y + prompt.height / 1.5 + 60;
        cancel.clickPress = close;
        add(cancel);

        var titleText = new FlxHillText();
        titleText.text = "OPTIONS";
        titleText.setPosition(240, 120);
        titleText.y -= titleText.height / 2;
        add(titleText);

        descText = new FlxHillText();
        descText.size = 48;
        add(descText);

        changeSelection();
    }
    
    var holdTime:Float = 0;
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
            else if (settings[curSelected - 4][1] == "fps")
            {
                changeFPS(FlxG.keys.justPressed.LEFT ? -1 : 1);
            }
            else 
            {
                changeOption();
            }
        }
        else if (FlxG.keys.pressed.LEFT || FlxG.keys.pressed.RIGHT)
        {
            var pressed = (FlxG.keys.justPressed.LEFT || FlxG.keys.justPressed.RIGHT);
            if (holdTime > 0.5 || pressed)
            {
                changeFPS((FlxG.keys.pressed.LEFT || FlxG.keys.justPressed.LEFT) ? -1 : 1);
            }

            holdTime += elapsed;
        }
        else if (FlxG.keys.released.LEFT || FlxG.keys.released.RIGHT)
        {
            holdTime = 0;
        }
    }

    override function close()
    {
        FlxSprite.defaultAntialiasing = FlxG.save.data.antialiasing;
        super.close();
    }

    function changeFPS(value:Int)
    {
        if (settings[curSelected - 4] == null || settings[curSelected - 4][1] != "fps")
            return;

        if (FlxG.save.data.fps < 60)
        {
            FlxG.save.data.fps = 60;
            FlxG.save.flush();
        }
        else if (FlxG.save.data.fps > 450)
        {
            FlxG.save.data.fps = 450;
            FlxG.save.flush();
        }

        FlxG.drawFramerate = FlxG.updateFramerate = FlxG.save.data.fps;
        updateTexts();

        if (FlxG.save.data.fps + value < 60)
            return;
        else if (FlxG.save.data.fps + value > 450)
            return;

        FlxG.save.data.fps += value;
        FlxG.save.flush();

        FlxG.drawFramerate = FlxG.updateFramerate = FlxG.save.data.fps;
        
        updateTexts();
    }

    function changeOption()
    {
        if (settings[curSelected - 4] == null)
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
            if (settings[settings.indexOf(i)][1] == "fps")
            {
                descText.text += "\n" + i[0];

                if (index == curSelected)
                    descText.text += "< " + FlxG.save.data.fps + " > FPS";
                else
                    descText.text += FlxG.save.data.fps + " FPS";
            }
            else
            {
                if (index == curSelected)
                    descText.text += text + " <";
                else 
                    descText.text += text;
            }
        }

        descText.setPosition(200, 120);
    }
}