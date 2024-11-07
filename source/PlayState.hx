package;

import openfl.media.Sound;
import flixel.util.FlxSpriteUtil;
import flixel.graphics.FlxGraphic;
#if desktop
import Discord.DiscordClient;
#end
import Section.SwagSection;
import DownSubstate;
import Song.SwagSong;
import flixel.FlxBasic;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxGame;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.FlxSubState;
import flixel.addons.display.FlxGridOverlay;
import flixel.addons.effects.FlxTrail;
import flixel.addons.effects.FlxTrailArea;
import flixel.addons.effects.chainable.FlxEffectSprite;
import flixel.addons.effects.chainable.FlxWaveEffect;
import flixel.addons.transition.FlxTransitionableState;
import flixel.graphics.atlas.FlxAtlas;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.system.FlxSound;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.ui.FlxBar;
import flixel.util.FlxCollision;
import flixel.util.FlxColor;
import flixel.util.FlxSort;
import flixel.util.FlxStringUtil;
import flixel.util.FlxTimer;
import haxe.Json;
import lime.utils.Assets;
import openfl.Lib;
import openfl.display.BlendMode;
import openfl.display.StageQuality;
import openfl.filters.BitmapFilter;
import openfl.utils.Assets as OpenFlAssets;
import flixel.group.FlxSpriteGroup;
import flixel.input.keyboard.FlxKey;
import Note.EventNote;
import openfl.events.KeyboardEvent;
import flixel.effects.particles.FlxEmitter;
import flixel.effects.particles.FlxParticle;
import flixel.util.FlxSave;
import flixel.animation.FlxAnimationController;

#if !flash 
import flixel.addons.display.FlxRuntimeShader;
import openfl.filters.ShaderFilter;
#end

#if sys
import sys.FileSystem;
import sys.io.File;
#end


using StringTools;

class PlayState extends MusicBeatState
{
	public static var STRUM_X_MIDDLESCROLL = -278;

	public var noteKillOffset:Float = 350;

	public static var curStage:String = '';
	public static var SONG:SwagSong = null;

	public var spawnTime:Float = 2000;

	public var vocals:FlxSound;

	public var boyfriend:Boyfriend = null;

	public var notes:FlxTypedGroup<Note>;
	public var unspawnNotes:Array<Note> = [];

	private var strumLine:FlxSprite;

	//Handles the new epic mega sexy cam code that i've done
	public var camFollow:FlxPoint;
	public var camFollowPos:FlxObject;
	private static var prevCamFollow:FlxPoint;
	private static var prevCamFollowPos:FlxObject;

	public var strumLineNotes:FlxTypedGroup<StrumNote>;
	public var playerStrums:FlxTypedGroup<StrumNote>;

	public var gfSpeed:Int = 1;
	public var health:Float = 1;
	public var combo:Int = 0;

	private var generatedMusic:Bool = false;
	public var endingSong:Bool = false;
	public var startingSong:Bool = false;

	//Gameplay settings
	public var camHUD:FlxCamera;
	public var camGame:FlxCamera;
	public var camOther:FlxCamera;
	public var cameraSpeed:Float = 1;

	public var songScore:Int = 0;
	public var songHits:Int = 0;
	public var songMisses:Int = 0;
	var coinTween:FlxTween;

	var battery:Float = 1;
	var batteryTween:FlxTween;

	private var singAnimations:Array<String> = ['singLEFT', 'singDOWN', 'singUP', 'singRIGHT'];

	#if desktop
	// Discord RPC variables
	var detailsText:String = "";
	var detailsPausedText:String = "";
	#end

	// Lua shit
	public static var instance:PlayState;

	// Less laggy controls
	private var keysArray:Array<Dynamic>;
	private var controlArray:Array<String>;

	var precacheList:Map<String, String> = new Map<String, String>();

	var initialCoin:Int = 0;

