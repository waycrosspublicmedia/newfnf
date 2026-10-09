lightColor = getColorFromHex('3dcbff')
tintColor = getColorFromHex('a0b8c1')

local xx, yy = 1380, 650; -- headhunter
local xx2, yy2 = 750, 630; -- lucy
local ofs, ofs2 = 15, 35;

local stage, hud, sounds, dialogueSFX = 'stages/week3/etrain/', 'stages/hudelements/', 'WEEK2/', 'WEEK2/DIALOGUE SFX/'

local allowCountdown, doDialogue, doShakeTrain, followchars = false, true, false, false; 
local doZoom, doIntro, inGameOver = false, false, false
local panDoor = false

------------------------------------------------------------------- minigame shit
local maxBullets, reloadIndex, reloading = 6, 0 , false
local bulletSpacing, bulletStartX, bulletY = 20, 0, 0
local ammo = maxBullets

local recoil, recoilMax, recoilDamp, baseCamOtherX, baseCamOtherY = 0, 1, 6, 0, 0
local cursorScale = 0.7

local timerBarWidth, timerBarHeight, timerLerp = 400, 12, 0
local score, timer, timerMax, isTimerActive = 0, 0, 8, false

local moleX, mole, moleCount = 0, 0, 3
local moleTags = {}

local isMoleVisible, lastHitMole = false, nil

--outcomes after minigames
local isHypno, gameRunning, wonGame, gameWin, lostGame, killLucy = false, false, false, false, false, false

--intro variables
zoomNum, zoomSpeed = 1.1, 1
debug = 0
--
local reveals = {}
local shakeDuration, shakeTime, shakeStrength, doShake = 0, 0, 0, false
local blurAlpha, blurActive = 1, false

local forceCam = false

-- QTE
local startEnding = false
qteActive = false
qteDone = false
qteTimer = 0
qtePunching = false
qteFinalBlow = false

-- tooltips
local tooltipPadding = 8
local tooltipWidth = 420
local tooltipY = 55
local tooltipX = 35

function onNextDialogue(lineNum)
	if lineNum == 5 then
		cameraShake('camFilm', 0.003, 0.4)
		playSound(dialogueSFX.. 'destin-door', 1) -- bust thru
		runHaxeCode([[
            FlxG.sound.music.fadeOut(1, 0.1, 0.1);
        ]])
	end
    if lineNum == 10 then
		runHaxeCode([[
            FlxG.sound.music.fadeIn(1, 0.1, 1);
        ]])
		playSound(dialogueSFX.. 'destin-push', 1) -- push
      
    end

	if lineNum == 11 then
		cameraShake('camFilm', 0.003, 0.4)
		playSound(dialogueSFX.. 'destin-kick', 1) -- kick
	end

	if lineNum == 15 then
		triggerBlur()
		cameraShake('camFilm', 0.003, 0.4)
		playSound(dialogueSFX.. 'destin-car', 1) -- car screech
	end
end

function onStartCountdown()

	if isStoryMode then
		
		if not allowCountdown then
			if doDialogue and not seenCutscene then

				startDialogue('destinationShit', 'dialogueMusic/destinationDia')  
				
				doDialogue = false
				allowCountdown = true;
				return Function_Stop;
			
			end
		end
	end

	allowCountdown = true	
	return Function_Continue
end

function onCreatePost() 


	if not lowQuality then
		xShit = -10
		yShit = 500
		followchars = false
		doZoom = false
		forceCam = true
		setProperty('boyfriend.alpha', debug)
		setProperty('dad.alpha', 0)
		doTweenZoom('peep', 'camGame', 1.1, 1, 'circOut')
	else
		followchars = true
		doZoom = true
	end

	math.randomseed(os.time())
	
--caching
	precacheSound('MINIGAME/trainIntro')
	precacheSound(sounds..'bingBong')

	precacheImage('noteSkins/Bullet_Note')
	precacheImage(stage..'PEEPS/DAZED')
	precacheImage(stage..'SIDEDOOR')
	precacheImage(stage..'SIDEDOOR-LOW')

	if enableMinigame then
		--minigame
		precacheSound(stage..'MINIGAME/BULLET')
		precacheSound('MINIGAME/gun/reload')
		precacheSound('MINIGAME/gun/shot')

		precacheSound('MINIGAME/intro/intro1')
		precacheSound('MINIGAME/intro/intro2')

		precacheSound('MINIGAME/win/win1')
		precacheSound('MINIGAME/win/win2')
		precacheSound('MINIGAME/win/win3')

		precacheSound('MINIGAME/lose/lose1')
		precacheSound('MINIGAME/lose/lose2')
		precacheSound('MINIGAME/lose/lose3')
		precacheSound('MINIGAME/lose/lose4')

		precacheSound('MINIGAME/hurt/hurt1')
		precacheSound('MINIGAME/hurt/hurt2')
		precacheSound('MINIGAME/hurt/hurt3')
		precacheSound('MINIGAME/hurt/hurt4')
		precacheSound('MINIGAME/hurt/hurt5')
		precacheSound('MINIGAME/hurt/hurt6')
		precacheSound('MINIGAME/hurt/hurt7')
		precacheSound('MINIGAME/hurt/hurt8')
		precacheSound('MINIGAME/hurt/hurt9')
		precacheSound('MINIGAME/hurt/hurt10')

		precacheSound('MINIGAME/hit/hit1')
		precacheSound('MINIGAME/hit/hit2')
		precacheSound('MINIGAME/hit/hit3')

		precacheImage(stage..'MINIGAME/BG2')
		precacheImage(stage..'MINIGAME/BG')
		precacheImage(stage..'MINIGAME/TITLE')
		precacheImage(stage..'MINIGAME/MOLE')
		precacheImage(stage..'MINIGAME/CURSOR_TARGET')
	end
end

function onSongStart()
	openingIntroStory() 
end

function onCreate()

	
	setPropertyFromClass('substates.GameOverSubstate', 'characterName', 'death-lucy'); --Character json file for the death 
	setPropertyFromClass('substates.GameOverSubstate', 'deathSoundName', 'DEATH/lucyDeath');
	setPropertyFromClass('substates.GameOverSubstate', 'endSoundName', 'DEATH/destinConfirm');
	setPropertyFromClass('substates.GameOverSubstate', 'loopSoundName', 'DEATH/destinDeath');

	makeAnimatedLuaSprite('moving', stage..'BGMOVING', -200,180); --right most
	addAnimationByPrefix('moving', 'wee', 'movingLights', 24, true);
	addLuaSprite('moving', false);
	setScrollFactor('moving', 0, 0.85);
	scaleObject('moving', '1.3','1');
	objectPlayAnimation('moving', 'wee',true);

	makeLuaSprite('wall', stage..'TRAINBG NEW', -840, -200);
	setScrollFactor('wall', 0.85, 0.9);
	addLuaSprite('wall', false);
	scaleObject('wall', '1.1','1');

	if not lowQuality then
		makeAnimatedLuaSprite('side', stage..'SIDEDOOR', -810, -200); --right most
		addAnimationByPrefix('side', 'idle', 'DOOR IDLE', 24, false);
		addAnimationByPrefix('side', 'peep', 'INTRO', 24, false);
		addLuaSprite('side', false);
		setScrollFactor('side', 0.85, 0.9);
		objectPlayAnimation('side', 'idle',false);

		makeAnimatedLuaSprite('lucyIntro', stage..'PEEPS/LUCYINTRO', 124,290);
		scaleObject('lucyIntro', '1', '1');
		addLuaSprite('lucyIntro', true);
		setScrollFactor('lucyIntro', 0.9, 0.9);
		setProperty('lucyIntro.visible', false)
	else
		makeLuaSprite('side-low', stage..'SIDEDOOR-LOW', -810, -200);
		setScrollFactor('side-low', 0.85, 0.9);
		addLuaSprite('side-low', false);
	end

	if not lowQuality then
		makeLuaSprite('polesBg', stage..'POLES', -500, -60);
		setScrollFactor('polesBg', 0.9, 0.9);
		addLuaSprite('polesBg', false);
		scaleObject('polesBg', '1','1');
	end



	makeAnimatedLuaSprite('lucyHyp', stage..'PEEPS/DAZED', 50,300);
	addAnimationByPrefix('lucyHyp', 'intro', 'DAZED', 24, false);
	addAnimationByPrefix('lucyHyp', 'lose', 'LOSE', 24, false);
	addAnimationByPrefix('lucyHyp', 'win', 'WIN', 24, false); --right mos
	scaleObject('lucyHyp', '1', '1');
	addLuaSprite('lucyHyp', false);
	setScrollFactor('lucyHyp', 0.9, 0.9);
	setProperty('lucyHyp.visible', false)

	makeAnimatedLuaSprite('lucyFight', stage..'PEEPS/FIGHT', 110, 310) -- x450, y450 og
	addAnimationByPrefix('lucyFight', 'intro', 'TRANSITION', 24, false)
    addAnimationByPrefix('lucyFight', 'idle', 'HIT-IDLE', 24, true)
    addAnimationByPrefix('lucyFight', 'beat', 'PUNCH-1', 24, false)
	addAnimationByPrefix('lucyFight', 'beat2', 'PUNCH-2', 24, false)
	addAnimationByPrefix('lucyFight', 'ending', 'DEATH', 24, false)
	setScrollFactor('lucyFight', 0.9, 0.9);
    addLuaSprite('lucyFight', true)
    setProperty('lucyFight.visible', false)

	makeLuaSprite('overlay', '', -300, -100);
	setScrollFactor('overlay', 0, 0);
	addLuaSprite('overlay', true);
	scaleObject('overlay', '1','1');
	makeGraphic('overlay', screenWidth, screenHeight, '66FFFF')
	setProperty('overlay.alpha', 0.3)
	setBlendMode('overlay', 'MULTIPLY')
	scaleObject('overlay', '1.4','1.4');

	makeLuaSprite('tint', '', 0, 0);
	setScrollFactor('tint', 0, 0);
	addLuaSprite('tint', true);
	scaleObject('tint', '1.3','1.3');
	setProperty('tint.alpha', 0.1)
	makeGraphic('tint', screenWidth, screenHeight, 'a0b8c1')

	makeLuaSprite('fade', '', 0, 0);
	setScrollFactor('fade', 0, 0);
	addLuaSprite('fade', true);
	scaleObject('fade', '1.3','1.3');
	setProperty('fade.alpha', 1)
	makeGraphic('fade', screenWidth, screenHeight, '000000')
	--setObjectCamera('fade', 'other')

	makeLuaSprite('HHArt', stage..'INTRO/HHIntro', 0, 50);
	setScrollFactor('HHArt', 0, 0);
	scaleObject('HHArt', '1','1');
	makeLuaSprite('HHName', stage..'INTRO/HHName', 0, 250);
	setScrollFactor('HHName', 0, 0);
	scaleObject('HHName', '1','1');
	
	addLuaSprite('HHArt', true);
	addLuaSprite('HHName', true);
	setProperty('HHArt.alpha', 0)
	setProperty('HHName.alpha', 0)
	setObjectCamera('HHName', 'other')
	setObjectCamera('HHArt', 'other')


