local baseFPS = 144

local xx, yy = 590, 250;
local xx2, yy2 = 750, 430; -- bf
local xx3, yy3 = 560, 170;
local ofs, ofs2 = 15, 35;

local followchars, del, del2, i = true, 0, 0, 0; 
local allowCountdown, uhohEnd, mustZoomIn, wtfIntro, doDialogue, doIntro = false, true, false, true, false, false;

local stage = 'stages/week2/UHOH/'
local fog = 'stages/week3/stripClub/'
local hud = 'stages/hudelements/4-hudShit/'

local windowX, windowY = nil, nil
local returnToCenter = false

local zoomNum, zoomSpeed = 0.8, 1
local forceCam = false

local shakeDuration, shakeTime, shakeStrength, doShake = 0, 0, 0, false
local blurAlpha, blurActive = 1, false

local lightColor = getColorFromHex('f967c0')  

function onStartCountdown()


	if isStoryMode and songName == 'uhoh' then
		
		if not allowCountdown and not seenCutscene then --Block the first countdown
			startVideo('insane');
			allowCountdown = true;
			doDialogue = true;
			return Function_Stop;
	
		elseif doDialogue and not censored then

			setProperty('inCutscene', true);
			startDialogue('uhohShit', 'dialogueMusic/uhohDia') 
			doDialogue = false
			
			return Function_Stop
		elseif doDialogue and censored then
	
			setProperty('inCutscene', true);
			startDialogue('uhohCensored', 'dialogueMusic/uhohDia') 
			doDialogue = false
			return Function_Stop
		end
		return Function_Continue
	end

	if doIntro then
		if songName == 'uhoh' and not isStoryMode then
			if not allowCountdown then
				return Function_Stop
			end

			if allowCountdown and songName == 'uhoh' and not isStoryMode  then
				return Function_Continue
			end
		end
	end
	
end

function onSongStart()
	cameraFlash('camGame', 'FFFFFF', 1, false)
end

function onCreatePost() 
	if doIntro then
		if not isStoryMode then

			zoomNum = 1.1
			zoomSpeed = 2

			setProperty('cameraSpeed', 2)

			setProperty(camX, 560);
			setProperty(camY, -500);

			if not enableLights then
				setProperty('light2.alpha', 0)
			end
			setProperty('camHUD.alpha', 0)

			runTimer('panDown', 2.5,1);
			runTimer('fuckingOff', 2.5,1);
			runTimer('screamPrep', 4.9,1);
			runTimer('introRemove', 0.5,1);

			letterBox(2,2)

		end
	else
		followchars = true
		forceCam = false
		mustZoomIn = true
	end

	precacheImage(stage..'ENDING/KILLNOVA')
	precacheImage(stage..'ENDING/NOVADYING')
	precacheImage(stage..'ENDING/PICOLOL')
end

function onCreate()

	--cameraShit
	camX = 'camFollow.x';	
	camY = 'camFollow.y';

	setPropertyFromClass('substates.GameOverSubstate', 'characterName', 'uhoh-nova-death'); --Character json file for the death 
	setPropertyFromClass('substates.GameOverSubstate', 'deathSoundName', 'DEATH/novaDeath'); --put in mods/sounds/

	makeLuaSprite('wall', stage..'BG', -700, 250);
	setScrollFactor('wall', 0.55, 0.7);
	addLuaSprite('wall', false);
	scaleObject('wall', '1.2','1.2');

