local hud = 'stages/hudelements/4-hudShit/'
local stage = 'stages/slopventure/BG/'

local xx, yy, xx2, yy2 = 750, 670, 1160, 650; -- first is dad, second set is bf
local ofs, ofs2, i = 35, 20, 0;
local followchars, forceCam = false, false;


local kaylaFollow, kaylaAltFollow, kaylaPosX, kaylaPosY = false, false, 0, 0

local defaultStrumX = {}
local defaultStrumY = {}

local simulatedHour = 6 -- start at 6 AM
local simulatedTimer = 0
local simulatedSpeed = 3-- seconds in game = 1 hour
local lightColor = getColorFromHex('42C1D6')  

local doIntroPan, doIntro, zoomNum = false, true, 1.1

local followKalyaAlts, doZoom = false, true

local testingMode = false

function onCreatePost() 

	if songName == 'sno-bunnie' then
		if doIntro then
			forceCam = true
			followchars = false
			doZoom = false

			camX = 940
			camY = 100

			setProperty('cameraSpeed', 2)
			setProperty('camHUD.alpha', 0);
			letterBox(1,1,0)

			runTimer('panDown', 2,1);
			runTimer('gameStart', 7,1);
		end
	end

end

function onCreate()

	--cameraShit
	camX = 'camFollow.x';	
	camY = 'camFollow.y';

	scaleSize = '1.1'

	makeLuaSprite('sky', '', 0, 0);
	setScrollFactor('sky', 0, 0);
	addLuaSprite('sky', false);
	scaleObject('sky', '1.3','1.3');
	makeGraphic('sky', screenWidth, screenHeight, 'ffffff')

	makeLuaSprite('bg', stage..'BG BUILDING', 1200, 300);
	setScrollFactor('bg', 0.6, 0.3);
	addLuaSprite('bg', false);
	scaleObject('bg', 1, 1);

	makeLuaSprite('folliage', stage..'BG TREES', 1000, -150);
	setScrollFactor('folliage', 0.75, 0.55);
	addLuaSprite('folliage', false);
	scaleObject('folliage', scaleSize, scaleSize);

	makeLuaSprite('building', stage..'BUILDING', -200, -150);
	setScrollFactor('building', 0.8, 0.7);
	addLuaSprite('building', false);
	scaleObject('building', 1.2, scaleSize);

	makeLuaSprite('ground', stage..'SIDEWALK', -250, 540);
	setScrollFactor('ground', 0.9, 0.9);
	addLuaSprite('ground', false);
	scaleObject('ground', 1.4, scaleSize);

	if not lowQuality then

		makeLuaSprite('sign', stage..'SIGN', 500, 280);
		setScrollFactor('sign', 0.9, 0.9);
		addLuaSprite('sign', false);
		scaleObject('sign', 1, 1);

		makeLuaSprite('pole', stage..'POLE', 1300, -100);
		setScrollFactor('pole', 0.9, 0.9);
		addLuaSprite('pole', false);
		scaleObject('pole', scaleSize, scaleSize);
	end

	makeAnimatedLuaSprite('kaylaAlt', 'stages/slopventure/ALTS', 190, 500)
	addAnimationByPrefix('kaylaAlt', 'LEFT', 'LEFT', 24, false)
	addAnimationByPrefix('kaylaAlt', 'DOWN', 'DOWN', 24, false)
	addAnimationByPrefix('kaylaAlt', 'UP', 'UP', 24, false)
	addAnimationByPrefix('kaylaAlt', 'RIGHT', 'RIGHT', 24, false)
	setScrollFactor('kaylaAlt', 0.9, 0.9);
	setProperty('kaylaAlt.alpha', 0)
	addLuaSprite('kaylaAlt', false);

	makeLuaSprite('tree', stage..'TREE', -100, -140);
	setScrollFactor('tree', 0.9, 0.9);
	addLuaSprite('tree', false);
	scaleObject('tree', scaleSize, scaleSize);

	if not lowQuality then
		makeLuaSprite('car', stage..'CAR', 1520, 640);
		setScrollFactor('car', 1.6, 2);
		addLuaSprite('car', true);
		scaleObject('car', 1.4, 1.3);
	end

	if not enableLights then
		makeLuaSprite('light', hud..'LIGHTTEST', -500, -100); -- -200
		setScrollFactor('light', 0, 0);
		addLuaSprite('light', true);
		scaleObject('light', '1.7','1');
		setBlendMode('light', 'SCREEN')
		setProperty('light.alpha', 0.5)
		setObjectOrder('light', 50)
		setProperty('light.color', lightColor)

		makeLuaSprite('overlay', '', -300, -100);
		setScrollFactor('overlay', 0, 0);
		addLuaSprite('overlay', true);
		makeGraphic('overlay', screenWidth, screenHeight, 'FFFFFF')
		setProperty('overlay.alpha', 0.2)
		setBlendMode('overlay', 'MULTIPLY')
		scaleObject('overlay', '1.6','1.4');
	end

	if not lowQuality then
		makeLuaSprite('light', stage..'LIGHT', 700, -130);
		setScrollFactor('light', 0.9, 0.9);
		addLuaSprite('light', true);
		setProperty('light.alpha', 0)
		setBlendMode('light', 'SCREEN')
		scaleObject('light', scaleSize, scaleSize);
	end
	
	makeLuaSprite('clipTop', '', 0, -50);
	makeGraphic('clipTop', screenWidth, 50, '000000')
	makeLuaSprite('clipBottom', '', 0, screenHeight);
	makeGraphic('clipBottom', screenWidth, 50, '000000')

	setObjectCamera('clipTop', 'other')
	setObjectCamera('clipBottom', 'other')
	addLuaSprite('clipTop', false);
	addLuaSprite('clipBottom', false);

	updateSkyByTime()
