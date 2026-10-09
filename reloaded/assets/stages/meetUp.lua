local lightColor = getColorFromHex('42C1D6')  

local fog = 'stages/week3/stripClub/TEST/'
local stage = 'stages/week3/car-meet/'
local stagePeeps = 'stages/week3/car-meet/PEEPS/'
local hud = 'stages/hudelements/4-hudShit/'
local sounds = 'WEEK2/'

local xx, yy = 580, 530; -- lucy
local xx2, yy2 = 750, 535; -- jasmine
local ofs, ofs2 = 15, 35;
local i = 0;

local followchars, forceCam = false, false;

local doIntro = true
local allowCountdown, doDialogue, doZoom, doIntroPan, doCenterPan, stayCentered = false, true, false, false, false, false;
local scaleXPeeps, scaleYPeeps, scrollXPeeps, scrollYPeeps = 0.9, 0.9, 0.60, 0.9

--TIME
simulatedHour = 6
simulatedTimer = 0
simulatedSpeed = 3-- seconds in game = 1 hour

--FLASHES
local flashPaths = {
    'stages/week3/car-meet/FLASHES/flash1',
    'stages/week3/car-meet/FLASHES/flash2',
    'stages/week3/car-meet/FLASHES/flash3'
}

local flashesEnabled = false
local flashSpawnTag, flashSpawnRate, flashMaxAlive, flashFadeTime, flashScaleMin, flashScaleMax, flashAlphaMin, flashAlphaMax = 'crowdFlashSpawn', 0.10,14, 0.22,1.25, 1.55, 0.9, 1
local hudPopChance, hudPopAlphaMin, hudPopAlphaMax, hudPopFadeTime = 15, 0.08, 0.24, 0.22
local burstChance, burstExtraSpawns = 12, 2
local flashAlive, flashId = 0, 0

--CUSTOM FUNCTIONS
local shakeDuration, shakeTime, shakeStrength, doShake = 0, 0, 0, false
local blurAlpha, blurActive = 1 , false

--VOICE CRACK
local strumDefaultX = {}
local strumDefaultY = {}
local strumCached = false


function onStartCountdown()

	if isStoryMode then
		if not allowCountdown and songName == 'rude' then
			if doDialogue and not seenCutscene then
				setProperty('inCutscene', true);
				startDialogue('rudeShit', 'dialogueMusic/rudeDia')  
				doDialogue = false
				return Function_Stop
			end
			return Function_Continue
		end
	end

end

function onSongStart()
	for i = 0, 7 do
		strumDefaultX[i] = getPropertyFromGroup('strumLineNotes', i, 'x')
		strumDefaultY[i] = getPropertyFromGroup('strumLineNotes', i, 'y')
	end
	strumCached = true
end


function onCreatePost() 

	if not isStoryMode and doIntro and not seenCutscene then
		
		setProperty('defaultCamZoom',0.7)
		doTweenZoom('zoomIntro', 'camGame', '0.7', 0.5, 'quadOut')

		runTimer('introShow', 1, 1);
		runTimer('panDown', 2, 1);
		runTimer('introFade', 4, 1);
		runTimer('getOuttaHere', 3, 1);
		runTimer('gameStart', 5, 1);

		setProperty(camY, -100)
		setProperty(camX, 580)
	else
		followchars = true
		doZoom = true
	end

	makeLuaSprite('hudFlashPop', hud..'VIN', 20, 0)
	setProperty('hudFlashPop.scale.x', 0.95)
	setObjectCamera('hudFlashPop', 'camHUD')
	setProperty('hudFlashPop.alpha', 0)
	addLuaSprite('hudFlashPop', false)

	cacheStrums()

	if not lowQuality then
		precacheImage(stage..'crowdLow')
		precacheImage(stage..'SMOKE')
		precacheImage(stage..'CAR-1')
		precacheImage(stage..'CAR-2')
		precacheImage(stage..'lensflare')
		precacheImage(stagePeeps..'bop-1')
		precacheImage(stagePeeps..'bop-2')
		precacheImage(stagePeeps..'bop-3')
		precacheImage(stagePeeps..'bop-4')
		precacheImage(stagePeeps..'bop-5')
		precacheImage(stagePeeps..'bop-6')
		precacheImage(stagePeeps..'bop-7')
	end