-- AD BILLBOARDS 
	if not lowQuality then 
		makeAnimatedLuaSprite('backAdvert2', stage..'BILL TOGETHER', -650,-500)	
		addAnimationByPrefix('backAdvert2', 'full', 'billTogether',0,true)
		addAnimationByPrefix('backAdvert2', 'broke', 'billTogether',24,false)
		addLuaSprite('backAdvert2',false)
		setScrollFactor('backAdvert2', 0.55, 0.7);
		objectPlayAnimation('backAdvert2', 'full',true)

		makeAnimatedLuaSprite('advert', stage..'TWO BILL', -550,-160)
		addAnimationByPrefix('advert', 'full', 'twoBill',0,true)
		addAnimationByPrefix('advert', 'broke', 'twoBill',24,false)
		addLuaSprite('advert',false)
		setScrollFactor('advert', 0.55, 0.7);
		objectPlayAnimation('advert', 'full',true)
		
		makeAnimatedLuaSprite('backAdvert', stage..'CIRCLE BILL', 350,-500)	
		addAnimationByPrefix('backAdvert', 'full', 'circleBill',0,true)
		addAnimationByPrefix('backAdvert', 'broke', 'circleBill',24,false)
		addLuaSprite('backAdvert',false)
		setScrollFactor('backAdvert', 0.55, 0.7);
		objectPlayAnimation('backAdvert', 'full',true)

		makeAnimatedLuaSprite('advertside', stage..'BILL 5', 900,-400)	
		addAnimationByPrefix('advertside', 'full', 'bill5',0,true)
		addAnimationByPrefix('advertside', 'broke', 'bill5',24,false)
		addLuaSprite('advertside',false)
		setScrollFactor('advertside', 0.55, 0.7);
		objectPlayAnimation('advertside', 'full',true)

		makeAnimatedLuaSprite('advert3', stage..'CURVED BILL', 1000,-100)	
		addAnimationByPrefix('advert3', 'full', 'curvedBill',0,true)
		addAnimationByPrefix('advert3', 'broke', 'curvedBill',24,false)
		addLuaSprite('advert3',false)
		setScrollFactor('advert3', 0.55, 0.7);
		objectPlayAnimation('advert3', 'full',true)

		makeAnimatedLuaSprite('advert2', stage..'MIDDLE BILL', 250,-150)	
		addAnimationByPrefix('advert2', 'full', 'middleBill',0,true)
		addAnimationByPrefix('advert2', 'broke', 'middleBill',24,false)
		addLuaSprite('advert2',false)
		setScrollFactor('advert2', 0.55, 0.7);
		objectPlayAnimation('advert2', 'full',true)

		setProperty('advert2.x', getProperty('advert2.x') + 200)
		setProperty('advert3.x', getProperty('advert3.x') + 200)
		setProperty('advertside.x', getProperty('advertside.x') + 200)
		setProperty('backAdvert.x', getProperty('backAdvert.x') + 200)
		setProperty('advert.x', getProperty('advert.x') + 200)
		setProperty('backAdvert2.x', getProperty('backAdvert2.x') + 200)
	end
--

	makeAnimatedLuaSprite('pico', stage..'ENDING/PICOLOL', 150 + 300, 170)	
	addAnimationByPrefix('pico', 'pullup', 'PICO0', 22, false)
	setScrollFactor('pico', 0.9, 0.9);
	setProperty('pico.visible', false)
	addLuaSprite('pico',false)
	
	makeLuaSprite('floor', stage..'GROUND', -750, 180);
	setScrollFactor('floor', 0.9,0.9);
	addLuaSprite('floor', false);
	scaleObject('floor', '1.3','1.1');

	if not lowQuality then

		makeLuaSprite('deadBody', stage..'JAYLADEAD', 950, 650);
		setScrollFactor('deadBody', 1,0.9);
		addLuaSprite('deadBody', false);
		scaleObject('deadBody', '1','1');

		makeLuaSprite('deadBody2', stage..'MANDYDEAD', -450, 700);
		setScrollFactor('deadBody2', 1,0.9);
		addLuaSprite('deadBody2', false);
		scaleObject('deadBody2', '1','1');

		makeLuaSprite('groundLight', stage..'lights', 200, 100);
		setScrollFactor('groundLight', 0.9, 0.9);
		addLuaSprite('groundLight', false);
		scaleObject('groundLight', '1','1');
		setBlendMode('groundLight', 'SCREEN')
		setObjectOrder('groundLight', 13)

		makeLuaSprite('fog1', fog..'TEST/FOG-1', 500, 450);
		setScrollFactor('fog1', 1.1, 1.3);
		addLuaSprite('fog1', true);
		scaleObject('fog1', '1.1','1.1');
		setProperty('fog1.alpha', 0.4)
		setBlendMode('fog1', 'SCREEN')
		setProperty('fog1.x', -screenWidth - (getProperty('fog1.width')/2))

		makeLuaSprite('fog2', fog..'TEST/FOG-2', 0, 550);
		setScrollFactor('fog2', 1.3, 1.2);
		addLuaSprite('fog2', true);
		scaleObject('fog2', '1.8','1.4');
		setBlendMode('fog2', 'SCREEN')
		setProperty('fog2.alpha', 0.3)
		setProperty('fog2.x', -screenWidth - (getProperty('fog2.width')/4))

		

		fogColor = getColorFromHex('FF6699') 
		fogColor2 = getColorFromHex('f49afc')

	

		makeLuaSprite('rubble', stage..'FG RUBBLE', -880, 700);
		setScrollFactor('rubble', 1.5, 1.7);
		scaleObject('rubble', '1.3','1.4');
		addLuaSprite('rubble', true);
		scaleObject('rubble', '1','1');

		makeLuaSprite('rubble2', stage..'FG RUBBLE', 1050, 700);
		setScrollFactor('rubble2', 1.5, 1.7);
		scaleObject('rubble2', '1.2','1.2');
		addLuaSprite('rubble2', true);
		scaleObject('rubble2', '1','1');

		makeLuaSprite('fog3', fog..'TEST/FOG-3', 800, 50);
		setScrollFactor('fog3', 1.1, 1.3);
		addLuaSprite('fog3', true);
		scaleObject('fog3', '1.6','1.5');
		setBlendMode('fog3', 'SCREEN')
		setProperty('fog3.x', -screenWidth + (getProperty('fog3.width')/2))

		setProperty('floor.x', getProperty('floor.x') + 100)
		setProperty('deadBody.x', getProperty('deadBody.x') + 100)
		setProperty('deadBody2.x', getProperty('deadBody2.x') + 100)
		setProperty('groundLight.x', getProperty('groundLight.x') + 100)

		setProperty('fog1.color', fogColor)
		setProperty('fog2.color', fogColor)
		setProperty('fog3.color', fogColor2)

		speed1 = '0.3'
		speed2 = '0.5'
		speed3 = '0.4'
	end