-- ========================================== MINIGAME ==========================================
	makeLuaSprite('black', '', 0, 0);
	addLuaSprite('black', false);
	scaleObject('black', '1','1');
	makeGraphic('black', screenWidth, screenHeight, '000000')
	setObjectCamera('black', 'other')
	setProperty('black.alpha', 0)

	if enableMinigame then
		makeLuaSprite('base', stage..'MINIGAME/BG', 0, 0); -- playing field
		setScrollFactor('base', 0, 0);
		addLuaSprite('base', false);
		setObjectCamera('base', 'other')
		scaleObject('base', '1','1');
		setProperty('base.x', (screenWidth/2) - (getProperty('base.width')/2));
		setProperty('base.y', (screenHeight/2) - (getProperty('base.height')/2));
		setProperty('base.alpha', 0)

		makeLuaSprite('bg', stage..'MINIGAME/BG2', 0, 0); --arcade cabinet
		setScrollFactor('bg', 0, 0);
		addLuaSprite('bg', false);
		setObjectCamera('bg', 'other')
		scaleObject('bg', '1','1');
		setProperty('bg.alpha', 0)

		moleTags = {}
		for i = 1, moleCount do
			local tag = 'mole' .. i

			makeAnimatedLuaSprite(tag, stage..'MINIGAME/MOLE', 0, 0)
			addAnimationByPrefix(tag, 'idle', 'idleLaugh', 24, true)
			addAnimationByPrefix(tag, 'hit', 'hitTarget', 24, false)
			setScrollFactor(tag, 1, 1)
			scaleObject(tag, '0.9', '0.9')
			setObjectCamera(tag, 'other')
			objectPlayAnimation(tag, 'idle', true)
			setProperty(tag .. '.visible', false)
			setProperty(tag .. '.alpha', 0)
			updateHitbox(tag)
			addLuaSprite(tag, true)

			table.insert(moleTags, tag)
		end

		-- == HUD ELEMENTS ==
		makeLuaSprite('titleGame', stage..'MINIGAME/TITLE', 0, 0); 
		setScrollFactor('titleGame', 0, 0);
		scaleObject('titleGame', '1','1');
		setProperty('titleGame.x', (screenWidth/2) - (getProperty('titleGame.width')/2))
		setProperty('titleGame.y', (screenHeight/2) - (getProperty('titleGame.height')/2))
		updateHitbox('titleGame')

		makeLuaText('time', '', screenWidth, '200', '0') -- timer
		setTextFont('time', 'GothicJoker.ttf')
		setTextAlignment('time', 'left')
		setTextSize('time','65')
		addLuaText('time')
		setTextColor('time', 'f13174')
		setTextBorder('time', '2', '000000')
		setProperty('time.x', (getProperty('base.width') + 550))
		setProperty('time.y', screenHeight - 200)

		makeLuaText('score', '', screenWidth, '0', '0') -- score
		setTextFont('score', 'GothicJoker.ttf')
		setTextAlignment('score', 'left')
		setTextSize('score','45')
		setTextBorder('score', '2', '000000')
		setProperty('score.x', (getProperty('base.width') + 550))
		setProperty('score.y', screenHeight - 100)

		makeLuaSprite('winText', stage..'MINIGAME/WIN', 0, 0); 
		setScrollFactor('winText', 0, 0);
		scaleObject('winText', '0.3','0.3');
		setProperty('winText.x', (screenWidth/2) - (getProperty('winText.width')/2))
		setProperty('winText.y', (screenHeight/2) - (getProperty('winText.height')/2))

		makeLuaSprite('loseText', stage..'MINIGAME/FAIL', 0, 0); 
		setScrollFactor('loseText', 0, 0);
		scaleObject('loseText', '0.3','0.3');
		setProperty('loseText.x', (screenWidth/2) - (getProperty('loseText.width')/2))
		setProperty('loseText.y', (screenHeight/2) - (getProperty('loseText.height')/2))

		setProperty('titleGame.visible', false)
		setProperty('winText.visible', false)
		setProperty('loseText.visible', false)
		setProperty('time.visible', false)
		setProperty('score.visible', false)

		--camera
		setObjectCamera('titleGame', 'other')
		setObjectCamera('winText', 'other')
		setObjectCamera('loseText', 'other')
		setObjectCamera('time', 'other')
		setObjectCamera('score', 'other')

		setProperty('titleGame.alpha', 0)
		setProperty('winText.alpha', 0)
		setProperty('loseText.alpha', 0)
		setProperty('time.alpha', 0)
		setProperty('score.alpha', 0)

		--add
		addLuaSprite('titleGame', false);
		addLuaSprite('winText', true);
		addLuaSprite('loseText', true);
		addLuaText('score')
		addLuaText('time')
		addLuaText('endGameText')
		
		-- == TIMER BAR == --
		makeLuaSprite('timerBarBG', '', 0, 0)
		makeGraphic('timerBarBG', timerBarWidth, timerBarHeight, '000000')
		setObjectCamera('timerBarBG', 'other')
		addLuaSprite('timerBarBG', true)

		setProperty('timerBarBG.x', (getProperty('base.width') + 550))
		setProperty('timerBarBG.y', screenHeight - 130)

		makeLuaSprite('timerBar', '', 0, 0)
		makeGraphic('timerBar', timerBarWidth, timerBarHeight, 'f13174')
		setObjectCamera('timerBar', 'other')
		addLuaSprite('timerBar', true)
		setProperty('timerBar.x', getProperty('timerBarBG.x'))
		setProperty('timerBar.y', getProperty('timerBarBG.y'))
		setGraphicSize('timerBar', 1, timerBarHeight)
		updateHitbox('timerBar')

		setProperty('timerBarBG.visible', false)
		setProperty('timerBar.visible', false)
		setProperty('timerBarBG.alpha', 0)
		setProperty('timerBar.alpha', 0)

		-- == CURSOR ==
		cursorX = getMouseX('other')
		cursorY = getMouseY('other')

		makeLuaSprite('cursor', stage..'MINIGAME/CURSOR_TARGET', cursorX,cursorY)
		setObjectCamera('cursor', 'other')
		scaleObject('cursor', '0.3','0.3');
		setProperty('cursor.alpha', 0)
		addLuaSprite('cursor', true)

		-- == RELOAD HINT ==

		makeLuaText('reloadHint', 'RELOAD', 0, 0, 0)
		setTextFont('reloadHint', 'GothicJoker.ttf')
		setTextAlignment('reloadHint', 'center')
		setTextSize('reloadHint', 32)
		setObjectCamera('reloadHint', 'other')
		setProperty('reloadHint.visible', false)
		addLuaText('reloadHint')
	end

	--
	makeLuaSprite('clipTop', '', 0, -50);
	makeGraphic('clipTop', screenWidth, 50, '000000')
	makeLuaSprite('clipBottom', '', 0, screenHeight);
	makeGraphic('clipBottom', screenWidth, 50, '000000')
	setObjectCamera('clipBottom', 'other')
	setObjectCamera('clipTop', 'other')
	addLuaSprite('clipTop', false);
	addLuaSprite('clipBottom', false);
	