end


function restoreRange(a, b, time, ease)
	time = time or 0.6
	ease = ease or 'cubeOut'
	for i = a, b do
		noteTweenX('vc_backX'..i, i, strumDefaultX[i], time, ease)
		noteTweenY('vc_backY'..i, i, strumDefaultY[i], time, ease)
	end
end

function jumbleRange(a, b, amount, time, ease)
	amount = amount or 80
	time = time or 0.15
	ease = ease or 'quadOut'
	for i = a, b do
		local rx = getRandomInt(-amount, amount)
		local ry = getRandomInt(-amount, amount)
		noteTweenX('vc_jumX'..i, i, strumDefaultX[i] + rx, time, ease)
		noteTweenY('vc_jumY'..i, i, strumDefaultY[i] + ry, time, ease)
	end
end

function voiceCrackFor(who, amount)
	
	if who == 'lucy' then
		jumbleRange(0, 3, amount)
		runTimer('vc_restore_opp', 1.0)
	else
		jumbleRange(4, 7, amount)
		runTimer('vc_restore_player', 1.0)
	end
end

function onCreate()

	camX = 'camFollow.x'
	camY = 'camFollow.y'

	setPropertyFromClass('substates.GameOverSubstate', 'characterName', 'death-jasmine');
	setPropertyFromClass('substates.GameOverSubstate', 'loopSoundName', 'DEATH/jasmineDeath');
	setPropertyFromClass('substates.GameOverSubstate', 'endSoundName', 'DEATH/jasmineConfirm');
	setPropertyFromClass('substates.GameOverSubstate', 'deathSoundName', 'DEATH/jasDeath');

	-- ASSETS
	makeLuaSprite('sky', '', 0, 0);
	setScrollFactor('sky', 0.2, 0.2);
	addLuaSprite('sky', false);
	scaleObject('sky', '1.3','1.3');
	makeGraphic('sky', screenWidth, screenHeight, 'FFFFFF')

	makeLuaSprite('clouds', stage..'CLOUDS', -100, 0);
	setScrollFactor('clouds', 0.3, 0.6);
	addLuaSprite('clouds', false);
	setProperty('clouds.alpha', 0.2)
	scaleObject('clouds', '0.8','0.8');

	makeLuaSprite('sun', stage..'SUN', -200, 100); -- x 50, y 100
	setScrollFactor('sun', 0.35, 0.8);
	addLuaSprite('sun', false);
	scaleObject('sun', '1','1');

	makeLuaSprite('moon', stage..'MOON', -500, 230);
	setScrollFactor('moon', 0.3, 0.8);
	addLuaSprite('moon', false);
	scaleObject('moon', '1','1');
	
	makeLuaSprite('city', stage..'bg2', -310, 20);
	setScrollFactor('city', 0.45, 0.9);
	addLuaSprite('city', false);

	makeLuaSprite('floor', stage..'ground', -350, 220);
	setScrollFactor('floor', 0.55,0.9);
	addLuaSprite('floor', false);
	scaleObject('floor', '1.1','1');

	makeLuaSprite('wall', stage..'bg', 500, 130); --50 y
	setScrollFactor('wall', 0.55, 0.9);
	scaleObject('wall', '1.05','0.9');
	addLuaSprite('wall', false);


	if not lowQuality then 

		makeLuaSprite('crowd', stage..'crowdLow', -350, 270); -- 200
		setScrollFactor('crowd', 0.65, 0.9);
		scaleObject('crowd', '0.8','0.8');
		addLuaSprite('crowd', false);

		makeAnimatedLuaSprite('gen', stagePeeps..'bop-1', 520, 300)
		addAnimationByPrefix('gen', 'dance', 'animatedPeeps',24,true)
		setScrollFactor('gen', scrollXPeeps, scrollYPeeps);
		scaleObject('gen', scaleXPeeps, scaleYPeeps);

		makeAnimatedLuaSprite('krip', stagePeeps..'bop-2', 1350, 300)
		addAnimationByPrefix('krip', 'dance', 'krip',24,true)
		setScrollFactor('krip', scrollXPeeps, scrollYPeeps);
		scaleObject('krip', scaleXPeeps, scaleYPeeps);

		makeAnimatedLuaSprite('stem', stagePeeps..'bop-4', 50, 290)
		addAnimationByPrefix('stem', 'dance', 'stem',24,true)
		setScrollFactor('stem', scrollXPeeps, scrollYPeeps);
		setProperty('stem.flipX', true);

		makeAnimatedLuaSprite('feline', stagePeeps..'bop-3', 160, 290)
		addAnimationByPrefix('feline', 'dance', 'feline',24,true)
		setScrollFactor('feline', scrollXPeeps, scrollYPeeps);
		scaleObject('feline', scaleXPeeps, scaleYPeeps);

		makeAnimatedLuaSprite('vi', stagePeeps..'bop-5', 480, 290)
		addAnimationByPrefix('vi', 'dance', 'vi',24,true)
		setScrollFactor('vi', scrollXPeeps, scrollYPeeps);
		scaleObject('vi', scaleXPeeps, scaleYPeeps);

		makeAnimatedLuaSprite('sari', stagePeeps..'bop-6', 1150, 280)
		addAnimationByPrefix('sari', 'dance', 'sar',24,true)
		setScrollFactor('sari', scrollXPeeps, scrollYPeeps);

		makeAnimatedLuaSprite('ping', stagePeeps..'bop-7', 880, 300)
		addAnimationByPrefix('ping', 'dance', 'pin',24,true)
		setScrollFactor('ping', scrollXPeeps, scrollYPeeps);
		scaleObject('ping', scaleXPeeps, scaleYPeeps);

		if not enableFog then
			fogColor = getColorFromHex('98DDE9') 
			fogColor2 = getColorFromHex('54A9B8')

			makeLuaSprite('fog2', fog..'FOG-2', 0, 750 - 500);
			setScrollFactor('fog2', 0.75, 1.1);
			scaleObject('fog2', '1.8','1.7');
			setBlendMode('fog2', 'SCREEN')
			setProperty('fog2.alpha', 0.4)
			setProperty('fog2.x', -screenWidth - (getProperty('fog2.width')/4))
			setProperty('fog2.color', fogColor)

			makeLuaSprite('fog1', fog..'FOG-1', 0, 650 - 200);
			setScrollFactor('fog1', 0.45, 0.9);
			scaleObject('fog1', '1.1','0.8');
			setProperty('fog1.alpha', 0.9);
			setBlendMode('fog1', 'SCREEN')

			makeLuaSprite('fog3', fog..'FOG-3', -700, 350 - 100);
			setScrollFactor('fog3', 1.7, 1.7);
			scaleObject('fog3', '1.2','1.3');
			setBlendMode('fog3', 'SCREEN')
			
			setProperty('fog1.color', fogColor)
			setProperty('fog3.color', fogColor2)

			speed1 = '0.2'
			speed2 = '0.3'
			speed3 = '0.1'

			makeAnimatedLuaSprite('smoke_1', stage..'SMOKE', 1050, 180)
			addAnimationByPrefix('smoke_1', 'steam', 'coffeeSmoke',24,true)
			setScrollFactor('smoke_1', 0.65, 0.9);
			setProperty('smoke_1.alpha', 0.4)
			scaleObject('smoke_1', '1.9','1.3');

			makeAnimatedLuaSprite('smoke-2', stage..'SMOKE', -50, 130)
			addAnimationByPrefix('smoke-2', 'steam', 'coffeeSmoke',28,true)
			setScrollFactor('smoke-2', 0.65, 0.9);
			setProperty('smoke-2.alpha', 0.4)
			scaleObject('smoke-2', '1.9','1.3');

			makeAnimatedLuaSprite('smoke-3', stage..'SMOKE', -1600, -450)
			addAnimationByPrefix('smoke-3', 'steam', 'coffeeSmoke',19,true)
			setScrollFactor('smoke-3', 3, 1.7);
			setProperty('smoke-3.alpha', 0.5)
			scaleObject('smoke-3', '9','7');
		end

		makeAnimatedLuaSprite('car', stage..'CAR-1', -130, 390)
		addAnimationByPrefix('car', 'idling', 'cars_2',18,true)
		setScrollFactor('car', 0.65, 0.9);
		
		makeAnimatedLuaSprite('car2', stage..'CAR-2', -300, 400)
		addAnimationByPrefix('car2', 'idling', 'car_1',18,true)
		setScrollFactor('car2', 0.65, 0.9);

		makeLuaSprite('fogFG', stage..'fogFG', -400, 300);
		setScrollFactor('fogFG', 0.7, 0.9);
		setProperty('fogFG.alpha', 1)
		scaleObject('fogFG', '1.2','1');
		setBlendMode('fogFG', 'SCREEN')

		makeLuaSprite('flare', stage..'lensflare', 50, 0);
		setScrollFactor('flare', 0.70, 0.9);
		scaleObject('flare', '1','1');
		setProperty('flare.alpha', 0.9)
		setBlendMode('flare', 'ADD')

		addLuaSprite('feline',false)
		addLuaSprite('vi',false)
		addLuaSprite('gen',false)
		addLuaSprite('ping',false)
		addLuaSprite('stem',false)
		addLuaSprite('sari',false)
		addLuaSprite('krip',false)
	
		if not enableFog then
			addLuaSprite('smoke-3',true)
			addLuaSprite('smoke-2',false)
			addLuaSprite('smoke_1',false)
		end
		addLuaSprite('car',false)
		addLuaSprite('car2',false)
		if not enableFog then
			addLuaSprite('fogFG', false);
			addLuaSprite('fog2', false);
			addLuaSprite('fog1', false);
			addLuaSprite('fog3', true);
		end

		addLuaSprite('flare', true);
	
		startCrowdFlashes(0.10, 12)
		
	end

	----------------
	-- HUD STUFF
	----------------
	makeLuaSprite('light', hud..'LIGHTTEST', -500, -100); -- -200
	setScrollFactor('light', 0, 0);
	addLuaSprite('light', true);
	scaleObject('light', '1.7','1');
	setBlendMode('light', 'SCREEN')
	setProperty('light.alpha', 0.5)
	setObjectOrder('light', 50)
	setProperty('light.color', lightColor)

	makeLuaSprite('overlay', '', -300, -100); -- for the time of day tint
	setScrollFactor('overlay', 0, 0);
	addLuaSprite('overlay', true);
	makeGraphic('overlay', screenWidth, screenHeight, 'FFFFFF')
	setProperty('overlay.alpha', 0.4)
	setBlendMode('overlay', 'MULTIPLY')
	scaleObject('overlay', '1.6','1.4');

	makeLuaSprite('CAM', hud..'CAMERA2', -100, 0);
	setScrollFactor('CAM', 0, 0);
	addLuaSprite('CAM', true);
	screenCenter('CAM', '')
	scaleObject('CAM', '1','1');
	setObjectCamera('CAM', 'camFilm')
	setProperty('CAM.alpha', 1)

	makeLuaSprite('clipTop', '', 0, -50);
	addLuaSprite('clipTop', false);
	makeGraphic('clipTop', screenWidth, 50, '000000')
	setObjectCamera('clipTop', 'other')

	makeLuaSprite('clipBottom', '', 0, screenHeight);
	addLuaSprite('clipBottom', false);
	makeGraphic('clipBottom', screenWidth, 50, '000000')
	setObjectCamera('clipBottom', 'other')

	if not lowQuality and not isStoryMode then
		if songName == 'rude' and doIntro and not seenCutscene then
			makeLuaSprite('introHide', '', 0, 0);
			setScrollFactor('introHide', 0, 0);
			addLuaSprite('introHide', true);
			scaleObject('introHide', '1.3','1.3');
			makeGraphic('introHide', screenWidth, screenHeight, '000000')
			setObjectCamera('introHide', 'other')
			setObjectOrder('introHide', 2)

			makeLuaSprite('intro', hud..'intros/intro_rude', 0, 0);
			addLuaSprite('intro', true);
			scaleObject('intro', '0.6','0.6');
			screenCenter('intro')
			setObjectCamera('intro', 'other')
			setProperty('intro.alpha', 0)
			setProperty('intro.visible', false)
		end
	end

	updateSkyByTime()