end



function activateRage()

	runHaxeCode([[
		FlxG.sound.music.pause();
		if (PlayState.instance.vocals != null) PlayState.instance.vocals.pause();
		PlayState.instance.generatedMusic = false;
		Conductor.songPosition = FlxG.sound.music.time;
		PlayState.instance.paused = true;
	]]);

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


	if kaylaFollow then
		camX = kaylaPosX
		camY = kaylaPosY
	end

	if followKalyaAlts then -- tree
		xx2 = 350
		yy2 = 630
		zoomNum = 1.6
	else
		xx2 = 1160
		yy2 = 650
		zoomNum = 1.1
	end

	--CAMERA
	if doZoom then
		if mustHitSection == false  then
			setProperty('defaultCamZoom',1.3) -- this is nana
			doTweenZoom('toNana', 'camGame', '1.3', 0.5, 'quadOut')
			cancelTween('toKayler')
		else
			doTweenZoom('toKayler', 'camGame', zoomNum , 1, 'circOut')
         	setProperty('defaultCamZoom', zoomNum) -- this is kayler
			cancelTween('toNana')
      	end
	end

	-- kaylas offset alts
	addOffset('kaylaAlt','intro', 85, 10)
	addOffset('kaylaAlt','UP', 5, 0)
	addOffset('kaylaAlt','DOWN', 5, -35)
	addOffset('kaylaAlt','RIGHT', 5, -20)
	addOffset('kaylaAlt','LEFT', 25, -20)


	for i = 0, 7 do
		local ogX = getPropertyFromGroup('strumLineNotes', i, 'x')
		local wiggle = math.sin((getSongPosition() / 100) + i) * 1
		setPropertyFromGroup('strumLineNotes', i, 'x', ogX + wiggle)
	end

	for i = 0, 7 do
		setPropertyFromGroup('strumLineNotes', i, 'scale.x', 0.6)
		setPropertyFromGroup('strumLineNotes', i, 'scale.y', 0.6)
		noteTweenX('noteBumpX'..i, i, getPropertyFromGroup('strumLineNotes', i, 'x'), 0.15, 'backOut')
		noteTweenY('noteBumpY'..i, i, getPropertyFromGroup('strumLineNotes', i, 'y'), 0.15, 'backOut')
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
			if getProperty('boyfriend.animation.curAnim.name') == 'idle-alt' then
				triggerEvent('Camera Follow Pos',xx2,yy2)
			end
		end
	else
		triggerEvent('Camera Follow Pos','','') -- self explanatory
	end

	setProperty('gf.visible', false)
end

function letterBox(duration,time,alpha) 
	doTweenY('clip1Move', 'clipTop', 0, duration, 'smootherStepIn')
	doTweenY('clip2Move', 'clipBottom', screenHeight - 50, duration, 'smootherStepIn')
	doTweenAlpha('byebye', 'camHUD', alpha, time, 'backIn')
end
function letterBoxOut(duration,time,alpha) 
	doTweenY('clip1Move', 'clipTop', -50, duration, 'smootherStepIn')
	doTweenY('clip2Move', 'clipBottom', screenHeight, duration, 'smootherStepIn')
	doTweenAlpha('hellohello', 'camHUD', alpha, time, 'circOut')
end

