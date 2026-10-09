local xx, yy = 550, 570; --dad
local xx2, yy2 = 450, 600; --bf
local ofs = 15;  
local del, del2, i = 0, 0, 0;
local followchars = false; 
local allowCountdown, doDialogue = false, true;

local stage = 'stages/week1/gunrange/'
local hud = 'stages/hudelements/'

local canSpeedTalk = false
local usedSpeedUp = false
local talkSpeedBoost = 5
local normalSpeed = 1
local speedReturnTime = 1.2

-- tooltips
local tooltipPadding = 8
local tooltipWidth = 420
local tooltipY = 55
local tooltipX = 35

function onStartCountdown()

	if isStoryMode and songName == 'rehearsal' then
		if not allowCountdown and doDialogue and not censored and not seenCutscene then -- NOT CENSORED
			startDialogue('tutorialShit', 'dialogueMusic/rehearsalDia') 
			doDialogue = false
			allowCountdown = true;
			return Function_Stop

		elseif not allowCountdown and doDialogue and censored and not seenCutscene then
			startDialogue('tutorialCensored', 'dialogueMusic/rehearsalDia') 
			doDialogue = false
			allowCountdown = true;
			return Function_Stop
		end
		return Function_Continue
	end

	if songName == 'rehearsal' and isStoryMode then
		if not allowCountdown then
			return Function_Stop
		end

		if allowCountdown then
			return Function_Continue
		end
	end

end

function onCreatePost()

	removeLuaSprite('gf', true)
	runHaxeCode([[
		if (PlayState.instance.gf != null)
		{
			PlayState.instance.remove(PlayState.instance.gf, true);
			PlayState.instance.gf.destroy();
			PlayState.instance.gf = null;
		}
	]]);
end

function onCreate()

	--cameraShit
	camX = 'camFollow.x';	
	camY = 'camFollow.y';

	makeLuaSprite('wall', stage..'BG2', -300, -100);
	setScrollFactor('wall', 0.4, 0.7);
	addLuaSprite('wall', false);
	scaleObject('wall', '1.1','1');

	if not lowQuality then
		makeAnimatedLuaSprite('brute', stage..'BRUTUS', -350, 170);
		addAnimationByPrefix('brute', 'idle', 'BOP',24,true);
		setScrollFactor('brute', 0.5, 0.9);
		addLuaSprite('brute', false);
	end

	makeLuaSprite('wallSide', stage..'BG1', 1150, 50);
	setScrollFactor('wallSide', 0.7,0.8);
	addLuaSprite('wallSide', false);
	scaleObject('wallSide', '1.2','1');

	makeLuaSprite('counter', stage..'FG', -730, -60);
	setScrollFactor('counter', 1.1, 0.9);
	addLuaSprite('counter', true);
	scaleObject('counter', '1.2','1');

	makeAnimatedLuaSprite('chloeEnd', stage..'CHLOE-ENDING', 90, 260);
	addAnimationByPrefix('chloeEnd', 'gang', 'FUCK YOU FULL',24,true);
	setScrollFactor('chloeEnd', 0.9, 0.9);
	addLuaSprite('chloeEnd', false);
	setProperty('chloeEnd.visible', false)
	scaleObject('chloeEnd', '1','1');

	makeAnimatedLuaSprite('chloeListen', stage..'CHLOE-LISTEN', 110, 305);
	addAnimationByPrefix('chloeListen', 'listen', 'LISTEN0',24,true);
	addAnimationByPrefix('chloeListen', 'intro', 'LISTENINTRO',24,false);
	addAnimationByPrefix('chloeListen', 'end', 'LISTENEND',24,false);
	setScrollFactor('chloeListen', 0.9, 0.9);
	addLuaSprite('chloeListen', false);
	setProperty('chloeListen.visible', false)
	scaleObject('chloeListen', '1','1');

	addOffset('chloeListen','intro', 5, 35) -- -5, 35
	addOffset('chloeListen','listen', 5, 15) -- -5, 15

	makeLuaSprite('clipTop', '', 0, -100);
	setScrollFactor('clipTop', 1, 1);
	addLuaSprite('clipTop', false);
	scaleObject('clipTop', '1','1');
	makeGraphic('clipTop', screenWidth, 80, '000000')
	setObjectCamera('clipTop', 'other')

	makeLuaSprite('clipBottom', '', 0, screenHeight + 100);
	setScrollFactor('clipBottom', 1, 1);
	addLuaSprite('clipBottom', false);
	scaleObject('clipBottom', '1','1');
	makeGraphic('clipBottom', screenWidth, 80, '000000')
	setObjectCamera('clipBottom', 'other')

	makeLuaSprite('topIntro', '', -400, -screenHeight);
	setScrollFactor('topIntro', 1, 1);
	addLuaSprite('topIntro', true);
	scaleObject('topIntro', '1.4','1');
	makeGraphic('topIntro', screenWidth, screenHeight, '000000')
	
	------------------------------------------------------- TEXT SHIT --------------------------------------------------------

	makeAnimatedLuaSprite('textbg', hud..'4-hudShit/TEXTBOXES', 0, 450);
	addAnimationByPrefix('textbg', 'chloe', 'textBoxChloe',12,true);
	addAnimationByPrefix('textbg', 'jasmine', 'textBoxJasmine',12,true);
	addAnimationByPrefix('textbg', 'lucy', 'textBoxLucy',12,true);
	objectPlayAnimation('textbg', 'jasmine',true);
	setObjectCamera('textbg', 'other')
	scaleObject('textbg', '0.9','0.9');
	screenCenter('textbg', 'x')
	addLuaSprite('textbg', false);
	setProperty('textbg.alpha', 0)

	makeLuaText('talk2', '', '1100', '495', '510')
	setTextFont('talk2', 'GothicJoker.ttf')
	setTextAlignment('talk2', 'left')
	setObjectCamera('talk2', 'other')
	setTextSize('talk2','40')
	setTextString('talk2', 'Alright! So first, we need to train you on your firing. Hold your gun with both hands and aim at your target... And shoot that shit.')

	addLuaText('talk2')
	setProperty('talk2.alpha', 0)
	setTextBorder('talk2', '0', '')

	--tooltips
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