end

function onUpdate(elapsed)

	simulatedTimer = simulatedTimer + elapsed
   if simulatedTimer >= simulatedSpeed then
		simulatedTimer = 0
		simulatedHour = simulatedHour + 1
		if simulatedHour >= 24 then
			simulatedHour = 0
		end
		updateSkyByTime()
   end

	setProperty('clouds.x', getProperty('clouds.x') + 0.05)

	------------------ 
	-- CAMERA STUFF
	------------------
	if doIntroPan then
		local currentY = getProperty(camY)
        local newY = lerp(currentY, 550, elapsed * 1)

		setProperty(camY, newY)
	
        if math.abs(newY - 550) <= 1 then
        	doIntroPan = false
        end
    end

	if doCenterPan then
		local currentY2 = getProperty(camY)
		local currentX2 = getProperty(camX)

		local newX2 = lerp(currentX2, 650, elapsed * 2)
      local newY2 = lerp(currentY2, 560, elapsed * 2)
	
      if math.abs(newX2 - 650) <= 1 then
        	doCenterPan = false
			
		else
			setProperty(camY, newY2)
			setProperty(camX, newX2)
		end
   end

	if songName == 'rude' and doZoom then
		
		if curStep  > 641 and curStep  < 896 then
			if mustHitSection == false  then
				setProperty('defaultCamZoom',0.9) -- this is lucy
				doTweenZoom('toJasmine', 'camGame', '0.9', 0.5, 'quadInOut')

				yy = 550;

				ofs, ofs2 = 20, 40
				setProperty('cameraSpeed', 1)
			else
				setProperty('defaultCamZoom',0.9) -- this is jasmine
				doTweenZoom('toLucy', 'camGame', '0.9', 0.5, 'circInOut')

				ofs, ofs2 = 20, 40
				yy2 = 555;
				setProperty('cameraSpeed', 1)
			end
		elseif curStep  > 1024 and curStep  < 1152 then
			if mustHitSection == false  then
				setProperty('defaultCamZoom',0.9) -- this is lucy
				doTweenZoom('toJasmine', 'camGame', '0.9', 0.5, 'quadInOut')

				yy = 550;
				setProperty('cameraSpeed', 1)
			else
				setProperty('defaultCamZoom',0.9) -- this is jasmine
				doTweenZoom('toLucy', 'camGame', '0.9', 0.5, 'circInOut')
				yy2 = 555;
				setProperty('cameraSpeed', 1)
			end
		else
			if mustHitSection == false  then
				setProperty('defaultCamZoom', 1) -- this is lucy
				doTweenZoom('toJasmine', 'camGame', '1', 0.5, 'quadInOut')
			else
				setProperty('defaultCamZoom',1.1) -- this is jasmine
				doTweenZoom('toLucy', 'camGame', '1.1', 0.5, 'quadOut')
			end
			setProperty('cameraSpeed', 1.2)
			ofs, ofs2 = 5, 5
		end

		if not lowQuality then 
			if mustHitSection == false  then
				doTweenAlpha('toJasmineFlare', 'flare', '0.9', 0.1, 'quadOut')
			else
				doTweenAlpha('toLucyFlare', 'flare', '0.5', 0.1, 'quadOut')
				
			end
		end
	end

	---------------- 
	--CUSTOM FUNCTIONS
	----------------

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

	------------------ 
	-- CHARACTERS
	------------------

	setProperty('gf.visible', false)

	setProperty('dad.scrollFactor.x', 1.5);
	setProperty('dad.scrollFactor.y', 1.5);
	setProperty('boyfriend.scrollFactor.x', 1.5);
	setProperty('boyfriend.scrollFactor.y', 1.5);

	------------------ 
	-- SPRITE PROP
	------------------

	if not lowQuality then 
		if not enableFog then
			setProperty('fog1.x', (getProperty('fog1.x') + speed2))
			setProperty('fog2.x', (getProperty('fog2.x') + speed1))
			setProperty('fog3.x', (getProperty('fog3.x') + speed3))

			
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
	end


	if forceCam then
	
		local cx = getProperty('camFollow.x')
		local cy = getProperty('camFollow.y')

		local t = math.min(1, elapsed * 6)
		setProperty('camFollow.x', cx + (camX - cx) * t)
		setProperty('camFollow.y', cy + (camY - cy) * t)

		triggerEvent('Camera Follow Pos', tostring(camX), tostring(camY))

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
	    	if getProperty('boyfriend.animation.curAnim.name') == 'idle' then
                triggerEvent('Camera Follow Pos',xx2,yy2)
            end
        end
   else
      triggerEvent('Camera Follow Pos','','') -- self explanatory
   end

    