stepHitFuncs = { 

	
	[1] = function() 
		if songName == 'sno-bunnie' then
			triggerEvent('Play Animation', 'intro', 'Dad')
		end
	end,

	[23] = function() -- kayla speaks
		if songName == 'sno-bunnie' then
			forceCam = true
			kaylaFollow = true
			doIntroPan = false

			kaylaPosX = 1110
			kaylaPosY = 610
		end
	end,

	[25] = function() 
		if songName == 'sno-bunnie' then
			triggerEvent('Play Animation', 'intro', 'BF')
		end
	end,

	[64] = function() 
		if songName == 'sno-bunnie' then
			forceCam = false
			followchars = true
			doZoom = true
		end
	end,

	[85] = function() -- pans over before cough
		if songName == 'sno-bunnie' then
			forceCam = true
			followchars = false
			doZoom = false
			kaylaFollow = true
		end
	end,

	[88] = function() -- coughs
		if songName == 'sno-bunnie' then
			triggerEvent('Play Animation', 'ahem', 'BF')
		end
	end,

	[96] = function() --starts
		if songName == 'sno-bunnie' then
			followchars = true
			forceCam = false
			doZoom = true
			kaylaFollow = false
		end
		
	end,

	[315] = function() -- she humps
		if songName == 'sno-bunnie' then
			setProperty('cameraSpeed', 0.5)
			followchars = false
			forceCam = true
			kaylaFollow = true

			kaylaPosX = 1110
			kaylaPosY = 680
		end

	end,

	[348] = function() 
		if songName == 'sno-bunnie' then
			setProperty('cameraSpeed', 1)
			followchars = true
			kaylaFollow = false
			forceCam = false
		end
		
	end,

	[368] = function() -- go to alts
		if songName == 'sno-bunnie' then
			kaylaFollow = true
			kaylaPosX = 350
			kaylaPosY = 630
			
			followKalyaAlts = true
			followchars = false
			doZoom = false
			forceCam = true

			setProperty('cameraSpeed', 1.5)

			doTweenZoom('toKaylaAlt', 'camGame', '1.6', 1, 'quadOut')
			setProperty('defaultCamZoom',1.6)
		
			addAnimationByPrefix('kaylaAlt', 'intro', 'INTRO', 24, false)
			playAnim('kaylaAlt', 'intro', true)
			setProperty('kaylaAlt.alpha', 1)
		end
	end,

	[378] = function() -- begin animations
		if songName == 'sno-bunnie' then
			kaylaFollow = false
			doZoom = true
			forceCam = false
			followKalyaAlts = true
			followchars = true
		end
	end,

	[478] = function() -- it ends the alts
		if songName == 'sno-bunnie' then
			setProperty('cameraSpeed', 1)
			followKalyaAlts = false
			forceCam = false
			doTweenX('moveKayla', 'kaylaAlt', 180, 0.5, 'smootherStepIn')
			doTweenAlpha('fadeKayla', 'kaylaAlt', 0, 0.5, 'smootherStepIn')
		end
	end,

	[580] = function() --113
		if songName == 'sno-bunnie' then
			letterBox(1,1,0)
			triggerEvent('Play Animation', 'PHONE', 'Dad')
		end
	end,

	[592] = function() --113
		if songName == 'sno-bunnie' then
			triggerEvent('Play Animation', 'BIDNESS', 'BF')
			cameraShake('camGame', 0.005, 4) 
			runTimer('fadeNana', 3,1);
		end
	end,

}

function onStepHit()
	if stepHitFuncs[curStep] then
		stepHitFuncs[curStep]()
	end

end

function onTimerCompleted(tag, loops, loopsLeft)

	-- INTRO
	if tag == 'panDown' then
		camY = 650
		setProperty('cameraSpeed', 0.6)
		doTweenZoom('begin', 'camGame', '1.1', 3, 'quadOut')
		
	end

	if tag == 'gameStart' then
		setProperty('cameraSpeed', 1.2)
		letterBoxOut(1,1,1)
	end
	
	if tag == 'fadeNana' then
		doTweenAlpha('nanaFades', 'dad', '0', 0.3, 'circOut')
	end
end

function onTweenCompleted(tag, loops, loopsLeft)
	if tag == 'nanaFade' then
		setProperty('dad.visible', false)
	end
end

--SKY
function updateSkyByTime()
   local hour = getCurrentHour()
   local skyColor = 'FFFFFF'
	local skyOverlay = 'FFFFFF'
   local isDay = true

   if hour >= 5 and hour < 7 then
      skyColor = 'FBD786' -- SUNRISE
		skyOverlay = 'fcfcdd' -- Day
      isDay = true
		
	elseif hour >= 7 and hour < 12 then
      skyColor = '87CEFA' -- MORNING
		skyOverlay = 'FFFFFF' 
      isDay = false

		if not lowQuality then
			doTweenAlpha('streetLight', 'light', 0, 1, 'quartInOut')
		end
	elseif hour >= 12 and hour < 17 then
      skyColor = '87CEEB' -- AFTERNOON
		skyOverlay = 'd5eefc' 
      isDay = true
	
	elseif hour >= 17 and hour < 19 then
      skyColor = 'FFA07A' -- EVENING
		skyOverlay = 'fcfcdd' 
      isDay = true

		if not lowQuality then
			doTweenAlpha('streetLight', 'light', 0.8, 3, 'quartInOut')
		end
   elseif hour >= 19 and hour < 21 then
      	skyColor = 'FF7E5F' -- Sunset
		skyOverlay = 'f9d3a5' 
      	isDay = false
	  	if not lowQuality then
			doTweenAlpha('streetLight', 'light', 0.8, 3, 'quartInOut')
		end
   else
     	skyColor = '0D1B2A' -- Night
		skyOverlay = 'bef2fb' 
      	isDay = false
	 	 if not lowQuality then
			doTweenAlpha('streetLight', 'light', 0.8, 3, 'quartInOut')
		end
   end

   doTweenColor('skyColorTween', 'sky', skyColor, 3, 'quartInOut')

	if not enableLights then
		doTweenColor('skyOverlayTween', 'overlay', skyOverlay, 3, 'quartInOut')
	end

end

function getCurrentHour()
   return os.date("*t").hour

	--return simulatedHour
end