-- UI SHIT

	if not lowQuality then
		makeLuaSprite('screamVin', stage..'bloody', 0, 0);
		setScrollFactor('screamVin', 0.9, 0.9);
		addLuaSprite('screamVin', false);
		scaleObject('screamVin', '2','1.4');
		setProperty('screamVin.alpha', 0)
		setObjectCamera('screamVin', 'other')
		setObjectOrder('screamVin', 1)
	end

	if not enableLights then
		makeLuaSprite('light2', hud..'LIGHTTEST', -500, -100);
		setScrollFactor('light2', 0, 0);
		addLuaSprite('light2', true);
		scaleObject('light2', '1.5','1');
		setBlendMode('light2', 'SCREEN')
		setProperty('light2.color', lightColor)
	end

	makeLuaSprite('tint', '', 0, 0);
	setScrollFactor('tint', 0, 0);
	addLuaSprite('tint', true);
	scaleObject('tint', '1.3','1.3');
	setProperty('tint.alpha', 0.1)
	makeGraphic('tint', screenWidth, screenHeight, '87a5c7')

	makeLuaSprite('dark', '', 0, 0); -- for the ending
	setScrollFactor('dark', 1, 1);
	addLuaSprite('dark', false);
	scaleObject('dark', '1','1');
	makeGraphic('dark', screenWidth, screenHeight, '000000')
	setObjectCamera('dark', 'other')
	setProperty('dark.alpha', 0)

	makeLuaSprite('clipTop', '', 0, -50);
	setScrollFactor('clipTop', 1, 1);
	addLuaSprite('clipTop', false);
	scaleObject('clipTop', '1','1');
	makeGraphic('clipTop', screenWidth, 50, '000000')
	setObjectCamera('clipTop', 'other')

	makeLuaSprite('clipBottom', '', 0, screenHeight);
	setScrollFactor('clipBottom', 1, 1);
	addLuaSprite('clipBottom', false);
	scaleObject('clipBottom', '1','1');
	makeGraphic('clipBottom', screenWidth, 50, '000000')
	setObjectCamera('clipBottom', 'other')


end

function opponentNoteHit(id, direction, noteType, isSustainNote)
	
	health = getProperty('health')
	if getProperty('health') > 0.2 then
		setProperty('health', getProperty('health')-0.025);
	end
end