end

stepHitFuncs = { 

	[5] = function() --testing space
	
	end,

	[1069] = function() -- voicecrack lucy
		doTweenZoom('zoomOut', 'camGame', '0.85', 0.5, 'circOut')
		startSmoothShake(5, 0.5)
		voiceCrackFor('lucy', 80)
	end,

	[1134] = function() -- voicecrack jasmine
		doTweenZoom('zoomOut', 'camGame', '0.85', 0.5, 'circOut')
		startSmoothShake(5, 0.5)
		voiceCrackFor('jasmine', 80)
	end,

	[1455] = function() -- voicecrack lucy
		doTweenZoom('zoomOut', 'camGame', '0.85', 0.5, 'circOut')
		startSmoothShake(5, 0.5)
		voiceCrackFor('lucy', 80)
	end,

	[1520] = function() -- voicecrack jasmine
		doTweenZoom('zoomOut', 'camGame', '0.85', 0.5, 'circOut')
		startSmoothShake(5, 0.5)
		voiceCrackFor('jasmine', 80)
	end,

	[1548] = function() --ending
		playSound(sounds.. 'rude_BITCH-2', 1, 'ending')
		
		triggerEvent('Play Animation', 'BITCH', 'Dad')
		triggerEvent('Play Animation', 'BITCH', 'Boyfriend')

		doCenterPan = true
		--stayCentered = true
		followchars = false
		forceCam = true
		doZoom = false

		doTweenZoom('finalZoom', 'camGame', '1', 0.5, 'bounceIn')
		setProperty('defaultCamZoom',1)
		setProperty('cameraSpeed', 1.4)

		doTweenAlpha('fadeHBG', 'camHUD', '0', 0.5, 'quadOut')
		startSmoothShake(8, 1.5)
	end,

}