-- == QTE STUFF ==
	makeLuaSprite('qteSpaceIcon', hud..'4-hudShit/PUNCHICON', 0, 0);
	setObjectCamera('qteSpaceIcon', 'other')
    addLuaSprite('qteSpaceIcon', true)
    setProperty('qteSpaceIcon.alpha', 0)

	makeLuaSprite('qteRing', hud..'4-hudShit/PUNCH CIRCLE', 0, 0)
    setObjectCamera('qteRing', 'other')
    addLuaSprite('qteRing', true)
    setProperty('qteRing.alpha', 0)
	screenCenter('qteRing', '')

	repositionQTEUI()

-- == TOOL TIP ==
	makeLuaSprite('tooltipBG', hud..'4-hudShit/toolTipBG2', tooltipX, 0)
	setObjectCamera('tooltipBG', 'other')
	setProperty('tooltipBG.alpha', 0)
	addLuaSprite('tooltipBG', true)

	makeLuaText('tooltipText', '', tooltipWidth, tooltipX + tooltipPadding, 0)
	setTextSize('tooltipText', 18)
	setTextColor('tooltipText', 'FFFFFF')
	setTextBorder('tooltipText', 1, '000000')
	setTextAlignment('tooltipText', 'left')
	setObjectCamera('tooltipText', 'other')
	setProperty('tooltipText.alpha', 0)
	addLuaText('tooltipText')

	setProperty('tooltipBG.y', tooltipY)
	setProperty('tooltipText.y', tooltipY + tooltipPadding)
end

function onDialogueFinished()
	if songName == 'destination' and isStoryMode then
		doShakeTrain = true
	end
end


function onUpdate(elapsed)
-- =============== QTE ===============
	if qteActive then
        qteTimer = qteTimer - elapsed
       
        if qteTimer <= 0 then
            failLucyQTE()
        elseif getPropertyFromClass('flixel.FlxG', 'keys.justPressed.SPACE') then
            hitLucyQTE()
        end
    end

    -- when punch anim ends, go back to idle
    if qtePunching then
       if getProperty('lucyFight.animation.curAnim.finished') then
			if qteFinalBlow then
				qtePunching = false
			else
				qtePunching = false
            	playAnim('lucyFight', 'idle', true)
			end
        end
    end

	for tag, r in pairs(reveals) do
		r.t = r.t + elapsed
		local p = r.t / r.dur
		if p >= 1 then
			applyReveal(tag, 1, r.dir)
			runHaxeCode([[
				var spr = game.getLuaObject("]]..tag..[[", true);
				if (spr != null) { spr.clipRect = null; spr.drawFrame(); }
			]])
			reveals[tag] = nil
		else
			applyReveal(tag, p, r.dir)
		end
   end

	if not lowQuality then
		
		addOffset('side','peep', 145, 0)
		if panDoor then

			local cx = getProperty('camFollow.x')
			local cy = getProperty('camFollow.y')

			local t = math.min(1, elapsed * 6) -- smaller = slower
			setProperty('camFollow.x', cx + (xShit - cx) * t)
			setProperty('camFollow.y', cy + (yShit - cy) * t)

			triggerEvent('Camera Follow Pos', tostring(xShit), tostring(yShit))
			doTweenZoom('peep', 'camGame', zoomNum, zoomSpeed, 'circOut')
		end
		
	end

	--HYPNO
	if isHypno then
		setProperty('boyfriend.alpha', 0)
		
		xShit = 650;
		yShit = 650;
	end

	if startEnding == true then
		setProperty('boyfriend.alpha', 0)
		xShit = 500;
		yShit = 660;
	end

	if lostGame then
		setProperty('vocals.volume', 0)
	end

	-- CAMERA
	if doZoom then
		if mustHitSection == false  then
			setProperty('defaultCamZoom',1)
			doTweenZoom('hellowee', 'camGame', '1', 0.5, 'backOut') -- headhunter
		else
            setProperty('defaultCamZoom',0.9) -- lucy
        end
	end
	
	if not inGameOver and not doShakeTrain then
		startSmoothShake(1, 1)
	else
		startSmoothShake(0, 1)
	end

	--CHARACTER PROP
	if dadName == 'headhunter' then
		setProperty('dad.x', 1300)
	end

	if boyfriendName == 'lucy-train' then
		setProperty('boyfriend.x', 100)
		
	end

	setProperty('dad.scrollFactor.x', 0.9);
	setProperty('dad.scrollFactor.y', 0.9);
	setProperty('boyfriend.scrollFactor.x', 0.9);
	setProperty('boyfriend.scrollFactor.y', 0.9);

	addOffset('lucyHyp','win', 50, 85)
	addOffset('lucyHyp','lose', -155, 0)
	addOffset('lucyFight','idle', 0, 0)
	addOffset('lucyFight','beat', 0, 47)
	addOffset('lucyFight','beat2', 0, 37)
	addOffset('lucyFight','ending', 66, 49)

	-- if getPropertyFromClass('flixel.FlxG', 'keys.justPressed.W') then
	-- 	playAnim('lucyFight', 'idle', true)
  	-- elseif getPropertyFromClass('flixel.FlxG', 'keys.justPressed.Q') then
	-- 	playAnim('lucyFight', 'beat', true)
	-- elseif getPropertyFromClass('flixel.FlxG', 'keys.justPressed.E') then
	-- 	playAnim('lucyFight', 'beat2', true)
	-- elseif getPropertyFromClass('flixel.FlxG', 'keys.justPressed.S') then
	-- 	playAnim('lucyFight', 'ending', true)
	-- end

	-- setProperty('dad.alpha', 0)
	-- setProperty('boyfriend.alpha', 1)
	setProperty('gf.visible', false)