function onUpdate(elapsed)

	--CAMERA ZOOMS, CUR STEPS
	if mustZoomIn then
		if curStep < 1135 and songName == 'uhoh' then
			if mustHitSection == false  then
				setProperty('defaultCamZoom',1.1)
				doTweenZoom('hellowee', 'camGame', '1.1', 0.5, 'quadIn') -- 1
			else
				doTweenZoom('hellowee2', 'camGame', '0.8', 0.5, 'backOut') 
				setProperty('defaultCamZoom',0.8)
			end
		end
	else
		doTweenZoom('hellowee2', 'camGame', zoomNum, zoomSpeed, 'backOut') 
		setProperty('defaultCamZoom', zoomNum)
	end

	setProperty('gf.alpha', 0)
	setProperty('boyfriend.scale.x', 1.5)
	setProperty('boyfriend.scale.y', 1.5)

	if curStep  >= 1131  and curStep  < 1186 then -- add 55
		setProperty('stephKill.y', (math.sin(i/55)*75) - 50)
	end

	--MOVE WINDOW BACK
	if returningToCenter and canMoveWindow() then
        local curX = getPropertyFromClass('openfl.Lib', 'application.window.x')
        local curY = getPropertyFromClass('openfl.Lib', 'application.window.y')

        local speed = 3
        local t = math.min(elapsed * speed, 0.4)

        local nx = curX + (windowX - curX) * t
        local ny = curY + (windowY - curY) * t

        setPropertyFromClass('openfl.Lib', 'application.window.x', nx)
        setPropertyFromClass('openfl.Lib', 'application.window.y', ny)

        if math.abs(nx - windowX) < 0.5 and math.abs(ny - windowY) < 0.5 then
            setPropertyFromClass('openfl.Lib', 'application.window.x', windowX)
            setPropertyFromClass('openfl.Lib', 'application.window.y', windowY)
            returningToCenter = false
        end
    end

	-- FLYING STEPHANIE
	if curStep >= 0 and curStep < 1131 then
	 	setProperty('dad.y', (math.sin(i/35)*75) + 100)
		yy = (math.sin(i/35)*75) + 100
  	end

	if not enableLights then
		setObjectOrder('light2', 20)
	end

	setProperty('dad.scrollFactor.x', 0.9);
	setProperty('dad.scrollFactor.y', 0.9);
	setProperty('boyfriend.scrollFactor.x', 1.4);
	setProperty('boyfriend.scrollFactor.y', 1.4);

	daElapsed = elapsed * 30
	i = i + daElapsed

	if del > 0 then
		del = del - 1
	end
	if del2 > 0 then
		del2 = del2 - 1
	end

	if forceCam then
		local cx = getProperty('camFollow.x')
		local cy = getProperty('camFollow.y')

		local t = math.min(1, elapsed * 6)
		setProperty('camFollow.x', cx + (camX - cx) * t)
		setProperty('camFollow.y', cy + (camY - cy) * t)

		triggerEvent('Camera Follow Pos', tostring(camX), tostring(camY))

	elseif followchars == true then
		if mustHitSection == false and curStep > 0 and curStep < 1131 then
			if getProperty('dad.animation.curAnim.name') == 'singLEFT' then
				triggerEvent('Camera Follow Pos',xx - (ofs*2),yy)
			end
			if getProperty('dad.animation.curAnim.name') == 'singRIGHT' then
				triggerEvent('Camera Follow Pos',xx + (ofs*2),yy)
			end
			if getProperty('dad.animation.curAnim.name') == 'singUP' then
				triggerEvent('Camera Follow Pos',xx,yy-ofs-25)
			end
			if getProperty('dad.animation.curAnim.name') == 'singDOWN' then
				triggerEvent('Camera Follow Pos',xx,yy + (ofs*3))
			end
			
			if getProperty('dad.animation.curAnim.name') == 'idle' then
				triggerEvent('Camera Follow Pos',xx,yy)
			end
		
		else
			
			if getProperty('boyfriend.animation.curAnim.name') == 'singLEFT' then
				triggerEvent('Camera Follow Pos',xx2-ofs2,yy2)
			end
			if getProperty('boyfriend.animation.curAnim.name') == 'LEFTshoot' then
				triggerEvent('Camera Follow Pos',xx2-ofs2,yy2)
			end
			if getProperty('boyfriend.animation.curAnim.name') == 'singRIGHT' then
				triggerEvent('Camera Follow Pos',xx2+ofs2,yy2)
			end
			if getProperty('boyfriend.animation.curAnim.name') == 'RIGHTshoot' then
				triggerEvent('Camera Follow Pos',xx2+ofs2,yy2)
			end
			if getProperty('boyfriend.animation.curAnim.name') == 'singUP' then
				triggerEvent('Camera Follow Pos',xx2,yy2-ofs2)
			end
			if getProperty('boyfriend.animation.curAnim.name') == 'UPshoot' then
				triggerEvent('Camera Follow Pos',xx2,yy2-ofs2)
			end
			if getProperty('boyfriend.animation.curAnim.name') == 'singDOWN' then
				triggerEvent('Camera Follow Pos',xx2,yy2+ofs2)
			end
			if getProperty('boyfriend.animation.curAnim.name') == 'DOWNshoot' then
				triggerEvent('Camera Follow Pos',xx2,yy2+ofs2)
			end
			if getProperty('boyfriend.animation.curAnim.name') == 'singRIGHT-alt' then
				triggerEvent('Camera Follow Pos',xx2+ofs2,yy2)
			end
			if getProperty('boyfriend.animation.curAnim.name') == 'singUP-alt' then
				triggerEvent('Camera Follow Pos',xx2,yy2-ofs2)
			end
			if getProperty('boyfriend.animation.curAnim.name') == 'singDOWN-alt' then
				triggerEvent('Camera Follow Pos',xx2,yy2+ofs2)
			end
			if getProperty('boyfriend.animation.curAnim.name') == 'idle-alt' then
				triggerEvent('Camera Follow Pos',xx2,yy2)
			end
		end
	else
		triggerEvent('Camera Follow Pos','','') -- self explanatory
	end
	

	if followchars == true and curStep >= 1131 and curStep < 1196 then
		triggerEvent('Camera Follow Pos',xx3,yy3)
	end

	if blurActive then
		blurAlpha = blurAlpha - (elapsed * 0.7) -- how fast it fades out

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
		local falloff = 1 - progress

		local offsetX = math.sin(os.clock() * 20) * shakeStrength * falloff
		local offsetY = math.cos(os.clock() * 25) * shakeStrength * falloff

		setProperty('camGame.x', offsetX)
		setProperty('camGame.y', offsetY)

		if shakeTime <= 0 then
			setProperty('camGame.x', 0)
			setProperty('camGame.y', 0)
		end
	end

	-- fog
	setProperty('fog1.x', (getProperty('fog1.x') + (speed2 * baseFPS * elapsed)))
	setProperty('fog2.x', (getProperty('fog2.x') + (speed1 * baseFPS * elapsed)))
	setProperty('fog3.x', (getProperty('fog3.x') + (speed3 * baseFPS * elapsed)))

	if getProperty('fog1.x') > 1720 then
		setProperty('fog1.x', -800 - getProperty('fog1.width'))
	end
	if getProperty('fog2.x') > 1720 then
		setProperty('fog2.x', -500 - getProperty('fog2.width'))
	end
	if getProperty('fog3.x') > 1720 then
		setProperty('fog3.x', -500 - getProperty('fog3.width'))
	end