	override public function create()
	{
		//trace('Playback Rate: ' + playbackRate);
		Paths.clearStoredMemory();

		initialCoin = Std.int(FlxG.save.data.coin + 0);

		// for lua
		instance = this;

		keysArray = [
			[FlxKey.fromString(FlxG.save.data.coin5), FlxKey.LEFT],
			[FlxKey.fromString(FlxG.save.data.coin25), FlxKey.DOWN],
			[FlxKey.fromString(FlxG.save.data.coin100), FlxKey.UP],
			[FlxKey.fromString(FlxG.save.data.coin500), FlxKey.RIGHT],
		];

		controlArray = [
			'NOTE_LEFT',
			'NOTE_DOWN',
			'NOTE_UP',
			'NOTE_RIGHT'
		];

		if (FlxG.sound.music != null)
			FlxG.sound.music.stop();

		// var gameCam:FlxCamera = FlxG.camera;
		camGame = new FlxCamera();
		camHUD = new FlxCamera();
		camOther = new FlxCamera();
		camHUD.bgColor.alpha = 0;
		camOther.bgColor.alpha = 0;

		FlxG.cameras.reset(camGame);
		FlxG.cameras.add(camHUD, false);
		FlxG.cameras.add(camOther, false);

		FlxG.cameras.setDefaultDrawTarget(camGame, true);

		persistentUpdate = true;
		persistentDraw = true;

		if (SONG == null)
			SONG = Song.loadFromJson('tutorial');

		Conductor.mapBPMChanges(SONG);
		Conductor.changeBPM(SONG.bpm);

		#if desktop
		// String that contains the mode defined here so it isn't necessary to call changePresence for each mode
		detailsText = "Hill Climb Funkin";
		// String for when the game is paused
		detailsPausedText = "Paused";
		#end

		FlxG.camera.zoom = 0.4;

		var songName:String = Paths.formatToSongPath(SONG.song);

		var bg:FlxSprite = new FlxSprite().loadGraphic(Paths.image(curStage.toLowerCase()));
		bg.scale.scale(2.5);
		bg.updateHitbox();
		bg.screenCenter();
		bg.scrollFactor.set();
		add(bg);

		boyfriend = new Boyfriend(0, 0, SONG.player1);
		add(boyfriend);

		switch curStage.toLowerCase()
		{
			case "countryside":
				boyfriend.x -= 400;
				boyfriend.y -= 450;
			case "desert":
				boyfriend.y -= 530;
				boyfriend.angle -= 7;
			case "arctic":
				var snow:FlxEmitter = new FlxEmitter(0, 0, 200);
				for (i in 0...200)
				{
					var snowflake:FlxParticle = new FlxParticle();
					snowflake.antialiasing = false;
					snowflake.loadGraphic(Paths.image("snowflakes/snowflake" + FlxG.random.int(1, 6)));
					snow.add(snowflake);
				}

				snow.cameras = [camOther];
				snow.width = FlxG.width;
				snow.launchMode = SQUARE;
				snow.y -= 50;
				snow.velocity.set(-10, 80, 0, 120);
				snow.lifespan.set(0);
				add(snow);
				snow.start(false, 0.05);

				boyfriend.y -= 430;
			case "moon":
				boyfriend.y -= 475;
		}

		var camPos:FlxPoint = new FlxPoint(0, 0);

		Conductor.songPosition = -5000 / Conductor.songPosition;

		strumLine = new FlxSprite(STRUM_X_MIDDLESCROLL, 50).makeGraphic(FlxG.width, 10);
		if(FlxG.save.data.downscroll) strumLine.y = FlxG.height - 100;
		strumLine.scrollFactor.set();

		strumLineNotes = new FlxTypedGroup<StrumNote>();
		add(strumLineNotes);

		playerStrums = new FlxTypedGroup<StrumNote>();

		// startCountdown();

		generateSong(SONG.song);

		// After all characters being loaded, it makes then invisible 0.01s later so that the player won't freeze when you change characters
		// add(strumLine);
		
		var heart = new FlxSprite().loadGraphic(Paths.image("health"));
		heart.x = 10;
		heart.y = 10;
		add(heart);

		healthBar = new FlxBar(heart.x * 2 + 60, heart.y + 15, LEFT_TO_RIGHT, 150, 40, this, "health", 0, 2);
		healthBar.createGradientBar([FlxColor.TRANSPARENT], [FlxColor.RED, FlxColor.fromRGB(225, 0, 0), FlxColor.RED], 1, 90);
		add(healthBar);

		var borderh:FlxSprite = new FlxSprite().makeGraphic(Std.int(healthBar.width), Std.int(healthBar.height), FlxColor.TRANSPARENT);
		borderh.setPosition(healthBar.x, healthBar.y);
		FlxSpriteUtil.drawRect(borderh, 0, 0, borderh.width, borderh.height, FlxColor.TRANSPARENT, {thickness: 5, color: FlxColor.BLACK});
		add(borderh);

		var battery = new FlxSprite().loadGraphic(Paths.image("batteryicon"));
		battery.x = 10;
		battery.y = 75;

		batteryBar = new FlxBar(battery.x * 2 + 60, battery.y + 15, LEFT_TO_RIGHT, 150, 40, this, "battery", 0, 1);
		batteryBar.createGradientBar([FlxColor.TRANSPARENT], [FlxColor.GREEN, FlxColor.fromRGB(0, 225, 0), FlxColor.GREEN], 1, 90);
		add(battery);

		var border:FlxSprite = new FlxSprite().makeGraphic(Std.int(batteryBar.width), Std.int(batteryBar.height), FlxColor.TRANSPARENT);
		border.setPosition(batteryBar.x, batteryBar.y);
		FlxSpriteUtil.drawRect(border, 0, 0, border.width, border.height, FlxColor.TRANSPARENT, {thickness: 5, color: FlxColor.BLACK});

		add(batteryBar);
		add(border);

		var coin = new FlxSprite();
		coin.loadGraphic(Paths.image("coin"));
		coin.x = battery.x;
		coin.y = battery.y + battery.height + 5;
		add(coin);

		coinText = new FlxHillText();
		coinText.size = 48;
		coinText.y = coin.y + 10;
		coinText.x = coin.x + coin.width / 2 + 20;
		add(coinText);

		camFollow = new FlxPoint();
		camFollowPos = new FlxObject(0, 0, 1, 1);

		snapCamFollowToPos(camPos.x, camPos.y);
		if (prevCamFollow != null)
		{
			camFollow = prevCamFollow;
			prevCamFollow = null;
		}
		if (prevCamFollowPos != null)
		{
			camFollowPos = prevCamFollowPos;
			prevCamFollowPos = null;
		}
		add(camFollowPos);

		FlxG.camera.follow(camFollowPos, LOCKON, 1);
		// FlxG.camera.setScrollBounds(0, FlxG.width, 0, FlxG.height);
		FlxG.camera.focusOn(camFollow);

		FlxG.worldBounds.set(0, 0, FlxG.width, FlxG.height);

		FlxG.fixedTimestep = false;
		moveCameraSection();

		strumLineNotes.cameras = [camHUD];
		notes.cameras = [camHUD];
		battery.cameras = [camHUD];
		border.cameras = [camHUD];
		batteryBar.cameras = [camHUD];
		healthBar.cameras = [camHUD];
		borderh.cameras = [camHUD];
		heart.cameras = [camHUD];
		coin.cameras = [camHUD];
		coinText.cameras = [camHUD];

		// if (SONG.song == 'South')
		// FlxG.camera.alpha = 0.7;
		// UI_camera.zoom = 1;

		// cameras = [FlxG.cameras.list[1]];
		startingSong = true;
		

		noteTypeMap.clear();
		noteTypeMap = null;
		eventPushedMap.clear();
		eventPushedMap = null;

		startCountdown();

		var pauseButton:PauseButton = new PauseButton();
		pauseButton.scale.scale(1.25);
		pauseButton.cameras = [camOther];
		pauseButton.thiscamera = camOther;
		pauseButton.y = 20;
		pauseButton.x = FlxG.width - pauseButton.width - 20;
		pauseButton.pause = openPauseMenu;
		pauseButton.scrollFactor.set();
		add(pauseButton);

		batteryLow = new FlxSprite();
		batteryLow.loadGraphic(Paths.image("fuel-warning"));
		batteryLow.cameras = [camHUD];
		batteryLow.screenCenter();
		batteryLow.y += batteryLow.height / 2;
		batteryLow.alpha = 0;
		add(batteryLow);

		lowSound = new FlxSound().loadEmbedded(Paths.sound("beep"), true);
	
		#if desktop
		// Updating Discord Rich Presence.
		DiscordClient.changePresence(detailsText, curStage.toUpperCase());
		#end

		FlxG.stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyPress);
		FlxG.stage.addEventListener(KeyboardEvent.KEY_UP, onKeyRelease);