function onUpdate(elapsed)

	for i = 0,3 do 
		setPropertyFromGroup('strumLineNotes', i, 'alpha', alpha)
	end
	
	if canSpeedTalk and not usedSpeedUp and getPropertyFromClass('flixel.FlxG', 'keys.justPressed.SPACE') then
		usedSpeedUp = true
		currentTalkSpeed = talkSpeedBoost
	end

	if currentTalkSpeed > normalSpeed then
		currentTalkSpeed = currentTalkSpeed - elapsed * 0.6
		if currentTalkSpeed < normalSpeed then currentTalkSpeed = normalSpeed end

		setProperty('playbackRate', currentTalkSpeed)
	end
	
	setProperty('gf.alpha', 0)

	setObjectOrder('chloeListen', 10)
	setObjectOrder('chloeEnd', 10)

	setProperty('dad.scrollFactor.x', 0.9);
	setProperty('dad.scrollFactor.y', 0.9);

	setProperty('boyfriend.scrollFactor.x', 0.9);
	setProperty('boyfriend.scrollFactor.y', 0.9);

	daElapsed = elapsed * 30
	i = i + daElapsed

	if del > 0 then
		del = del - 1
	end
	if del2 > 0 then
		del2 = del2 - 1
	end
    if followchars == true then
        if mustHitSection == false then
            if getProperty('dad.animation.curAnim.name') == 'singLEFT' then
                triggerEvent('Camera Follow Pos',xx-ofs,yy)
            end
            if getProperty('dad.animation.curAnim.name') == 'singRIGHT' then
                triggerEvent('Camera Follow Pos',xx+ofs,yy)
            end
            if getProperty('dad.animation.curAnim.name') == 'singUP' then
                triggerEvent('Camera Follow Pos',xx,yy-ofs)
            end
            if getProperty('dad.animation.curAnim.name') == 'singDOWN' then
                triggerEvent('Camera Follow Pos',xx,yy+ofs)
            end
            if getProperty('dad.animation.curAnim.name') == 'singLEFT-alt' then
                triggerEvent('Camera Follow Pos',xx-ofs,yy)
            end
            if getProperty('dad.animation.curAnim.name') == 'singRIGHT-alt' then
                triggerEvent('Camera Follow Pos',xx+ofs,yy)
            end
            if getProperty('dad.animation.curAnim.name') == 'singUP-alt' then
                triggerEvent('Camera Follow Pos',xx,yy-ofs)
            end
            if getProperty('dad.animation.curAnim.name') == 'singDOWN-alt' then
                triggerEvent('Camera Follow Pos',xx,yy+ofs)
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
    