function onStepHit()
	if stepHitFuncs[curStep] then
		stepHitFuncs[curStep]()
	end

end

function onTweenCompleted(tag)
    -- tag format: fade_crowdFlash_123
    if string.sub(tag, 1, 5) == 'fade_' then
        local spr = string.sub(tag, 6)
        if luaSpriteExists(spr) then
            removeLuaSprite(spr, true)
            flashAlive = clamp(flashAlive - 1, 0, 9999)
        end
    end
end

function onTimerCompleted(tag, loops, loopsLeft)

	-- INTRO
	if tag == 'getOuttaHere' then
		doTweenAlpha('delete', 'introHide', 0, 1.5, 'quadOut')

	end
	if tag == 'panDown' then
		--setProperty('cameraSpeed', 0.2)
		doIntroPan = true

		setProperty('defaultCamZoom',1)
		doTweenZoom('zoomIntro', 'camGame', '1', 5, 'quadOut')
		--setProperty(camY, 650)

	end
	if tag == 'introShow' then
		setProperty('intro.visible', true)
		playSound('0-JINGLES/rude', 0.7, 'intro')

		doTweenAlpha('introRudeFade', 'intro', 1, 1, 'quadOut')
	end
	if tag == 'introFade' then
		doTweenAlpha('goodbyeIntro', 'intro', 0, 1, 'quadOut')
	end
	if tag == 'gameStart' then
		allowCountdown = true
		forceCam = false
		followchars = true
		doZoom = true

		setProperty('cameraSpeed', 1)

		letterBoxOut(2,2)
		startCountdown()
	end

	--CAMERA FLASHING
	if tag == flashSpawnTag and flashesEnabled then
		spawnCrowdFlash()

		-- sometimes spawn 2 in same tick
		if getRandomBool(35) then
			spawnCrowdFlash()
		end

		-- mini burst moment
		if getRandomBool(burstChance) then
			for i = 1, burstExtraSpawns do
				spawnCrowdFlash()
			end
		end
   end

	--RESTORE 
	if tag == 'vc_restore_opp' then restoreRange(0, 3, 0.7, 'cubeOut') end
	if tag == 'vc_restore_player'  then restoreRange(4, 7, 0.7, 'cubeOut') end

	
	