end

function onCountdownStarted()
	if songName == 'uhoh' and isStoryMode then
		doTweenAlpha('comeBackLight1', 'light2', 1, 0.5, 'backIn')
	end
end

function endingShit()

	cameraFlash('camGame', 'FFFFFF', 1, false)

	makeAnimatedLuaSprite('stephKill', stage..'ENDING/KILLNOVA', 110,-100)	
	addAnimationByPrefix('stephKill', 'die', 'CHOKE0',22,false)
	setScrollFactor('stephKill', 0.9, 0.9);

	makeAnimatedLuaSprite('angelo', stage..'ENDING/NOVADYING', 500,130)	
	addAnimationByPrefix('angelo', 'ohno', 'angeloCHOKE0',22,false)
	scaleObject('angelo', '1.3','1.3');
	setScrollFactor('angelo', 0.9, 0.9);
	setObjectOrder('angelo', 18)

	setProperty('dad.alpha', 0)
	setProperty('boyfriend.alpha', 0)

	playAnim('stephKill', 'die',true, false, 1)
	playAnim('angelo', 'ohno',true, false, 1)

	addLuaSprite('stephKill',false)
	addLuaSprite('angelo',false)
	
	doTweenColor('shartDark', 'screamVin', '000000', 5, 'smootherStepIn')
	doTweenAlpha('view', 'screamVin', 1, 5, 'smootherStepIn')
	doTweenAlpha('view2', 'dark', 0.7, 5, 'smootherStepIn')

	doTweenY('raise', 'angelo', -50, 4, 'smootherStepInOut')
	
	runTimer('darkAway', 5.1,1); -- pico pulls up
	runTimer('zoomslow', 1,1);

	letterBox(2,2)