end

------------------------------ TALKING FUNCTIONS -------------------------------------

function letterBoxJasmineTalk() 

	doTweenY('clip1Move', 'clipTop', -30, 1, 'smootherStepIn')
	doTweenY('clip2Move', 'clipBottom', 660, 1, 'smootherStepIn')
	doTweenAlpha('byebye', 'camHUD', 0, 0.5, 'backIn')
	followchars = false

	triggerEvent('Play Animation', 'talking', 'Dad')

	setProperty('boyfriend.alpha', 0)
	setProperty('chloeListen.visible', true)
	playAnim('chloeListen', 'intro',true)
	runTimer('playListen', 1.4,1);

end

function letterBoxOutJasmineEnds() 

	doTweenY('clip1Move', 'clipTop', -100, 1, 'smootherStepIn')
	doTweenY('clip2Move', 'clipBottom', screenHeight + 100, 1, 'smootherStepIn')
	doTweenAlpha('welcomeBack', 'camHUD', 1, 1.5, 'backIn')
	
	triggerEvent('Play Animation', 'talkingends', 'Dad')

	playAnim('chloeListen', 'intro',true, true)
	runTimer('endListen', 1.1,1);

	followchars = true
end

function talkingUI()
	doTweenAlpha('textboxAppear', 'textbg', 1, 1, 'backIn')
	doTweenAlpha('textAppear', 'talk2', 1, 1.5, 'backIn')
end

function fuckyou() -- ending

	setProperty('chloeEnd.visible', true)
	setProperty('boyfriend.visible', false)
	objectPlayAnimation('chloeEnd', 'gang',true);

	doTweenAngle('intenseRotate', 'camGame', '6', 0.5, 'circOut')
	doTweenZoom('begin', 'camGame', '1.1', 0.5, 'CircOut')

	triggerEvent('Play Animation', 'end', 'Dad')

	runTimer('resetNshake', 1.8,1);

end

stepHitFuncs = { 

	
	[5] = function() --testing space

		
	end,

	[16] = function() --testing space

		if songName == 'rehearsal' then
			showTooltip("Press SPACE to skip forward through the yapping...", 3)
			canSpeedTalk = true
			usedSpeedUp = false
			letterBoxJasmineTalk();
			talkingUI();

			runTimer('chloeText', 10,1);
			runTimer('jasmineText', 15,1);
			
			setProperty(camX, 745);
			setProperty(camY, 520);
		end
		
	end,

	[72] = function() --testing space
		if songName == 'rehearsal' then
			setProperty(camX, 450);
			setProperty(camY, 590);
			
		end
	end,

	[99] = function() --testing space
		if songName == 'rehearsal' then
			setProperty(camX, 745);
			setProperty(camY, 520);
		end
	end,

	[136] = function() --testing space
		if songName == 'rehearsal' then
			letterBoxOutJasmineEnds();
			runTimer('resetUI', 0.5,1);
		end
	end,

	[272] = function() --testing space
		if songName == 'rehearsal' then
			showTooltip("You can skip here too with SPACE... you monster, skipping through VERY IMPORTANT dialogue.", 4)
			canSpeedTalk = true
			usedSpeedUp = false
			talkSpeedBoost = 3
			letterBoxJasmineTalk();
			talkingUI();

			setProperty(camX, 745);
			setProperty(camY, 520);

			if misses >= 1 and misses <= 3 then 
				setTextString('talk2', 'Not bad girl. Your aim was a bit off, but you got the hang of it. Now let’s shoot and singing!')
			elseif misses >= 4 and misses <= 6 then 
				setTextString('talk2', 'Oh Jesus, I know you grew up in the burbs... it’s okay, now we’re gonna try shooting and singing!')
			elseif misses > 7 then
				setTextString('talk2', 'I don’t even know what to say. Did you even try? Let’s uhh... try shooting and singing. Can you handle that?')
			else
				setTextString('talk2', 'Damn girl, you’re a natural! You’re doing perfect! Now we’re gonna use your voice AND shoot at the same time!')
			end
			objectPlayAnimation('textbg', 'jasmine',true);

			runTimer('chloeText2', 6.5,1);
		end
		
	end,

	[304] = function() ------------------------------ END OF TALKING -------------------------------------
		if songName == 'rehearsal' then
			setProperty(camY, 450);
			setProperty(camX, 590);

			runTimer('resetUI', 3,1);
			runTimer('chloespeaks', 3,1);
		end
	end,

	[473] = function() ------------------------------ GANGSTA ---------------------------------------------
		if songName == 'rehearsal' then
			playSound('REHEARSAL/fuckYou', 1, 'ending')
		end

	end,

	[472] = function() ------------------------------ GANGSTA ---------------------------------------------
		if songName == 'rehearsal' then
			fuckyou()
			letterBox()
		end

	end,


}