end

function goodNoteHit(id, direction, noteType, isSustainNote)
	setProperty('health', getProperty('health')+0.04);
end

function opponentNoteHit(id, direction, noteType, isSustainNote)
	if getProperty('health') > 0.2 then
		setProperty('health', getProperty('health')-0.08);
	end
end


function onBeatHit()
	if curBeat % 2 == 0 then

		if getProperty('dad.animation.curAnim.name') == 'idle' then
			characterPlayAnim('dad','idle',true)
		end

		if getProperty('boyfriend.animation.curAnim.name') == 'idle' then
			characterPlayAnim('boyfriend','idle',true)
		end
	end

	if not lowQuality then
		if curBeat % 1 == 0 then
			objectPlayAnimation('gen', 'dance', true)
			objectPlayAnimation('krip', 'dance', true)
			objectPlayAnimation('stem', 'dance', true)
			objectPlayAnimation('feline', 'dance', true)
			objectPlayAnimation('vi', 'dance', true)
			objectPlayAnimation('sari', 'dance', true)
			objectPlayAnimation('ping', 'dance', true)
		end

	end
end


-- ==================================================================
-- MISC
-- ==================================================================
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

function startSmoothShake(strength, duration)
	shakeStrength = strength or 5
	shakeDuration = duration or 0.5
	shakeTime = shakeDuration