		super.create();
		CustomFadeTransition.nextCamera = camOther;

		Paths.clearUnusedMemory();
	}

	var batteryLow:FlxSprite;
	var batteryBar:FlxBar;
	var healthBar:FlxBar;
	var coinText:FlxHillText;

	/*function set_SONG.speed(value:Float):Float
	{
		if(generatedMusic)
		{
			var ratio:Float = value / SONG.speed; //funny word huh
			for (note in notes) note.resizeByRatio(ratio);
			for (note in unspawnNotes) note.resizeByRatio(ratio);
		}
		SONG.speed = value;
		noteKillOffset = 350 / SONG.speed;
		return value;
	}*/

	var startTimer:FlxTimer;
	var finishTimer:FlxTimer = null;

	// For being able to mess with the sprites on Lua
	public var countdownReady:FlxSprite;
	public var countdownSet:FlxSprite;
	public var countdownGo:FlxSprite;
	public static var startOnTime:Float = 0;

	public function startCountdown():Void
	{
		startedCountdown = true;
		Conductor.songPosition = -Conductor.crochet * 5;
		generateStaticArrows(1);
	}

	var previousFrameTime:Int = 0;
	var lastReportedPlayheadPosition:Int = 0;
	var songTime:Float = 0;

	var elapsedVal:Float;

	function startSong():Void
	{
		startingSong = false;

		previousFrameTime = FlxG.game.ticks;
		lastReportedPlayheadPosition = 0;

		FlxG.sound.playMusic(Paths.inst(PlayState.SONG.song), 1, false);
		FlxG.sound.music.onComplete = finishSong.bind();
		vocals.play();

		battery = 1;
		cancelBatteryTween();
		startOnTime = 0;

		if(paused) {
			//trace('Oopsie doopsie! Paused sound');
			FlxG.sound.music.pause();
			vocals.pause();
		}

		#if desktop
		// Updating Discord Rich Presence (with Time Left)
		DiscordClient.changePresence(detailsText, curStage.toUpperCase(), null, true, FlxG.sound.music.length);
		#end
	}

	var debugNum:Int = 0;
	private var noteTypeMap:Map<String, Bool> = new Map<String, Bool>();
	private var eventPushedMap:Map<String, Bool> = new Map<String, Bool>();
	var randomizedData:Int = -1;
	private function generateSong(dataPath:String):Void
	{
		var songData = SONG;
		Conductor.changeBPM(songData.bpm);

		if (SONG.needsVoices)
			vocals = new FlxSound().loadEmbedded(Paths.voices(PlayState.SONG.song));
		else
			vocals = new FlxSound();

		FlxG.sound.list.add(vocals);
		FlxG.sound.list.add(new FlxSound().loadEmbedded(Paths.inst(PlayState.SONG.song)));

		notes = new FlxTypedGroup<Note>();
		add(notes);

		var noteData:Array<SwagSection>;

		// NEW SHIT
		noteData = songData.notes;

		var playerCounter:Int = 0;

		var daBeats:Int = 0; // Not exactly representative of 'daBeats' lol, just how much it has looped

		var songName:String = Paths.formatToSongPath(SONG.song);

		for (section in noteData)
		{
			for (songNotes in section.sectionNotes)
			{
				var daStrumTime:Float = songNotes[0];
				var daNoteData:Int = Std.int(songNotes[1] % 4);

				var gottaHitNote:Bool = section.mustHitSection;

				if (songNotes[1] > 3)
				{
					gottaHitNote = !section.mustHitSection;
				}

				var oldNote:Note;
				if (unspawnNotes.length > 0)
					oldNote = unspawnNotes[Std.int(unspawnNotes.length - 1)];
				else
					oldNote = null;

				var coinVal:Int = 5;
				var extra:Float = Std.int(FlxG.save.data.coinUpLevel - 1);
				if (FlxG.random.bool(5 + extra))
					coinVal = 500;
				else if (FlxG.random.bool(10 + extra))
					coinVal = 100;
				else if (FlxG.random.bool(40 + extra))
					coinVal = 25;

				if (FlxG.save.data.random)
				{
					daNoteData = FlxG.random.int(0, 3, [randomizedData]);
					randomizedData = daNoteData % 4;
				}

				var swagNote:Note = new Note(daStrumTime, daNoteData, coinVal, oldNote);
				swagNote.sustainLength = songNotes[2];
				swagNote.gfNote = (section.gfSection && (songNotes[1]<4));
				swagNote.noteType = songNotes[3];
				//if(!Std.isOfType(songNotes[3], String)) swagNote.noteType = editors.ChartingState.noteTypeList[songNotes[3]]; //Backward compatibility + compatibility with Week 7 charts
				swagNote.scrollFactor.set();

				var susLength:Float = swagNote.sustainLength;

				susLength = susLength / Conductor.stepCrochet;
				unspawnNotes.push(swagNote);

				var floorSus:Int = Math.round(susLength);
				if(floorSus > 0) {
					for (susNote in 0...floorSus+1)
					{
						oldNote = unspawnNotes[Std.int(unspawnNotes.length - 1)];

						var sustainNote:Note = new Note(daStrumTime + (Conductor.stepCrochet * susNote) + (Conductor.stepCrochet / FlxMath.roundDecimal(SONG.speed, 2)), daNoteData, 5, oldNote, true);
						sustainNote.gfNote = (section.gfSection && (songNotes[1]<4));
						sustainNote.noteType = swagNote.noteType;
						sustainNote.scrollFactor.set();
						swagNote.tail.push(sustainNote);
						sustainNote.parent = swagNote;
						unspawnNotes.push(sustainNote);
					}
				}

				//swagNote.x += FlxG.width / 2; // general offset

				if(!noteTypeMap.exists(swagNote.noteType)) {
					noteTypeMap.set(swagNote.noteType, true);
				}
			}
			daBeats += 1;
		}

		// trace(unspawnNotes.length);
		// playerCounter += 1;

		unspawnNotes.sort(sortByShit);
		generatedMusic = true;
	}

	function sortByShit(Obj1:Note, Obj2:Note):Int
	{
		return FlxSort.byValues(FlxSort.ASCENDING, Obj1.strumTime, Obj2.strumTime);
	}

	public var skipArrowStartTween:Bool = false; //for lua
	private function generateStaticArrows(player:Int):Void
	{
		for (i in 0...4)
		{
			// FlxG.log.add(i);
			var targetAlpha:Float = 1;
			var babyArrow:StrumNote = new StrumNote(STRUM_X_MIDDLESCROLL, strumLine.y, i, player);
			babyArrow.downScroll = FlxG.save.data.downscroll;
			if (!skipArrowStartTween)
			{
				//babyArrow.y -= 10;
				babyArrow.alpha = 0;
				FlxTween.tween(babyArrow, {/*y: babyArrow.y + 10,*/ alpha: targetAlpha}, 1, {ease: FlxEase.circOut, startDelay: 0.5 + (0.2 * i)});
			}
			else
			{
				babyArrow.alpha = targetAlpha;
			}

			if (player == 1)
			{
				playerStrums.add(babyArrow);
			}

			strumLineNotes.add(babyArrow);
			babyArrow.postAddedToGroup();
		}
	}

	override function openSubState(SubState:FlxSubState)
	{
		if (paused)
		{
			if (FlxG.sound.music != null)
			{
				FlxG.sound.music.pause();
				vocals.pause();
			}

			lowSound.pause();

			if (startTimer != null && !startTimer.finished)
				startTimer.active = false;
			if (finishTimer != null && !finishTimer.finished)
				finishTimer.active = false;

			var chars:Array<Character> = [boyfriend];
			for (char in chars) {
				if(char != null && char.colorTween != null) {
					char.colorTween.active = false;
				}
			}
		}

		super.openSubState(SubState);
	}

	override function closeSubState()
	{
		if (paused)
		{
			if (FlxG.sound.music != null && !startingSong)
			{
				resyncVocals();
			}

			if (startTimer != null && !startTimer.finished)
				startTimer.active = true;
			if (finishTimer != null && !finishTimer.finished)
				finishTimer.active = true;

			var chars:Array<Character> = [boyfriend];
			for (char in chars) {
				if(char != null && char.colorTween != null) {
					char.colorTween.active = true;
				}
			}

			paused = false;

			#if desktop
			if (startTimer != null && startTimer.finished)
			{
				DiscordClient.changePresence(detailsText, curStage.toUpperCase(), null, true, FlxG.sound.music.length - Conductor.songPosition);
			}
			else
			{
				DiscordClient.changePresence(detailsText, curStage.toUpperCase(), null);
			}
			#end
		}

		super.closeSubState();
	}

	override public function onFocus():Void
	{
		#if desktop
		if (health > 0 && !paused)
		{
			if (Conductor.songPosition > 0.0)
			{
				DiscordClient.changePresence(detailsText, curStage.toUpperCase(), null, true, FlxG.sound.music.length - Conductor.songPosition);
			}
			else
			{
				DiscordClient.changePresence(detailsText, curStage.toUpperCase());
			}
		}
		#end

		super.onFocus();
	}

	override public function onFocusLost():Void
	{
		#if desktop
		if (health > 0 && !paused)
		{
			DiscordClient.changePresence(detailsPausedText, curStage.toUpperCase());
		}
		#end

		super.onFocusLost();
	}

	function resyncVocals():Void
	{
		if(finishTimer != null) return;

		vocals.pause();

		FlxG.sound.music.play();
		Conductor.songPosition = FlxG.sound.music.time;
		if (Conductor.songPosition <= vocals.length)
		{
			vocals.time = Conductor.songPosition;
		}
		vocals.play();
	}

	public var paused:Bool = false;
	public var canReset:Bool = true;
	var startedCountdown:Bool = false;
	var canPause:Bool = true;
	var limoSpeed:Float = 0;

	var isLow:Bool = false;
	var lowSound:FlxSound;
	var lowSine:Float;

	override public function update(elapsed:Float)
	{
		var lerpVal:Float = 1;
		camFollowPos.setPosition(FlxMath.lerp(camFollowPos.x, camFollow.x, lerpVal), FlxMath.lerp(camFollowPos.y, camFollow.y, lerpVal));

		coinText.text = "" + FlxG.save.data.coin;
		coinText.x = 67.5;

		ratingPercent = Std.int(Math.abs(totalNotesHit / totalPlayed * 100));
		if (ratingPercent > 100)
			ratingPercent = 100;
		if (ratingPercent < 0)
			ratingPercent = 0;

		if (curStage.toLowerCase() == "moon")
		{
			boyfriend.y += Math.sin(elapsedVal) / 5;
			camHUD.y += Math.sin(elapsedVal) / 10;

			elapsedVal += elapsed * 2;
		}

		super.update(elapsed);

		if (FlxG.keys.justPressed.ENTER && startedCountdown && canPause)
		{
			openPauseMenu();
		}

		if (battery <= 0)
		{
			camHUD.zoom += elapsed * 8;
			camHUD.alpha -= elapsed * 2;
			if (camHUD.zoom > 8)
			{
				openDeadMenu(OUT_OF_BATTERY);
			}
		}
		else if (health <= 0)
		{
			camHUD.zoom += elapsed * 8;
			camHUD.alpha -= elapsed * 2;
			if (camHUD.zoom > 8)
			{
				openDeadMenu(DIED);
			}
		}

		if (health > 2)
			health = 2;

		isLow = battery < 0.25 && battery > 0;
		if (isLow)
		{
			if (!lowSound.playing && !paused)
				lowSound.play();

			lowSine += 360 * elapsed;
			batteryLow.alpha = 1 - Math.sin((Math.PI * lowSine) / 360);
		}
		else
		{
			batteryLow.alpha = 0;
			if (lowSound.playing && !paused)
				lowSound.stop();
		}

		// FlxG.watch.addQuick('VOL', vocals.amplitudeLeft);
		// FlxG.watch.addQuick('VOLRight', vocals.amplitudeRight);

		if (startedCountdown)
		{
			Conductor.songPosition += FlxG.elapsed * 1000;
		}

		if (startingSong)
		{
			if (startedCountdown && Conductor.songPosition >= 0)
				startSong();
			else if(!startedCountdown)
				Conductor.songPosition = -Conductor.crochet * 5;
		}
		else
		{
			if (!paused)
			{
				songTime += FlxG.game.ticks - previousFrameTime;
				previousFrameTime = FlxG.game.ticks;

				// Interpolation type beat
				if (Conductor.lastSongPos != Conductor.songPosition)
				{
					songTime = (songTime + Conductor.songPosition) / 2;
					Conductor.lastSongPos = Conductor.songPosition;
					// Conductor.songPosition += FlxG.elapsed * 1000;
					// trace('MISSED FRAME');
				}
			}

			// Conductor.lastSongPos = FlxG.sound.music.time;
		}

		if (false)
		{
			
		}

		FlxG.watch.addQuick("secShit", curSection);
		FlxG.watch.addQuick("beatShit", curBeat);
		FlxG.watch.addQuick("stepShit", curStep);

		if (unspawnNotes[0] != null)
		{
			var time:Float = spawnTime;
			if(SONG.speed < 1) time /= SONG.speed;
			if(unspawnNotes[0].multSpeed < 1) time /= unspawnNotes[0].multSpeed;

			while (unspawnNotes.length > 0 && unspawnNotes[0].strumTime - Conductor.songPosition < time)
			{
				var dunceNote:Note = unspawnNotes[0];
				notes.insert(0, dunceNote);
				dunceNote.spawned=true;
				
				var index:Int = unspawnNotes.indexOf(dunceNote);
				unspawnNotes.splice(index, 1);
			}
		}

		if (generatedMusic)
		{
			keyShit();
			if(startedCountdown)
			{
				var fakeCrochet:Float = (60 / SONG.bpm) * 1000;
				notes.forEachAlive(function(daNote:Note)
				{
					var strumGroup:FlxTypedGroup<StrumNote> = playerStrums;

					var strumX:Float = strumGroup.members[daNote.noteData].x;
					var strumY:Float = strumGroup.members[daNote.noteData].y;
					var strumAngle:Float = strumGroup.members[daNote.noteData].angle;
					var strumDirection:Float = strumGroup.members[daNote.noteData].direction;
					var strumAlpha:Float = strumGroup.members[daNote.noteData].alpha;
					var strumScroll:Bool = strumGroup.members[daNote.noteData].downScroll;

					var swagWidth = Note.swagWidth;
					if (daNote.isSustainNote)
						swagWidth *= 0.7;

					strumX += daNote.offsetX;
					strumY += daNote.offsetY;
					strumAngle += daNote.offsetAngle;
					strumAlpha *= daNote.multAlpha;

					if (strumScroll) //Downscroll
					{
						//daNote.y = (strumY + 0.45 * (Conductor.songPosition - daNote.strumTime) * SONG.speed);
						daNote.distance = (0.45 * (Conductor.songPosition - daNote.strumTime) * SONG.speed * daNote.multSpeed);
					}
					else //Upscroll
					{
						//daNote.y = (strumY - 0.45 * (Conductor.songPosition - daNote.strumTime) * SONG.speed);
						daNote.distance = (-0.45 * (Conductor.songPosition - daNote.strumTime) * SONG.speed * daNote.multSpeed);
					}

					var angleDir = strumDirection * Math.PI / 180;
					if (daNote.copyAngle)
						daNote.angle = strumDirection - 90 + strumAngle;

					if(daNote.copyAlpha)
						daNote.alpha = strumAlpha;

					if(daNote.copyX)
						daNote.x = strumX;

					if(daNote.copyY)
					{
						daNote.y = strumY + Math.sin(angleDir) * daNote.distance;

						//Jesus fuck this took me so much mother fucking time AAAAAAAAAA
						if(strumScroll && daNote.isSustainNote)
						{
							if (daNote.animation.curAnim.name.endsWith('end')) {
								daNote.y += 10.5 * (fakeCrochet / 400) * 1.5 * SONG.speed + (46 * (SONG.speed - 1));
								daNote.y -= 46 * (1 - (fakeCrochet / 600)) * SONG.speed;
								daNote.y -= 19;
							}
							daNote.y += (swagWidth / 2) - (60.5 * (SONG.speed - 1));
							daNote.y += 27.5 * ((SONG.bpm / 100) - 1) * (SONG.speed - 1);
						}
					}

					var center:Float = strumY + swagWidth / 2;
					
					if(strumGroup.members[daNote.noteData].sustainReduce && daNote.isSustainNote && (!daNote.ignoreNote) &&
						((daNote.wasGoodHit || (daNote.prevNote.wasGoodHit && !daNote.canBeHit))))
					{
						if (strumScroll)
						{
							if(daNote.y - daNote.offset.y * daNote.scale.y + daNote.height >= center)
							{
								var swagRect = new FlxRect(0, 0, daNote.frameWidth, daNote.frameHeight);
								swagRect.height = (center - daNote.y) / daNote.scale.y;
								swagRect.y = daNote.frameHeight - swagRect.height;

								daNote.clipRect = swagRect;
							}
						}
						else
						{
							if (daNote.y + daNote.offset.y * daNote.scale.y <= center)
							{
								var swagRect = new FlxRect(0, 0, daNote.width / daNote.scale.x, daNote.height / daNote.scale.y);
								swagRect.y = (center - daNote.y) / daNote.scale.y;
								swagRect.height -= swagRect.y;

								daNote.clipRect = swagRect;
							}
						}
					}

					// Kill extremely late notes and cause misses
					if (Conductor.songPosition > noteKillOffset + daNote.strumTime)
					{
						if (!daNote.ignoreNote && !endingSong && (daNote.tooLate || !daNote.wasGoodHit)) {
							noteMiss(daNote);
						}

						daNote.active = false;
						daNote.visible = false;

						daNote.kill();
						notes.remove(daNote, true);
						daNote.destroy();
					}
				});
				
				if (battery <= 0)
				{
					notes.forEachAlive(function(note:Note)
					{
						note.copyAlpha = true;
						for (i in playerStrums)
							i.alpha = 0.4;
						note.canBeHit = false;
						note.earlyHitMult = 0;
						note.blockHit = true;
					});
				}
			}
			else
			{
				notes.forEachAlive(function(daNote:Note)
				{
					daNote.canBeHit = false;
					daNote.wasGoodHit = false;
				});
			}
		}
	}

	function openPauseMenu()
	{
		persistentUpdate = false;
		persistentDraw = true;
		paused = true;

		// 1 / 1000 chance for Gitaroo Man easter egg
		/*if (FlxG.random.bool(0.1))
		{
			// gitaroo man easter egg
			cancelMusicFadeTween();
			MusicBeatState.switchState(new GitarooPause());
		}
		else {*/
		if(FlxG.sound.music != null) {
			FlxG.sound.music.pause();
			vocals.pause();
		}
		openSubState(new PauseSubState(camOther));
		//}

		#if desktop
		DiscordClient.changePresence(detailsPausedText, curStage.toUpperCase());
		#end
	}

	function openDeadMenu(down:DownType)
	{
		persistentUpdate = false;
		persistentDraw = true;
		paused = true;

		if (vocals != null) 
		{
			vocals.pause();
		}
		if (FlxG.sound.music != null)
		{
			FlxG.sound.music.pause();
		}

		var onClick = () -> {
			trace('WENT BACK TO FREEPLAY??');
			cancelMusicFadeTween();
			CustomFadeTransition.nextCamera = camOther;
			MusicBeatState.switchState(new UpgradeMenuState());
			if (SoundButton.musicEnabled)
				FlxG.sound.playMusic(Paths.music('bgmusic00'));
			transitioning = true;
		}
		openSubState(new DownSubstate(down, down == SUCCESS ? FlxG.sound.music.length : FlxG.sound.music.time, Std.int(FlxG.save.data.coin - initialCoin), notesHit, FlxMath.roundDecimal(songScore / 1000, 1), songMisses, ratingPercent, onClick, endingSong));
	}

	public function getControl(key:String) {
		var pressed:Bool = Reflect.getProperty(controls, key);
		//trace('Control result: ' + pressed);
		return pressed;
	}

	function moveCameraSection():Void {
		if(SONG.notes[curSection] == null) return;

		if (!SONG.notes[curSection].mustHitSection)
		{
			//moveCamera(true);
		}
	}

	var cameraTwn:FlxTween;
	public function moveCamera(isDad:Bool)
	{
		camFollow.set(boyfriend.getMidpoint().x - 100, boyfriend.getMidpoint().y - 100);
	}

	function tweenCamIn() {
		if (Paths.formatToSongPath(SONG.song) == 'tutorial' && cameraTwn == null && FlxG.camera.zoom != 1.3) {
			cameraTwn = FlxTween.tween(FlxG.camera, {zoom: 1.3}, (Conductor.stepCrochet * 4 / 1000), {ease: FlxEase.elasticInOut, onComplete:
				function (twn:FlxTween) {
					cameraTwn = null;
				}
			});
		}
	}

	function snapCamFollowToPos(x:Float, y:Float) {
		camFollow.set(x, y);
		camFollowPos.setPosition(x, y);
	}

	public function finishSong(?ignoreNoteOffset:Bool = false):Void
	{
		var finishCallback:Void->Void = endSong; //In case you want to change it in a specific song.

		FlxG.sound.music.volume = 0;
		vocals.volume = 0;
		vocals.pause();
		finishCallback();
	}


	public var transitioning = false;
	public function endSong():Void
	{
		canPause = false;
		endingSong = true;

		if(!transitioning) {
			openDeadMenu(SUCCESS);
		}
	}

	public function KillNotes() {
		while(notes.length > 0) {
			var daNote:Note = notes.members[0];
			daNote.active = false;
			daNote.visible = false;

			daNote.kill();
			notes.remove(daNote, true);
			daNote.destroy();
		}
		unspawnNotes = [];
	}

	public var totalPlayed:Int = 0;
	public var totalNotesHit:Float = 0.0;
	public var notesHit:Int = 0;
	public var ratingPercent:Int = 0;

	public var showCombo:Bool = false;
	public var showComboNum:Bool = true;
	public var showRating:Bool = true;

	public var strumsBlocked:Array<Bool> = [];
	private function onKeyPress(event:KeyboardEvent):Void
	{
		var eventKey:FlxKey = event.keyCode;
		var key:Int = getKeyFromEvent(eventKey);
		//trace('Pressed: ' + eventKey);

		if (startedCountdown && !paused && key > -1 && (FlxG.keys.checkStatus(eventKey, JUST_PRESSED)))
		{
			if(!boyfriend.stunned && generatedMusic && !endingSong)
			{
				//more accurate hit time for the ratings?
				var lastTime:Float = Conductor.songPosition;
				Conductor.songPosition = FlxG.sound.music.time;

				// heavily based on my own code LOL if it aint broke dont fix it
				var pressNotes:Array<Note> = [];
				//var notesDatas:Array<Int> = [];
				var notesStopped:Bool = false;

				var sortedNotesList:Array<Note> = [];
				notes.forEachAlive(function(daNote:Note)
				{
					if (strumsBlocked[daNote.noteData] != true && daNote.canBeHit && !daNote.tooLate && !daNote.wasGoodHit && !daNote.isSustainNote && !daNote.blockHit)
					{
						if(daNote.noteData == key)
						{
							sortedNotesList.push(daNote);
							//notesDatas.push(daNote.noteData);
						}
					}
				});
				sortedNotesList.sort(sortHitNotes);

				if (sortedNotesList.length > 0) {
					for (epicNote in sortedNotesList)
					{
						for (doubleNote in pressNotes) {
							if (Math.abs(doubleNote.strumTime - epicNote.strumTime) < 1) {
								doubleNote.kill();
								notes.remove(doubleNote, true);
								doubleNote.destroy();
							} else
								notesStopped = true;
						}

						// eee jack detection before was not super good
						if (!notesStopped) {
							var chance:Float = FlxG.save.data.inputLevel - 1;
							chance = chance / 2.5;

							if (!FlxG.random.bool(4 - chance) || epicNote.noteType == "Battery")
							{
								goodNoteHit(epicNote);
								pressNotes.push(epicNote);
							}
							else
							{
								epicNote.alpha = 0.4;
							}
						}

					}
				}

				//more accurate hit time for the ratings? part 2 (Now that the calculations are done, go back to the time it was before for not causing a note stutter)
				Conductor.songPosition = lastTime;
			}

			var spr:StrumNote = playerStrums.members[key];
			if(strumsBlocked[key] != true && spr != null && spr.animation.curAnim.name != 'confirm')
			{
				spr.playAnim('pressed');
				spr.resetAnim = 0;
			}
		}
		//trace('pressed: ' + controlArray);
	}

	function sortHitNotes(a:Note, b:Note):Int
	{
		if (a.lowPriority && !b.lowPriority)
			return 1;
		else if (!a.lowPriority && b.lowPriority)
			return -1;

		return FlxSort.byValues(FlxSort.ASCENDING, a.strumTime, b.strumTime);
	}

	private function onKeyRelease(event:KeyboardEvent):Void
	{
		var eventKey:FlxKey = event.keyCode;
		var key:Int = getKeyFromEvent(eventKey);
		if(startedCountdown && !paused && key > -1)
		{
			var spr:StrumNote = playerStrums.members[key];
			if(spr != null)
			{
				spr.playAnim('static');
				spr.resetAnim = 0;
			}
		}
		//trace('released: ' + controlArray);
	}

	private function getKeyFromEvent(key:FlxKey):Int
	{
		if(key != NONE)
		{
			for (i in 0...keysArray.length)
			{
				for (j in 0...keysArray[i].length)
				{
					if(key == keysArray[i][j])
					{
						return i;
					}
				}
			}
		}
		return -1;
	}

	// Hold notes
	private function keyShit():Void
	{
		// HOLDING
		var parsedHoldArray:Array<Bool> = parseKeys();

		// FlxG.watch.addQuick('asdfa', upP);
		if (startedCountdown && !boyfriend.stunned && generatedMusic)
		{
			// rewritten inputs???
			notes.forEachAlive(function(daNote:Note)
			{
				// hold note functions
				if (daNote.isSustainNote && parsedHoldArray[daNote.noteData] && daNote.canBeHit && !daNote.tooLate && !daNote.wasGoodHit && !daNote.blockHit) {
					goodNoteHit(daNote);
				}
			});

			if (boyfriend.animation.curAnim != null && boyfriend.holdTimer > Conductor.stepCrochet * 0.0011 * boyfriend.singDuration && boyfriend.animation.curAnim.name.startsWith('sing') && !boyfriend.animation.curAnim.name.endsWith('miss'))
			{
				boyfriend.dance();
				//boyfriend.animation.curAnim.finish();
			}
		}
	}

	private function parseKeys(?suffix:String = ''):Array<Bool>
	{
		var ret:Array<Bool> = [];
		for (i in 0...controlArray.length)
		{
			ret[i] = Reflect.getProperty(controls, controlArray[i] + suffix);
		}
		return ret;
	}

	function noteMiss(daNote:Note):Void 
	{
		if (battery <= 0)
			return;

		//Dupe note remove
		notes.forEachAlive(function(note:Note) {
			if (daNote != note && daNote.noteData == note.noteData && daNote.isSustainNote == note.isSustainNote && Math.abs(daNote.strumTime - note.strumTime) < 1) {
				note.kill();
				notes.remove(note, true);
				note.destroy();
			}
		});
		combo = 0;
		health -= 0.04;

		//For testing purposes
		//trace(daNote.missHealth);
		songMisses++;
		vocals.volume = 0;

		totalPlayed++;

		var char:Character = boyfriend;
		if(char != null && !daNote.noMissAnimation && char.hasMissAnimations)
		{
			var animToPlay:String = singAnimations[Std.int(Math.abs(daNote.noteData))] + 'miss' + daNote.animSuffix;
			char.playAnim(animToPlay, true);
		}
	}

	function goodNoteHit(note:Note):Void
	{
		if (!note.wasGoodHit)
		{
			if((note.hitCausesMiss)) return;

			if (!note.isSustainNote)
			{
				if (SoundButton.soundEnabled)
					FlxG.sound.play(Paths.sound("coin"));

				FlxG.save.data.coin += note.coinVal;
			}

			if(note.hitCausesMiss) {
				noteMiss(note);

				if(!note.noMissAnimation)
				{
					switch(note.noteType) {
						case 'Hurt Note': //Hurt note
							if(boyfriend.animation.getByName('hurt') != null) {
								boyfriend.playAnim('hurt', true);
								boyfriend.specialAnim = true;
							}
					}
				}

				note.wasGoodHit = true;
				if (!note.isSustainNote)
				{
					note.kill();
					notes.remove(note, true);
					note.destroy();
				}
				return;
			}

			health += 0.02;

			if(!note.noAnimation) {
				var animToPlay:String = singAnimations[Std.int(Math.abs(note.noteData))];
				boyfriend.playAnim(animToPlay + note.animSuffix, true);
				boyfriend.holdTimer = 0;

				if(note.noteType == 'Hey!') {
					if(boyfriend.animOffsets.exists('hey')) {
						boyfriend.playAnim('hey', true);
						boyfriend.specialAnim = true;
						boyfriend.heyTimer = 0.6;
					}
				}
			}

			if (note.noteType == "Battery")
			{
				battery = 1;
				cancelBatteryTween();
				if (SoundButton.soundEnabled)
					FlxG.sound.play(Paths.sound("refuel"));
			}
			else
			{
				notesHit++;
				if (!note.isSustainNote)
				{
					totalPlayed++;

					var diff = Math.abs(note.strumTime - Conductor.songPosition);
					if (diff <= 45)
					{
						totalNotesHit++;
						songScore += 350;
					}
					else if (diff <= 90)
					{
						totalNotesHit += 0.75;
						songScore += 200;
					}
					else if (diff <= 135)
					{
						totalNotesHit += 0.5;
						songScore += 100;
					}
					else
					{
						totalNotesHit += 0.25;
						songScore += 50;
					}
				}
			}

			var spr = playerStrums.members[note.noteData];
			if(spr != null)
			{
				spr.playAnim('confirm', true);
			}
			
			note.wasGoodHit = true;
			vocals.volume = 1;

			var isSus:Bool = note.isSustainNote; //GET OUT OF MY HEAD, GET OUT OF MY HEAD, GET OUT OF MY HEAD
			var leData:Int = Math.round(Math.abs(note.noteData));
			var leType:String = note.noteType;

			if (!note.isSustainNote)
			{
				note.kill();
				notes.remove(note, true);
				note.destroy();

				coinBop();
			}
		}
	}

	override function destroy() {
		FlxG.stage.removeEventListener(KeyboardEvent.KEY_DOWN, onKeyPress);
		FlxG.stage.removeEventListener(KeyboardEvent.KEY_UP, onKeyRelease);
		
		FlxG.sound.music.pitch = 1;

		//FlxG.save.data.coin += songScore; 
		FlxG.save.flush();
		
		super.destroy();
	}

	public static function cancelMusicFadeTween() {
		if(FlxG.sound.music.fadeTween != null) {
			FlxG.sound.music.fadeTween.cancel();
		}
		FlxG.sound.music.fadeTween = null;
	}

	var lastStepHit:Int = -1;
	override function stepHit()
	{
		super.stepHit();
		if (Math.abs(FlxG.sound.music.time - (Conductor.songPosition - Conductor.offset)) > (20)
			|| (SONG.needsVoices && Math.abs(vocals.time - (Conductor.songPosition - Conductor.offset)) > (20)))
		{
			resyncVocals();
		}

		if(curStep == lastStepHit) {
			return;
		}

		lastStepHit = curStep;
	}

	var lightningStrikeBeat:Int = 0;
	var lightningOffset:Int = 8;

	var lastBeatHit:Int = -1;

	override function beatHit()
	{
		super.beatHit();

		if(lastBeatHit >= curBeat) {
			//trace('BEAT HIT: ' + curBeat + ', LAST HIT: ' + lastBeatHit);
			return;
		}

		if (generatedMusic)
		{
			notes.sort(FlxSort.byY, FlxG.save.data.downScroll ? FlxSort.ASCENDING : FlxSort.DESCENDING);
		}

		if (curBeat % boyfriend.danceEveryNumBeats == 0 && boyfriend.animation.curAnim != null && !boyfriend.animation.curAnim.name.startsWith('sing') && !boyfriend.stunned)
		{
			boyfriend.dance();
		}

		lastBeatHit = curBeat;
	}

	override function sectionHit()
	{
		super.sectionHit();

		if (SONG.notes[curSection] != null)
		{
			if (generatedMusic && !endingSong)
			{
				moveCameraSection();
			}

			if (SONG.notes[curSection].changeBPM)
			{
				Conductor.changeBPM(SONG.notes[curSection].bpm);
			}
		}
	}

	function StrumPlayAnim(isDad:Bool, id:Int, time:Float) {
		var spr:StrumNote = null;
		if(isDad) {
			spr = strumLineNotes.members[id];
		} else {
			spr = playerStrums.members[id];
		}

		if(spr != null) {
			spr.playAnim('confirm', true);
			spr.resetAnim = time;
		}
	}

	public function coinBop():Void {
		if(coinTween != null)
			coinTween.cancel();

		coinText.scale.x = coinText.size / 64 * 1.075;
		coinText.scale.y = coinText.size / 64 * 1.075;
		coinTween = FlxTween.tween(coinText.scale, {x: coinText.size / 64, y: coinText.size / 64}, 0.2, {
			onComplete: function(twn:FlxTween) {
				coinTween = null;
			}
		});
	}

	function cancelBatteryTween()
	{
		if (batteryTween != null)
			batteryTween.cancel();

		var duration = 17.5 + ((FlxG.save.data.batteryLevel - 1) * 7.5);
		batteryTween = FlxTween.tween(this, {battery: .0}, duration);
	}
}