-- =============== CUSTOM FUNCTIONS ===============
	if blurActive then
		blurAlpha = blurAlpha - (elapsed * 1) -- how fast it fades out

		if blurAlpha <= 0 then
			blurAlpha = 0
			blurActive = false
			runHaxeCode("FlxG.camera.setFilters([]);") -- clear blur when done
		else
			runHaxeCode([[
				var alpha = ]] .. blurAlpha .. [[;
				var filter = new openfl.filters.BlurFilter(6 * alpha, 6 * alpha, 2);
				FlxG.camera.setFilters([filter]);
			]])
		end
	end

	if shakeTime > 0 then
		shakeTime = shakeTime - elapsed
		local progress = 1 - (shakeTime / shakeDuration)
		local falloff = 1 - progress -- fades out smoothly

		local offsetX = math.sin(os.clock() * 20) * shakeStrength * falloff
		local offsetY = math.cos(os.clock() * 25) * shakeStrength * falloff

		setProperty('camGame.x', offsetX)
		setProperty('camGame.y', offsetY)

		if shakeTime <= 0 then
			setProperty('camGame.x', 0)
			setProperty('camGame.y', 0)
		end
	end


	if forceCam then
		local cx = getProperty('camFollow.x')
		local cy = getProperty('camFollow.y')

		local t = math.min(1, elapsed * 6)
		setProperty('camFollow.x', cx + (xShit - cx) * t)
		setProperty('camFollow.y', cy + (yShit - cy) * t)

		triggerEvent('Camera Follow Pos', tostring(xShit), tostring(yShit))
	elseif followchars == true then
        if mustHitSection == false then
            if getProperty('dad.animation.curAnim.name') == 'singLEFT' then
                triggerEvent('Camera Follow Pos',xx-ofs2,yy)
            end
            if getProperty('dad.animation.curAnim.name') == 'singRIGHT' then
                triggerEvent('Camera Follow Pos',xx+ofs2,yy)
            end
            if getProperty('dad.animation.curAnim.name') == 'singUP' then
                triggerEvent('Camera Follow Pos',xx,yy-ofs2)
            end
            if getProperty('dad.animation.curAnim.name') == 'singDOWN' then
                triggerEvent('Camera Follow Pos',xx,yy+ofs2)
            end
            if getProperty('dad.animation.curAnim.name') == 'singLEFT-alt' then
                triggerEvent('Camera Follow Pos',xx-ofs2,yy)
            end
            if getProperty('dad.animation.curAnim.name') == 'singRIGHT-alt' then
                triggerEvent('Camera Follow Pos',xx+ofs2,yy)
            end
            if getProperty('dad.animation.curAnim.name') == 'singUP-alt' then
                triggerEvent('Camera Follow Pos',xx,yy-ofs2)
            end
            if getProperty('dad.animation.curAnim.name') == 'singDOWN-alt' then
                triggerEvent('Camera Follow Pos',xx,yy+ofs2)
            end
            if getProperty('dad.animation.curAnim.name') == 'idle-alt' then
                triggerEvent('Camera Follow Pos',xx,yy)
            end
            if getProperty('dad.animation.curAnim.name') == 'idle' then
                triggerEvent('Camera Follow Pos',xx,yy)
            end
           
      else
               
            if getProperty('boyfriend.animation.curAnim.name') == 'singLEFT' then
                triggerEvent('Camera Follow Pos',xx2-ofs,yy2)
            end
	  		if getProperty('boyfriend.animation.curAnim.name') == 'LEFTshoot' then
                triggerEvent('Camera Follow Pos',xx2-ofs,yy2)
            end
            if getProperty('boyfriend.animation.curAnim.name') == 'singRIGHT' then
                triggerEvent('Camera Follow Pos',xx2+ofs,yy2)
            end
	 		if getProperty('boyfriend.animation.curAnim.name') == 'RIGHTshoot' then
                triggerEvent('Camera Follow Pos',xx2+ofs,yy2)
            end
            if getProperty('boyfriend.animation.curAnim.name') == 'singUP' then
                triggerEvent('Camera Follow Pos',xx2,yy2-ofs)
            end
			if getProperty('boyfriend.animation.curAnim.name') == 'UPshoot' then
                triggerEvent('Camera Follow Pos',xx2,yy2-ofs)
            end
            if getProperty('boyfriend.animation.curAnim.name') == 'singDOWN' then
                triggerEvent('Camera Follow Pos',xx2,yy2+ofs)
            end
	   		if getProperty('boyfriend.animation.curAnim.name') == 'DOWNshoot' then
                triggerEvent('Camera Follow Pos',xx2,yy2+ofs)
            end
            if getProperty('boyfriend.animation.curAnim.name') == 'singRIGHT-alt' then
                triggerEvent('Camera Follow Pos',xx2+ofs,yy2)
            end
            if getProperty('boyfriend.animation.curAnim.name') == 'singUP-alt' then
                triggerEvent('Camera Follow Pos',xx2,yy2-ofs)
            end
            if getProperty('boyfriend.animation.curAnim.name') == 'singDOWN-alt' then
                triggerEvent('Camera Follow Pos',xx2,yy2+ofs)
            end
	    	if getProperty('boyfriend.animation.curAnim.name') == 'idle-alt' then
                triggerEvent('Camera Follow Pos',xx2,yy2)
            end
        end
   	else
      triggerEvent('Camera Follow Pos','','') -- self explanatory
   	end

-- =============== MINIGAME ===============
	if gameRunning then

		setProperty('cursor.x', getMouseX('other') - 3);
		setProperty('cursor.y', getMouseY('other') - 3);

		if luaTextExists('reloadHint') then
			setProperty('reloadHint.x', (getProperty('cursor.x') - getProperty('reloadHint.width') / 2) + 15)
			setProperty('reloadHint.y', getProperty('cursor.y') + 50)
		end
	
		if mouseClicked('left') then -- shoot
			if not reloading then

				if ammo > 0 then

					shotSound()

					ammo = ammo - 1
					updateBullets()

					recoil = recoilMax
					cursorScale = 1

					local hitTag = nil

					if moleTags ~= nil then
						for _, tag in ipairs(moleTags) do
							if luaSpriteExists(tag) and getProperty(tag .. '.alpha') > 0 and objectsOverlap('cursor', tag) then
								hitTag = tag
								break
							end
						end
					end

					if hitTag ~= nil then
						lastHitMole = hitTag

						if score < 10 and getProperty(hitTag .. '.alpha') > 0 and getProperty(hitTag .. '.animation.curAnim.name') ~= 'hit'  then
							playAnim(hitTag, 'hit', true)
							
							hammerHit()
							runTimer('moleHitDelay_' .. hitTag, 0.7, 1)

							score = score + 1

							if score >= 10 and not gameWon then
							
								gameRunning = false
								gameWon = true
								wonGame = true
								isMoleVisible = false
								isTimerActive = false
								
								startMiniGameEndFade()
								endGame()

								doTweenAlpha('fadeInWinText', 'winText', 1, 0.12, 'quadOut')
								doTweenX('winTextScaleX', 'winText.scale', 1, 0.12, 'backOut')
   	 							doTweenY('winTextScaleY', 'winText.scale', 1, 0.12, 'backOut')
							end
						end
					end

				else
					playSound('MINIGAME/gun/empty', 1)
				end
			end
		end

		if keyboardJustPressed('SHIFT') and ammo < maxBullets and not reloading then -- reload
			reloading = true
			reloadIndex = ammo
			runTimer('reloadStep', 0.08, maxBullets - ammo)
			playSound('MINIGAME/gun/reload', 1)
		end

		if isTimerActive then

			timer = timer + elapsed
			setTextString('time', "Timer: ".. math.ceil(timer) .. "'s")
			setTextString('score', "Score: ".. score .."!")
			if timer >= timerMax then
				isTimerActive = false
				timer = timerMax
				lostGame = true
				isMoleVisible = false
			
				doTweenAlpha('fadeInLoseText', 'loseText', 1, 0.12, 'quadOut')
				doTweenX('loseTextScaleX', 'loseText.scale', 1, 0.12, 'backOut')
				doTweenY('loseTextScaleY', 'loseText.scale', 1, 0.12, 'backOut')

				startMiniGameEndFade()
				endGame()
			end

			local target = timer / timerMax
			if target < 0 then target = 0 end
			if target > 1 then target = 1 end

			timerLerp = lerp(timerLerp, target, math.min(elapsed * 8, 1))

			local barPixels = math.floor(timerBarWidth * timerLerp)
			if barPixels < 1 then barPixels = 1 end

			setGraphicSize('timerBar', barPixels, timerBarHeight)
			updateHitbox('timerBar')
		end

		if luaSpriteExists('cursor') then
			cursorScale = lerp(cursorScale, 0.7, elapsed * 12)
			setProperty('cursor.scale.x', cursorScale)
			setProperty('cursor.scale.y', cursorScale)
		end

		setProperty('loseText.x', (screenWidth/2) - (getProperty('loseText.width')/2))
		setProperty('loseText.y', (screenHeight/2) - (getProperty('loseText.height')/2))
		setProperty('winText.x', (screenWidth/2) - (getProperty('winText.width')/2))
		setProperty('winText.y', (screenHeight/2) - (getProperty('winText.height')/2))
	
	end

	

	if recoil > 0 then
		recoil = recoil - elapsed * recoilDamp
		if recoil < 0 then recoil = 0 end

		local t = recoil / recoilMax
		local kick = (t * t) * 12  -- vertical kick amount
		local shakeX = math.sin((1 - t) * 40) * kick * 0.4

	
		setProperty('camOther.scroll.x', baseCamOtherX + shakeX)
		setProperty('camOther.scroll.y', baseCamOtherY - kick)
		setProperty('camOther.angle', shakeX * 0.3)
	
	else
		-- reset when done
		setProperty('camOther.scroll.x', baseCamOtherX)
		setProperty('camOther.scroll.y', baseCamOtherY)
		setProperty('camOther.angle', 0)
	end

end

-- intro
function openingIntro() 

	if songName == 'destination' then

		playSound('MINIGAME/trainIntro', 1 , 'trainIntroSFX')

		panDoor = true
		xShit = -10
		yShit = 500

		runTimer('comeout', 2,1);
		runTimer('shock', 4.5,1);
		runTimer('panToHH', 5.5,1);
		runTimer('HHINTRO', 6,1);
		runTimer('panToNormal', 12,1);
		runTimer('showLucy', 14,1);
		runTimer('gameStart', 15,1);

		letterBox(1, 1, 0)
	end
	
end