end

function triggerBlur()
	blurAlpha = 1 -- reset
	blurActive = true
end

function lerp(a, b, t)
   return a + (b - a) * t
end

-- ==================================================================
-- REAL TIME BACKGROUND
-- ==================================================================
function getCurrentHour()
   return os.date("*t").hour

	--return simulatedHour
end

function updateSkyByTime()
    local hour = getCurrentHour()
    local skyColor = 'FFFFFF'
	local skyOverlay = 'FFFFFF'
    local isDay = true

   	if hour >= 5 and hour < 7 then
        skyColor = 'FBD786' -- SUNRISE
		skyOverlay = 'fcfcdd' -- Day
        isDay = false
		doTweenAlpha('moonFade', 'moon', 0, 1, 'quartInOut')
		doTweenAlpha('sunFade', 'sun', 0, 0.5, 'quartInOut')
		doTweenAlpha('cloudsAlphaDay', 'clouds', 0.1, 3, 'quartInOut')
	elseif hour >= 7 and hour < 12 then
        skyColor = '87CEFA' -- MORNING
		skyOverlay = 'FFFFFF' 
        isDay = true
		doTweenAlpha('sunFadeIn', 'sun', 1, 0.5, 'quartInOut')
		doTweenAlpha('cloudsAlphaSunset', 'clouds', 0.2, 3, 'quartInOut')
	elseif hour >= 12 and hour < 17 then
        skyColor = '87CEEB' -- AFTERNOON
		skyOverlay = 'd5eefc' 
        isDay = true
		
		doTweenAlpha('cloudsAlphaSunset', 'clouds', 0.3, 3, 'quartInOut')
	elseif hour >= 17 and hour < 19 then
        skyColor = 'FFA07A' -- EVENING
		skyOverlay = 'fcfcdd' 
        isDay = true
		doTweenAlpha('cloudsAlphaSunset', 'clouds', 0.3, 3, 'quartInOut')
    elseif hour >= 19 and hour < 21 then
        skyColor = 'FF7E5F' -- Sunset
		skyOverlay = 'f9d3a5' 
        isDay = false
		doTweenAlpha('sunFade', 'sun', 0, 1, 'quartInOut')
		doTweenAlpha('moonFade', 'moon', 0, 0.2, 'quartInOut')
		doTweenAlpha('cloudsAlphaSunset', 'clouds', 0.2, 3, 'quartInOut')
    else
        skyColor = '0D1B2A' -- Night
		skyOverlay = 'bef2fb' 
        isDay = false
		doTweenAlpha('moonFadeIn', 'moon', 1, 0.2, 'quartInOut')
		doTweenAlpha('cloudsAlphaNight', 'clouds', 0, 3, 'quartInOut')
    end

    doTweenColor('skyColorTween', 'sky', skyColor, 3, 'quartInOut')
	doTweenColor('skyOverlayTween', 'overlay', skyOverlay, 3, 'quartInOut')

    setProperty('sun.visible', isDay)
    setProperty('moon.visible', not isDay)

    updateCelestialPosition(hour, isDay)