end

stepHitFuncs = { 

	[783] = function() -- angelo chuckle
		mustZoomIn = false
		followchars = false
		forceCam = true

		doTweenZoom('watchThis', 'camGame', '0.9', 1, 'quadOut')
		setProperty('defaultCamZoom',0.9)

		triggerEvent('Play Animation', 'LOL', 'BF')

		setProperty(camX, 630);
		setProperty(camY, 450);

		
	end,

	[800] = function() -- chuckle end
		followchars = true
		forceCam = false
		mustZoomIn = true
	end,

	[864] = function() -- confused animation
		followchars = false
		forceCam = true
		mustZoomIn = false;
		zoomNum = 1.1
		zoomSpeed = 3

		triggerEvent('Play Animation', 'CONFUSED', 'Dad')

		setProperty(camX, 530);
		setProperty(camY, 100);

		runTimer('zoomEnable', 3,1);
	end,

	[895] = function() -- confused animation end
		followchars = true
		forceCam = false
	end,

	[976] = function() -- sir yap a lot
		followchars = false
		forceCam = true
		mustZoomIn = false;
		zoomNum = 1.1
		zoomSpeed = 3

		triggerEvent('Play Animation', 'ANNOYED', 'Dad')

		setProperty(camX, 530);
		setProperty(camY, 100);

		
		runTimer('zoomEnable', 4,1);
	end,

	[1020] = function() -- yap end
		followchars = true
		forceCam = false
	end,
 
	[1131] = function() --testing space
		mustZoomIn = false;
		zoomNum = 1.2
		zoomSpeed = 1

		setProperty('cameraSpeed', 0.25)
		endingShit()
		playSound('UHOH/uhohEnd', 1, 'ending')
	end,

	[1196] = function() --pico
		followchars = false
		forceCam = true
		zoomNum = 1.4
		zoomSpeed = 1

		setProperty('cameraSpeed', 0.8)

		doTweenX('moveSte', 'stephKill', 900, 1.5, 'smootherStepInOut')
		doTweenY('moveSte2', 'stephKill', -300, 1.5, 'smootherStepInOut')

		setProperty(camX, 300);
		setProperty(camY, 500);
		
		runTimer('picoPanUp', 3,1);
		runTimer('picoPanDown', 6,1);

	end,

	[1253] = function() --ending
		
	end,
}

function onStepHit()
	if stepHitFuncs[curStep] then
		stepHitFuncs[curStep]()
	end

end


function onTweenCompleted(tag, loops, loopsLeft)
	if tag == 'screamVinLeave' then
		removeLuaSprite('screamVin', true)
	end
end