function openingIntroStory() 

	if songName == 'destination' then

		doTweenAlpha('introFadeOut', 'fade', 0, 0.5, 'circOut')

		panDoor = true
		playSound('MINIGAME/trainIntro', 1 , 'trainIntroSFX')
		
		runTimer('comeout', 2,1);
		runTimer('shock', 4.5,1);
		runTimer('panToHH', 5.5,1);
		runTimer('HHINTRO', 6,1);
		runTimer('panToNormal', 12,1);
		runTimer('showLucy', 14,1);
		runTimer('gameStart', 15,1);

		letterBox(1, 1, 0)
	end
	
end

function revealHH()

	setProperty('HHArt.alpha', 1)
	startDirectionalReveal('HHArt', 0.6, 'L2R')
	doTweenAlpha('HHNameReveal', 'HHName', 1, 1, 'circOut')
	doTweenAlpha('bossFade', 'fade', 0.5, 1, 'circOut')
	doTweenX('HHNameRevealX', 'HHName', 100, 3, 'circOut')

end

function startEnding()
	startEnding = true
	followchars = false
	forceCam = true
	doZoom = false

	setProperty('lucyFight.visible', true)
	playAnim('lucyFight', 'intro', true)

	letterBox(1, 1, 0)
	runTimer('turnOff', 0.7, 1) -- turns off the light and plays gunshot and fighting sound
	runTimer('intoPosition', 5, 1)
	runTimer('turnOn', 8, 1)
end


function onBeatHit()
end


stepHitFuncs = { 

	[80] = function()
		showTooltip("Headhunter isn't your usual opponent, she'll use hypnosis to control your actions. Use MOUSE to aim and shoot and press SHIFT to reload your weapon.", 8)
	end,

	[150] = function()
		showTooltip("Later on when she's weakened, you'll have to face her directly, press SPACE when prompted to beat the ever-loving shit out of her.", 5)
	end,

	[188] = function() 
		doTweenZoom('startingSong', 'camGame', '0.9', 0.5, 'circOut')
	end,

	[726] = function()
		miniGameIntro()
	end,

	[1337] = function() --
		startEnding()
	end,

	[1545] = function() --
		startLucyFinalQTE()
	end,

}

function onStepHit()
	if stepHitFuncs[curStep] then
		stepHitFuncs[curStep]()
	end

end

function onTweenCompleted(tag, loops, loopsLeft)
	
	if string.sub(tag, 1, 11) == 'moleHitOut_' then
        local sprite = string.sub(tag, 12)

        if sprite ~= nil and luaSpriteExists(sprite) then
         	if gameRunning and not gameWon then
				respawnMole(sprite)
				setProperty(sprite .. '.alpha', 0)
				doTweenAlpha('moleHitIn_' .. sprite, sprite, 1, 0.12, 'quadIn')
			else
				setProperty(sprite .. '.visible', false)
				setProperty(sprite .. '.alpha', 0)
			end
        end

    end

	
end

function onTimerCompleted(tag, loops, loopsLeft)
	if tag == 'tooltipHide' then
		doTweenAlpha('tooltipBG_out',  'tooltipBG',  0.0, 0.25, 'quadIn')
		doTweenAlpha('tooltipText_out','tooltipText',0.0, 0.25, 'quadIn')
   end
-- == QTE ==
 	if tag == 'qte_impact' then
        doTweenZoom('qte_zoom_in', 'camGame', 1.1, 0.8, 'elasticOut')
        cameraShake('camGame', 0.030, 0.2)
		cameraShake('camHUD', 0.007, 0.4)
		triggerBlur()
	
	elseif tag == 'doAgain' then
		startLucyQTE()
	end

-- == INTRO ==
	if tag == 'comeout' then
		playAnim('side', 'peep',true, false, 1)
		setProperty('dad.alpha', 1)
	end

	if tag == 'shock' then
		zoomNum = 1.05
	end

	if tag == 'panToHH' then
		triggerEvent('Play Animation', 'introTrans', 'Dad') 
		xShit = 1550
		yShit = 650
		zoomNum = 1.2
		zoomSpeed = 3
	end

	if tag == 'HHINTRO' then
		revealHH()
		runTimer('HHoutro', 3,1);
	end

	if tag == 'HHoutro' then
		doTweenAlpha('HHNameHide', 'HHName', 0, 0.5, 'circIn')
		doTweenX('HHNameHideX', 'HHName', 500, 0.5, 'circIn')
		doTweenAlpha('HHArtHide', 'HHArt', 0, 0.5, 'circIn')
		doTweenAlpha('bossFade', 'fade', 0, 1, 'circOut')
	end

	if tag == 'panToNormal' then
		xShit = 750
		yShit = 650
		zoomNum = 0.9
		zoomSpeed = 5
		setProperty('cameraSpeed', 0.3)
		objectPlayAnimation('side', 'idle',false);
		
		doTweenZoom('startingSong', 'camGame', '0.9', 0.5, 'circOut')
		addAnimationByPrefix('lucyIntro', 'intro', 'INTRO', 24, false);
		setProperty('lucyIntro.visible', true)
	end

	if tag == 'showLucy' then
		debug = 1
		setProperty('lucyIntro.visible', false)
		setProperty('boyfriend.alpha', debug)
	end

	if tag == 'forceCamShi' then
		forceCam = false
		followchars = true
		setProperty('cameraSpeed', 0.8)
	end

	if tag == 'gameStart' then
		followchars = true
		panDoor = false
		doZoom = true
		forceCam = false

		noteTweenX('swoosh22', 4, defaultOpponentStrumX0, 3, 'cubeOut')
		noteTweenX('swoosh33', 5, defaultOpponentStrumX1, 3, 'cubeOut')
		noteTweenX('swoosh11', 6, defaultOpponentStrumX2, 3, 'cubeOut')
		noteTweenX('swoosh41', 7, defaultOpponentStrumX3, 3, 'cubeOut')

		noteTweenX('swoosh44', 0, defaultPlayerStrumX0, 3, 'cubeOut')
		noteTweenX('swoosh55', 1, defaultPlayerStrumX1, 3, 'cubeOut')
		noteTweenX('swoosh66', 2, defaultPlayerStrumX2, 3, 'cubeOut')
		noteTweenX('swoosh77', 3, defaultPlayerStrumX3, 3, 'cubeOut')

		setProperty('cameraSpeed', 0.8)
		setProperty('boyfriend.alpha', 1)
		letterBoxOut() 

		runTimer('showPlayerTheirNotes', 1, 3)
	end

	if tag == 'showPlayerTheirNotes' then
		staggerPlayerStrums()
	end

	if tag == 'staggerStrum0' then pressPlayerStrum(0) end -- left
	if tag == 'staggerStrum1' then pressPlayerStrum(1) end -- down
	if tag == 'staggerStrum2' then pressPlayerStrum(2) end -- up
	if tag == 'staggerStrum3' then pressPlayerStrum(3) end -- right