end

function updateCelestialPosition(hour, isDay)
    local progress = 0
    if isDay then
        progress = (hour - 6) / 12 -- 6 AM to 6 PM
    else
        if hour >= 20 then hour = hour - 24 end
        progress = (hour + 6) / 12 -- 6 PM to 6 AM
    end

    progress = math.max(0, math.min(1, progress))
    local x = 100 + (1080 * progress)
	local y = 160 - math.sin(progress * math.pi) * 140

    if isDay then
        doTweenX('sunX', 'sun', x, 2, 'smootherStepInOut')
        doTweenY('sunY', 'sun', y, 2, 'smootherStepInOut')
    else
        doTweenX('moonX', 'moon', x, 2, 'smootherStepInOut')
        doTweenY('moonY', 'moon', y, 2, 'smootherStepInOut')
    end
end

-- ==================================================================
-- CAMERA FLASHING
-- ==================================================================
function crowdBounds()
	local x = -200
	local y = 200
	local w = screenWidth - 100
	local h = screenHeight - 400
	return x, y, w, h
end

function spawnCrowdFlash()
	if flashAlive >= flashMaxAlive then return end

	local bx, by, bw, bh = crowdBounds()
	if bw <= 10 or bh <= 10 then return end

	flashId = flashId + 1
	local tag = 'crowdFlash_' .. flashId

	local chosen = flashPaths[getRandomInt(1, #flashPaths)]
	makeLuaSprite(tag, chosen, 0, 0)

	local sc = getRandomFloat(flashScaleMin, flashScaleMax)
	scaleObject(tag, sc, sc)
	setProperty(tag .. '.alpha', getRandomFloat(flashAlphaMin, flashAlphaMax))

	setBlendMode(tag, 'ADD')

	local rx = getRandomFloat(bx, bx + bw)
	local ry = getRandomFloat(by, by + bh)
	setProperty(tag .. '.x', rx)
	setProperty(tag .. '.y', ry)

	setScrollFactor(tag, getProperty('crowd.scrollFactor.x'), getProperty('crowd.scrollFactor.y'))
	addLuaSprite(tag, false)
	setObjectOrder(tag, getObjectOrder('crowd') + 10)

	flashAlive = flashAlive + 1

	doTweenAlpha('fade_' .. tag, tag, 0, flashFadeTime, 'quadOut')

	if getRandomBool(hudPopChance) and luaSpriteExists('hudFlashPop') then
		setProperty('hudFlashPop.alpha', getRandomFloat(hudPopAlphaMin, hudPopAlphaMax))
		doTweenAlpha('hudPopFade', 'hudFlashPop', 0, hudPopFadeTime, 'quadOut')
	end

end

function startCrowdFlashes(rate, maxAlive)
	flashesEnabled = true
	if rate ~= nil then flashSpawnRate = rate end
	if maxAlive ~= nil then flashMaxAlive = maxAlive end

	runTimer(flashSpawnTag, flashSpawnRate, 0)
end

function clamp(v, a, b)
	if v < a then return a end
	if v > b then return b end
	return v
end