function onTimerCompleted(tag, loops, loopsLeft)
	if tag == 'zoomEnable' then
		mustZoomIn = true;
	end

	if tag == 'zoomslow' then
		zoomNum = 1.5
		zoomSpeed = 4
	end
	if tag == 'panDown' then
	
		forceCam = true
		followchars = false

		setProperty(camY, 170);
		setProperty('cameraSpeed', 0.25)
		setProperty('defaultCamZoom',0.8)
		runTimer('gameStart', 5.5,1);

	end
	if tag == 'fuckingOff' then
		triggerEvent('Play Animation', 'SCREAM', 'Dad')
		doTweenZoom('ohshit', 'camGame', '1.1', 2.5, 'circIn')
	end

	if tag == 'windowShakee' and canMoveWindow() then
		if loopsLeft >= 0 then
			if loopsLeft > 0 then
				local ax = getVar('shake_ampX')
				local ay = getVar('shake_ampY')
				local nx = windowX + math.random(-ax, ax)
				local ny = windowY + math.random(-ay, ay)
				setPropertyFromClass('openfl.Lib', 'application.window.x', nx)
				setPropertyFromClass('openfl.Lib', 'application.window.y', ny)
			else
				returningToCenter = true -- start easing back
			end
		end
	end

	if tag == 'screamPrep' then
		doTweenZoom('ohshit2', 'camGame', '0.9', 1, 'circOut')
		cameraShake('camGame', 0.006, 1)
		doTweenAlpha('screamVinShow', 'screamVin', 1, 0.5, 'backOut')
		
		runTimer('screamRotate', 1,1);
	
		windowShake(30, 0.02, 12, 12)

		objectPlayAnimation('backAdvert2', 'broke',true)
		objectPlayAnimation('advert', 'broke',true)
		objectPlayAnimation('backAdvert', 'broke',true)
		objectPlayAnimation('advert3', 'broke',true)
		objectPlayAnimation('advert2', 'broke',true)
		objectPlayAnimation('advertside', 'broke',true)

	end

	if tag == 'screamRotate' then
		doTweenAlpha('screamVinLeave', 'screamVin', 0, 2, 'smootherStepOut')
	end
	
	if tag == 'gameStart' then

		allowCountdown = true
		forceCam = false
		followchars = true
		mustZoomIn = true

		setProperty('cameraSpeed', 0.9)
		
		letterBoxOut(1,2)
		startCountdown()
	end

	if tag == 'introRemove' then
		doTweenAlpha('getyoass', 'introHide', 0, 0.5, 'backIn')
		
		playSound('UHOH/uhohIntro', 0.9, 'intro')
		doTweenAlpha('lightcomeback', 'light2', 1, 2, 'backIn')
	end

	if tag == 'darkAway' then
		doTweenAlpha('view', 'dark', 0, 0.3, 'smootherStepIn')
		doTweenAlpha('view2', 'screamVin', 0, 0.3, 'smootherStepIn')
		doTweenZoom('zoominslow', 'camGame', '1.3', 0.3, 'backOut')

		setProperty('pico.visible', true)
		playAnim('pico', 'pullup',true, false, 90)

		startSmoothShake(5, 1)
		triggerBlur()
		doTweenX('movePico', 'pico', 150, 3, 'quadOut')
	end

	if tag == 'picoPanUp' then
		setProperty(camY, 450);
		runTimer('picoSlamShake', 2,1);
	end

	if tag == 'picoSlamShake' then
	
	end

	if tag == 'picoPanDown' then
		setProperty('cameraSpeed', 0.3)
		setProperty(camY, 670);

		runTimer('endSong', 5,1);

		doTweenAlpha('fadeOut', 'dark', 1, 3, 'smootherStepIn')
	end

	if tag == 'endSong' then
		endSong()
	end


end

function letterBox(duration,time) 
	doTweenY('clip1Move', 'clipTop', 0, duration, 'smootherStepIn')
	doTweenY('clip2Move', 'clipBottom', screenHeight - 50, duration, 'smootherStepIn')
	doTweenAlpha('byebye', 'camHUD', 0, time, 'backIn')
end
function letterBoxOut(duration,time) 
	doTweenY('clip1Move', 'clipTop', -50, duration, 'smootherStepIn')
	doTweenY('clip2Move', 'clipBottom', screenHeight, duration, 'smootherStepIn')
	doTweenAlpha('hellohello', 'camHUD', 1, time, 'circOut')
end

function canMoveWindow()
	return not getPropertyFromClass('flixel.FlxG', 'fullscreen')
end

function windowShake(shakes, step, ampX, ampY)

	if not canMoveWindow() then return end

	windowX = getPropertyFromClass('openfl.Lib', 'application.window.x') or 0
	windowY = getPropertyFromClass('openfl.Lib', 'application.window.y') or 0

	setVar('shake_ampX', ampX or 6)
	setVar('shake_ampY', ampY or 6)

	runTimer('windowShakee', step or 0.02, shakes or 30)

	returnToCenter = false

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

function onPause()
	pauseSound('intro')
	pauseSound('ending')
	return Function_Continue;
end

function onResume()
	resumeSound('intro')
	resumeSound('ending')
end