-- == MINI GAME ==
	if string.sub(tag, 1, 10) == 'moleIntro_' then
		local sprite = string.sub(tag, 11)
		if luaSpriteExists(sprite) then
			doTweenAlpha('moleIntroFade_' .. sprite, sprite, 1, 0.25, 'quadOut')
		end
	end

	if tag == 'reloadStep' then
		reloadIndex = reloadIndex + 1
		ammo = math.min(reloadIndex, maxBullets)
		updateBullets()

		if ammo >= maxBullets then
			reloading = false
		end
	end

	if string.sub(tag, 1, 13) == 'moleHitDelay_' then
		local sprite = string.sub(tag, 14)

		if not gameRunning or gameWon or lostGame then
			return
		end

		if sprite ~= nil and luaSpriteExists(sprite) then
			doTweenAlpha('moleHitOut_' .. sprite, sprite, 0, 0.12, 'quadOut')
		end
	end

	if tag == 'gamePrep' then
		doTweenAlpha('startGame', 'black', 1, 1, 'smootherStepIn')
	end
	if tag == 'startTimer' then
		gameRunning = true
		isTimerActive = true
		doTweenAlpha('cursorIn', 'cursor', 1, 0.5, 'circOut')
		updateBullets()
	
	end

	if tag == 'startGame' then
		miniGameBegin()
	end

	if tag == 'miniGamePrep' then
		introMoles()

		doTweenAlpha('timeFadeIn', 'time', 1, 0.2, 'smootherStepOut')
		doTweenAlpha('timerFadeIn', 'timerBarBG', 1, 0.4, 'smootherStepOut')
		doTweenAlpha('timerBarFadeIn', 'timerBar', 1, 0.6, 'quadOut')
		doTweenAlpha('scoreFadeIn', 'score', 1, 0.8, 'quadOut')
	end

	if tag == 'frEnd' then
		gameRunning = false
	end

	if tag == 'closeMini' then
		destroyMiniGame()
	end
	
	if tag == 'gameTurnOn' then -- music plays, bg fades
		
		playSound('MINIGAME/themes/silly', 1, 'theme')
		soundFadeIn('theme', 1)

		doTweenAlpha('fadeArtIn', 'bg', 1, 1, 'smootherStepOut')
		doTweenAlpha('turnon', 'base', 1, 2, 'quadOut')
	end
	if tag == 'title' then
		doTweenAlpha('showTitle', 'titleGame', 1, 1, 'quadOut')

		introSound = getRandomInt(1, 2, true)
		randomIntro[introSound]();
	elseif tag == 'deleteScreen' then
		doTweenAlpha('deleteTitle', 'titleGame', 0, 1, 'quadOut')
		
	end
	if tag == 'fadeArcade' then
		doTweenAlpha('fadeArtOut', 'bg', 0, 1, 'smootherStepOut')
		doTweenAlpha('fadeBG2', 'base', 0, 0.5, 'smootherStepOut')
	end
	if tag == 'fadeText' then
		doTweenAlpha('fadeScore', 'score', 0, 0.5, 'smootherStepOut')
		doTweenAlpha('fadeTime', 'time', 0, 0.5, 'smootherStepOut')
		doTweenAlpha('fadeWinText', 'winText', 0, 1, 'smootherStepOut')
		doTweenAlpha('fadeLoseText', 'loseText', 0, 1, 'smootherStepOut')
	end
	if tag == 'fadeBlack' then
		doTweenAlpha('bgFade', 'black', 0, 0.5, 'quadOut')
	end
	if tag == 'endPrepWin' then -- ending game if won

		cameraShake('game', 0.003, 0.3)
		doTweenZoom('win', 'camGame', '0.9', 1, 'circOut')

	elseif tag == 'endPrep' then -- ending game if lost
	
		local randSFX = getRandomInt(1, 2)
		playSound(sounds..'DESTIN-DEATH-'..randSFX, 0.7, 'lucyDeath')
			
		cameraShake('game', 0.005, 0.2)

	elseif tag == 'endGameFR' then -- kills you if lost
	
		runHaxeCode([[
            game.health = 0;
            game.doDeathCheck();
        ]])

	end
	if tag == 'backToNormal' then
		isHypno = false
		followchars = true
		forceCam = false
		
		setProperty('lucyHyp.visible', false)
		setProperty('boyfriend.alpha', 1)
	end

	if tag == 'miniGameOutcomeSound' then
		playSound('MINIGAME/winSound', 1)
	end

	if tag == 'miniGameOutcome' then
		miniGameOutcome()
	end

	if tag == 'debug' then
		setProperty('boyfriend.alpha', 1)
	end

	
	if tag == 'automaticRelease' then
		doTweenAlpha('startGame', 'black', 0, 0.5, 'smootherStepIn')
		doTweenAlpha('helloAgain', 'camHUD', 1, 1, 'backIn')

		runTimer('backToNormal', 3,1);
		runTimer('playRelease', 0.5,1);

		playSound('MINIGAME/winSound', 1)

	end

		
	if tag == 'playRelease' then
	
		cameraShake('game', 0.003, 0.3)
		doTweenZoom('win', 'camGame', '0.9', 1, 'circOut')
		playAnim('lucyHyp', 'win',true, false, 1)

	end

-- == ENDING ==
	if tag == 'turnOff' then
		doTweenAlpha('lightsoff', 'fade', 1, 0.2, 'circOut')
		playSound(sounds.. 'BEATING/FIGHTBG', 1)
	elseif tag == 'intoPosition' then
		setProperty('dad.visible', false)
		setProperty('lucyFight.x', 450)
		setProperty('lucyFight.y', 450)
		playAnim('lucyFight', 'idle', true)

		doTweenZoom('prep', 'camGame', '1.1', 0.5, 'circOut')
		setProperty('defaultCamZoom',1.1)

		startEnding = false
		forceCam = true
		followchars = false
		doZoom = false

		xShit = 800
		yShit = 700
	elseif tag == 'turnOn' then
		doTweenAlpha('lightson', 'fade', 0, 0.2, 'circOut')
		runTimer('doAgain', 2.5, 6)
	elseif tag == 'finalBlow' then
		triggerBlur()
		cameraShake('camGame', 0.02, 0.2)
	elseif tag == 'panOutEnd' then
		doTweenZoom('prep', 'camGame', '0.9', 4, 'smootherStepInOut')
		setProperty('defaultCamZoom',0.9)
	end
end
-- ========================================== MINIGAME FUNCTIONS ==========================================
function miniGameBegin()

	runTimer('gameTurnOn', 0.5,1);
	runTimer('title', 1,1);
	runTimer('deleteScreen', 2,1); -- delete title screen logo

	runTimer('miniGamePrep', 3.5,1);
	runTimer('startTimer', 4,1);

	isMoleVisible = true
	timerLerp = 0

	ammo = maxBullets
	reloading, reloadIndex = false, 0
	bulletStartX, bulletY = 600, 100

	baseCamOtherX = getProperty('camOther.x')
	baseCamOtherY = getProperty('camOther.y')

	-- == AMMO DISPLAY == --
	for i = 1, maxBullets do
		local spr = 'bullet' .. i

		makeLuaSprite(spr, stage..'MINIGAME/BULLET', bulletStartX + (i - 1) * bulletSpacing, bulletY)

		setProperty(spr .. '.alpha', 0)
		setObjectCamera(spr, 'other')
		addLuaSprite(spr, true)
	end

	setProperty('titleGame.visible', true)
	setProperty('winText.visible', true)
	setProperty('loseText.visible', true)
	setProperty('time.visible', true)
	setProperty('score.visible', true)
	setProperty('timerBarBG.visible', true)
	setProperty('timerBar.visible', true)

end

function startMiniGameEndFade()
    -- fade moles
    if moleTags ~= nil then
        for i, tag in ipairs(moleTags) do
            if luaSpriteExists(tag) then
                doTweenAlpha('moleEnd_' .. tag, tag, 0, 0.25, 'quadIn')
            end
        end
    end

    -- fade bullets
    for i = 1, maxBullets do
        local b = 'bullet' .. i
        if luaSpriteExists(b) then
            doTweenAlpha('bulletEnd_' .. b, b, 0, 0.2, 'quadIn')
        end
    end

    -- fade timer / score / bar + bg
    local uiNames = {'time', 'score', 'timerBarBG', 'timerBar'}
    for _, name in ipairs(uiNames) do
        if luaTextExists(name) or luaSpriteExists(name) then
            doTweenAlpha('uiEnd_' .. name, name, 0, 0.25, 'quadIn')
        end
    end
end

function destroyMiniGame() -- kills minigame
	
	if gameWin then
		doTweenAlpha('helloAgain', 'camHUD', 1, 1, 'backIn')
		runTimer('endPrepWin', 1.5,1);
		runTimer('backToNormal', 3,1);
		runTimer('miniGameOutcomeSound', 0.5,1);

		soundFadeIn(_, 3)
	end

	if lostGame then
		runTimer('endPrep', 0.5, 1);
		runTimer('endGameFR', 3, 1);
	end

	runTimer('miniGameOutcome', 0.5,1);
end

--functions
function getIntroPos(existing)
    local minX = getProperty('base.x') + 110
    local maxX = getProperty('base.x') + 500
    local minY = getProperty('base.y') + 100
    local maxY = getProperty('base.y') + 500

	local minDistX, minDistY = 120, 120

	local x, y, ok

	for tries = 1, 25 do
        x = getRandomInt(minX, maxX)
        y = getRandomInt(minY, maxY)
        ok = true

        for _, p in ipairs(existing) do
            if math.abs(x - p.x) < minDistX and math.abs(y - p.y) < minDistY then
                ok = false
                break
            end
        end

        if ok then break end
    end

    return x, y
end

function introMoles()
    if moleTags == nil then return end

    local placed = {}

    for i, tag in ipairs(moleTags) do
        if luaSpriteExists(tag) then
            local x, y = getIntroPos(placed)
            table.insert(placed, {x = x, y = y})

            setProperty(tag .. '.x', x)
            setProperty(tag .. '.y', y)
            setProperty(tag .. '.visible', true)
            setProperty(tag .. '.alpha', 0)
            objectPlayAnimation(tag, 'idle', true)

            runTimer('moleIntro_' .. tag, 0.12 * (i - 1), 1)
        end
    end

	for i = 1, maxBullets do
        local b = 'bullet' .. i
        if luaSpriteExists(b) then
            doTweenAlpha('bulletStart_' .. b, b, 1, 0.5, 'quadIn')
        end
    end

    isMoleVisible = true