function onStepHit()
	if stepHitFuncs[curStep] then
		stepHitFuncs[curStep]()
	end

end

function onTimerCompleted(tag, loops, loopsLeft)

	if tag == 'playListen' then
		
		playAnim('chloeListen', 'listen',true)
	
	end
	if tag == 'endListen' then
		setProperty('boyfriend.alpha', 1)
		setProperty('chloeListen.visible', false)

	end

	if tag == 'panDown' then
		followchars = true
		setProperty('cameraSpeed', 0.35)
		--setProperty('defaultCamZoom',0.9)

	end

	
	if tag == 'resetSpeed' then
		setProperty('cameraSpeed', 1)

	end

	if tag == 'chloeText' then
		setTextString('talk2', 'Uhh..okay I got it. I think I’m ready... Wait, where’s YOUR protection??')
		objectPlayAnimation('textbg', 'chloe',true);

		 --72 is the curStep
	end

	if tag == 'jasmineText' then
		setTextString('talk2', 'Girl I grew up in the ghetto parts of Brooklyn, these gunshots are practically lullabies to me.')
		objectPlayAnimation('textbg', 'jasmine',true);
	end

	if tag == 'chloeText2' then

		if misses > 6 then
			setTextString('talk2', 'Yes! Yes! I can! I was just dozing off there, heh... get it together chloe...')
		elseif misses > 3 then
			setTextString('talk2', 'What the freak? How did you know? I gotta do better, let’s do this.')
		elseif misses > 1 then
			setTextString('talk2', 'Oof, I’m getting there. C’mon, let’s do this.')
		else
			setTextString('talk2', 'Yeaah! This feels pretty cool! C’mon, let’s do this.')
		end

		objectPlayAnimation('textbg', 'chloe',true);

	end

	
	if tag == 'chloespeaks' then

		letterBoxOutJasmineEnds();
	end
	------------------------------------------ TALKING HAPPENS HERE -----------------------------------------------------

	if tag == 'resetUI' then
		doTweenAlpha('textboxAppear', 'textbg', 0, 1.5, 'backIn')
		doTweenAlpha('textAppear', 'talk2', 0, 1, 'backIn')

		canSpeedTalk = false
		setProperty('playbackRate', normalSpeed)
	end
	

	------------------------------------------ ENDING WHEN SHE POPS OFF -----------------------------------------------------
	if tag == 'resetNshake' then
		doTweenAngle('backToNormal', 'camGame', '0', 4, 'smootherStepInOut')
		doTweenZoom('begin', 'camGame', '0.95', 4, 'smootherStepInOut')
		cameraShake('camGame', 0.003, 3)

		setProperty(camX, 430);
		setProperty(camY, 570);
		followchars = false
	end

	--tooltips
	if tag == 'tooltipHide' then
		doTweenAlpha('tooltipBG_out',  'tooltipBG',  0.0, 0.25, 'quadIn')
		doTweenAlpha('tooltipText_out','tooltipText',0.0, 0.25, 'quadIn')
   end

end

function onPause()
	pauseSound('ending')
	return Function_Continue;
end

function onResume()
	resumeSound('ending')
end

function letterBox(duration) 
	doTweenY('clip1Move', 'clipTop', 0, duration, 'smootherStepIn')
	doTweenY('clip2Move', 'clipBottom', screenHeight - 50, duration, 'smootherStepIn')
	doTweenAlpha('byebye', 'camHUD', 0, 0.5, 'backIn')
end
function letterBoxOut(duration) 
	doTweenY('clip1Move', 'clipTop', -80, duration, 'smootherStepIn')
	doTweenY('clip2Move', 'clipBottom', screenHeight, duration, 'smootherStepIn')
	doTweenAlpha('hellohello', 'camHUD', duration, 0.5, 'circOut')
end

function onGameOver()
	return Function_Stop;
end

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