end

function getNonOverlappingPos(ignoreTag)
    local minX = getProperty('base.x') + 110
    local maxX = getProperty('base.x') + 500
    local minY = getProperty('base.y') + 100
    local maxY = getProperty('base.y') + 400

    local minDistX, minDistY = 120, 120

    local existing = {}

    if moleTags ~= nil then
        for _, tag in ipairs(moleTags) do
            if tag ~= ignoreTag and luaSpriteExists(tag) then
                table.insert(existing, {
                    x = getProperty(tag .. '.x'),
                    y = getProperty(tag .. '.y')
                })
            end
        end
    end

    local x, y, ok

    for tries = 1, 25 do
        x = getRandomInt(minX, maxX)
        y = getRandomInt(minY, maxY)
        ok = true

        for _, p in ipairs(existing) do
            if math.abs(x - p.x) < minDistX and math.abs(y - p.y) < minDistY then
                ok = false
                break
            end
        end

        if ok then break end
    end

    return x, y
end

function respawnMole(tag)
    if tag == nil or not luaSpriteExists(tag) then return end

    local x, y = getNonOverlappingPos(tag)

    setProperty(tag .. '.x', x)
    setProperty(tag .. '.y', y)
    setProperty(tag .. '.visible', true)
    setProperty(tag .. '.alpha', 1)
    objectPlayAnimation(tag, 'idle', true)
end

function updateBullets()
	for i = 1, maxBullets do
		local spr = 'bullet' .. i

		if i <= ammo then
			-- normal / "loaded" bullet
			setProperty(spr .. '.color', getColorFromHex('FFFFFF'))
			setProperty(spr .. '.alpha', 1)
		else
			-- spent bullet
			setProperty(spr .. '.color', getColorFromHex('000000'))
			setProperty(spr .. '.alpha', 0.5)
		end
	end

	if luaTextExists('reloadHint') then
		setProperty('reloadHint.visible', ammo == 0)
	end
end

function hammerHit()
	hurtSound = getRandomInt(1, 10, true)
	randomHurt[hurtSound]();
end

function shotSound()
   	local pitch = getRandomFloat(0.7, 1.1)

   	playSound('MINIGAME/gun/shot', 1, 'shotSound')
	setSoundPitch('shotSound', pitch)
end

function endGame()
	doTweenAlpha('curseleave', 'cursor', 0, 1, 'backIn')
	setProperty('reloadHint.visible', false)
	
	runTimer('frEnd', 1,1);
	runTimer('fadeArcade', 2,1);
	runTimer('fadeText', 2.5,1);
	runTimer('fadeBlack', 2.5,1);
	runTimer('closeMini', 3,1);

	stopSound('theme')
	if gameWon then
		setProperty('winText.visible', true)
		doTweenAlpha('fadeInWinText', 'winText', 1, 0.12, 'quadOut')
		doTweenX('winTextScaleX', 'winText.scale', 1, 0.12, 'backOut')
		doTweenY('winTextScaleY', 'winText.scale', 1, 0.12, 'backOut')

		playSound('MINIGAME/themes/win', 1, 'wonTheme')
		gameWin = true
		winVoice = getRandomInt(1, 3, true)
		randomWin[winVoice]();
	elseif not gameWon then

		setProperty('loseText.visible', true)
		doTweenAlpha('fadeInLoseText', 'loseText', 1, 0.12, 'quadOut')
		doTweenX('loseTextScaleX', 'loseText.scale', 1, 0.12, 'backOut')
		doTweenY('loseTextScaleY', 'loseText.scale', 1, 0.12, 'backOut')

		playSound('MINIGAME/themes/lose', 1, 'lostTheme')
		loseVoice = getRandomInt(1, 4, true)
		randomLose[loseVoice]();
	end
end

function miniGameIntro() -- 15 step hit
	isHypno = true
	followchars = false
	forceCam = true

	doTweenAlpha('byebye', 'camHUD', 0, 1, 'backOut')
	doTweenZoom('intense', 'camGame', '1.05', 5, 'smootherStepOut')
	
	if enableMinigame then
		runTimer('gamePrep', 2,1);
		runTimer('startGame', 4,1);
		soundFadeOut(_, 2)
	else
		doTweenAlpha('startGame', 'black', 1, 4, 'smootherStepIn')
		runTimer('automaticRelease', 10,1);
		--doTweenAlpha('startGame', 'black', 1, 1, 'smootherStepIn')
	end

	playSound('MINIGAME/introMini', 1, 'dazed')

	
	setProperty('lucyHyp.visible', true)
	playAnim('lucyHyp', 'intro',true, false, 1)
	triggerEvent('Play Animation', 'HYPNO', 'Dad') 
end

function miniGameOutcome() -- 45 step hit
	if gameWin then
		playAnim('lucyHyp', 'win',true, false, 1)
	end

	if lostGame == true then
		playAnim('lucyHyp', 'lose',true, false, 1)
	end
end

-- ========================================== CUSTOM FUNCTIONS ==========================================

randomIntro = { 
	[1] = function() 
		playSound('MINIGAME/intro/intro1', 1, 'intro1')
		
	end,
	[2] = function()
		playSound('MINIGAME/intro/intro2', 1, 'intro2')

	end

}

randomWin = { 
	[1] = function() 
		playSound('MINIGAME/win/win1', 0.6, 'win1')
		
	end,
	[2] = function()
		playSound('MINIGAME/win/win2', 0.6, 'win2')

	end,
	[3] = function()
		playSound('MINIGAME/win/win3', 0.6, 'win3')

	end

}

randomLose = { 
	[1] = function() 
		playSound('MINIGAME/lose/lose1', 0.6, 'lose1')
		
	end,
	[2] = function()
		playSound('MINIGAME/lose/lose2', 0.6, 'lose2')

	end,
	[3] = function()
		playSound('MINIGAME/lose/lose3', 0.6, 'lose3')

	end,
	[4] = function()
		playSound('MINIGAME/lose/lose4', 0.6, 'lose4')

	end

}

randomHurt = { 
	[1] = function() 
		playSound('MINIGAME/hurt/hurt1', 1)
		
	end,
	[2] = function()
		playSound('MINIGAME/hurt/hurt2', 1)

	end,
	[3] = function()
		playSound('MINIGAME/hurt/hurt3', 1)
		
	end,
	[4] = function()
		playSound('MINIGAME/hurt/hurt4', 1)
		
	end,
	[5] = function()
		playSound('MINIGAME/hurt/hurt5', 1)
		
	end,
	[6] = function()
		playSound('MINIGAME/hurt/hurt6', 1)

	end,
	[7] = function()
		playSound('MINIGAME/hurt/hurt7', 1)
		
	end,
	[8] = function()
		playSound('MINIGAME/hurt/hurt8', 1)
		
	end,
	[9] = function()
		playSound('MINIGAME/hurt/hurt9', 1)
		
	end,
	[10] = function()
		playSound('MINIGAME/hurt/hurt10', 1)
		
	end
		
}

randomHit = { 
	[1] = function() 
		playSound('MINIGAME/hit/hit1', 1)
		
	end,
	[2] = function()
		playSound('MINIGAME/hit/hit2', 1)

	end,
	[3] = function()
		playSound('MINIGAME/hit/hit3', 1)
		
	end
		
}

function showTooltip(text, dur)
   dur = dur or 3

	playSound('toolTipSFX', 1, 'tool')
	setTextString('tooltipText', text)

	local h = getProperty('tooltipText.height') + tooltipPadding * 2
	setGraphicSize('tooltipBG', tooltipWidth + tooltipPadding * 2, h)

	setProperty('tooltipBG.alpha', 0)
	setProperty('tooltipText.alpha', 0)
	setProperty('tooltipBG.visible', true)
	setProperty('tooltipText.visible', true)

	doTweenAlpha('tooltipBG_in',  'tooltipBG',  0.75, 0.18, 'quadOut')
	doTweenAlpha('tooltipText_in','tooltipText',1, 0.18, 'quadOut')

	runTimer('tooltipHide', dur)
end

function lerp(a, b, t)
	return a + (b - a) * t
end

function onGameOver()
	onPause()

	inGameOver = true
	return Function_Continue;
end

function startSmoothShake(strength, duration)
    shakeStrength = strength or 5
    shakeDuration = duration or 0.5
    shakeTime = shakeDuration
end

function triggerBlur()
	blurAlpha = 1 -- reset
	blurActive = true
end

function startDirectionalReveal(tag, dur, dir)
    reveals[tag] = {t=0, dur=dur or 0.6, dir=dir or 'L2R'}
    -- init fully hidden using frame dims
    runHaxeCode([[
        var spr = game.getLuaObject("]]..tag..[[", true);
        if (spr != null) {
            spr.clipRect = new flixel.math.FlxRect(0, 0, 0, spr.frameHeight);
            spr.drawFrame();
        }
    ]])
end

function applyReveal(tag, p, dir)
    if p < 0 then p = 0 end
    if p > 1 then p = 1 end

    runHaxeCode([[
        var spr = game.getLuaObject("]]..tag..[[", true);
        if (spr != null) {
            var fw = spr.frameWidth;
            var fh = spr.frameHeight;

            var rx = 0., ry = 0., rw = fw * ]]..p..[[, rh = fh * ]]..p..[[;
            switch ("]]..dir..[[") {
                case "L2R":
                    rx = 0;        ry = 0;        rw = fw * ]]..p..[[; rh = fh;
                case "R2L":
                    rw = fw * ]]..p..[[; rh = fh;  rx = fw - rw;   ry = 0;
                case "T2B":
                    rw = fw;       rh = fh * ]]..p..[[; rx = 0;        ry = 0;
                case "B2T":
                    rw = fw;       rh = fh * ]]..p..[[; rx = 0;        ry = fh - rh;
            }

            // If your sprite is atlas-packed and you see offset seams,
            // uncomment the next two lines to offset by the frame in the atlas:
            // rx += spr.frame.frame.x;
            // ry += spr.frame.frame.y;

            spr.clipRect = new flixel.math.FlxRect(rx, ry, rw, rh);
            spr.drawFrame();
        }
    ]])
end

function letterBox(speed, time, alpha) 
	doTweenY('clip1Move', 'clipTop', 0, speed, 'quadOut')
	doTweenY('clip2Move', 'clipBottom', screenHeight - 50, speed, 'quadOut')
	doTweenAlpha('byebye', 'camHUD', alpha, time, 'quadOut')
end

function letterBoxOut() 
	doTweenY('clip1Move', 'clipTop', -50, 1, 'smootherStepIn')
	doTweenY('clip2Move', 'clipBottom', screenHeight, 1, 'smootherStepIn')
	doTweenAlpha('hellohello', 'camHUD', 1, 0.5, 'circOut')
end

-- ========================================== QTE STUFF ==========================================
function repositionQTEUI()
   	setProperty('qteSpaceIcon.x', (screenWidth * 0.5) - (getProperty('qteSpaceIcon.width') * 0.5))
    setProperty('qteSpaceIcon.y', screenHeight - 180)

	screenCenter('qteRing', '')
end

function startLucyQTE()
	if qteActive then return end

    qteActive = true
    qteDone = false
    qteTimer = 0.75

    repositionQTEUI()

    setProperty('qteSpaceIcon.scale.x', 0.85)
    setProperty('qteSpaceIcon.scale.y', 0.85)

    setProperty('qteRing.alpha', 0.65)
    setProperty('qteRing.scale.x', 0.20)
    setProperty('qteRing.scale.y', 0.20)

    doTweenAlpha('qte_icon_in', 'qteSpaceIcon', 1, 0.12, 'quadOut')
    doTweenX('qte_icon_pop_x', 'qteSpaceIcon.scale', 1.0, 0.12, 'backOut')
    doTweenY('qte_icon_pop_y', 'qteSpaceIcon.scale', 1.0, 0.12, 'backOut')

    doTweenX('qte_ring_x', 'qteRing.scale', 3.2, 0.75, 'quadOut')
    doTweenY('qte_ring_y', 'qteRing.scale', 3.2, 0.75, 'quadOut')
    doTweenAlpha('qte_ring_fade', 'qteRing', 0, 0.75, 'quadOut')
end

function startLucyFinalQTE()
    if qteActive then return end

    qteActive = true
	qteFinalBlow = true
    qteDone = false
    qteTimer = 0.75

    repositionQTEUI()

    setProperty('qteSpaceIcon.scale.x', 0.85)
    setProperty('qteSpaceIcon.scale.y', 0.85)

    setProperty('qteRing.alpha', 0.65)
    setProperty('qteRing.scale.x', 0.20)
    setProperty('qteRing.scale.y', 0.20)

    doTweenAlpha('qte_icon_in', 'qteSpaceIcon', 1, 0.12, 'quadOut')
    doTweenX('qte_icon_pop_x', 'qteSpaceIcon.scale', 1.0, 0.12, 'backOut')
    doTweenY('qte_icon_pop_y', 'qteSpaceIcon.scale', 1.0, 0.12, 'backOut')

    doTweenX('qte_ring_x', 'qteRing.scale', 3.2, 0.75, 'quadOut')
    doTweenY('qte_ring_y', 'qteRing.scale', 3.2, 0.75, 'quadOut')
    doTweenAlpha('qte_ring_fade', 'qteRing', 0, 0.75, 'quadOut')
end

function failLucyQTE()
    if not qteActive then return end
    qteActive = false
    qteDone = true

	cancelTween('qte_icon_in')
    cancelTween('qte_icon_pop_x')
    cancelTween('qte_icon_pop_y')
    cancelTween('qte_ring_x')
    cancelTween('qte_ring_y')
    cancelTween('qte_ring_fade')

	if qteFinalBlow then
        playAnim('lucyFight', 'ending', true)
        playSound(sounds.. 'BEATING/endingShot', 1)
        runTimer('finalBlow', 1, 1)
        runTimer('panOutEnd', 3, 1)

	 	doTweenAlpha('qte_icon_out', 'qteSpaceIcon', 0, 0.12, 'quadIn')
        qtePunching = true
        return
    end
 
    setProperty('qteRing.alpha', 0)
    doTweenAlpha('qte_icon_out', 'qteSpaceIcon', 0, 0.12, 'quadIn')
end

function hitLucyQTE()
    if not qteActive then return end
    qteActive = false
    qteDone = true

    -- hide UI fast
    cancelTween('qte_icon_in')
    cancelTween('qte_icon_pop_x')
    cancelTween('qte_icon_pop_y')
    cancelTween('qte_ring_x')
    cancelTween('qte_ring_y')
    cancelTween('qte_ring_fade')

    setProperty('qteSpaceIcon.alpha', 0)
    setProperty('qteRing.alpha', 0)

  	if qteFinalBlow then
        playAnim('lucyFight', 'ending', true)
		playSound(sounds.. 'BEATING/endingShot', 1)
		runTimer('finalBlow', 1,1)
		runTimer('panOutEnd', 3,1)
    else
        if getRandomInt(1, 2) == 1 then
            playAnim('lucyFight', 'beat', true)
			playSound(sounds.. 'BEATING/punch-1', 1)
        else
            playAnim('lucyFight', 'beat2', true)
			playSound(sounds.. 'BEATING/punch-2', 1)
        end

		doTweenZoom('qte_zoom_out', 'camGame', 1, 0.20, 'circOut')
    	runTimer('qte_impact', 0.50, 1)
    end
    qtePunching = true

end

function staggerPlayerStrums()
	runTimer('staggerStrum0', 0, 1)
	runTimer('staggerStrum1', 0.3, 1)
	runTimer('staggerStrum2', 0.6, 1)
	runTimer('staggerStrum3', 0.9, 1)
end

function pressPlayerStrum(dir)
	runHaxeCode([[
		var dir = ]]..dir..[[;
		var spr = game.playerStrums.members[dir];

		if (spr != null)
		{
			spr.playAnim('pressed', true);
			spr.resetAnim = 0.3;
		}
	]])
end

function onPause()
	pauseSound('trainIntroSFX')
	pauseSound('theme')
	pauseSound('wonTheme')
	pauseSound('lostTheme')
	pauseSound('lucyDeath')

	pauseSound('dazed')

	pauseSound('intro1')
	pauseSound('intro2')
	pauseSound('win1')
	pauseSound('win2')	
	pauseSound('win3')
	pauseSound('lose1')
	pauseSound('lose2')
	pauseSound('lose3')
	pauseSound('lose4')
	return Function_Continue;
end

function onResume()
	resumeSound('trainIntroSFX')
	resumeSound('theme')
	resumeSound('wonTheme')
	resumeSound('lostTheme')
	resumeSound('lucyDeath')

	resumeSound('dazed')

	resumeSound('intro1')
	resumeSound('intro2')
	resumeSound('win1')
	resumeSound('win2')
	resumeSound('win3')
	resumeSound('lose1')
	resumeSound('lose2')
	resumeSound('lose3')
	resumeSound('lose4')

end