ambientLight = getColorFromHex('f9c342')  
ambientLight2 = getColorFromHex('32CEEE')  
playerColor = getColorFromHex('6ea6ef')  
opponentColor = getColorFromHex('f75596') 
hudColor = getColorFromHex('181521') 

local baseFPS = 144 -- i worked on this fps so i have to account for other fpses

--stage path
local stage, stage2, trans, hud = 'stages/week3/market/', 'stages/week3/market/SECOND STAGE/', 'stages/week3/market/TRANSITION/', 'stages/hudelements/'
local sounds = 'WEEK2/'

local camX, camY, forceCam = 'camFollow.x', 'camFollow.y', false
local startPan, doZoom, doSecondStagePan = false, true, false

--jasmine and lucy variables
local xx, yy = 1050, 580; -- jasmine
local xx2, yy2 = 790, 590; -- lucy
local ofs, ofs2 = 15, 30;
local del, del2, i, followchars = 0, 0, 0, true;

local moveSpeed, bounceDirection, topLimit = 0.2, 1, 385  
local swaySpeed, swayAmount, centerX, camEndY  = 2, 50, 300, 50;
local stillLooping, stillFlickering, isShaking = true, false, false

--assets
local shelfNames = {'shelf1', 'shelf2', 'shelf3'}
local shelfPaths = {'stages/week3/market/shelf', 'stages/week3/market/shelf2', 'stages/week3/market/shelf3'}
local shelfWidths = {}
local shelvesFrozen, shelfY = true, 170
local scrollEase, scrollDirection = 0, 1
local beamSpeedX, fridgeSpeedX, moveSpeedX, bgSpeedX, bgfrideSpeedX = 3, 1.9, 1.3, 0.1, 0.2;

local peopleSprites = {'MEX', 'HEX', 'NESSA'} 
local bgPeopleSprites = {'FG_1', 'FG_2', 'FG_3', 'FG_4', 'FG_5', 'FG_6', 'FG_7'} 
local canSpawnNPC, canSpawnNPC2, lastPeep, lastPeepBG = true, true, nil, nil

local spritesToRemove = {'bg', 'bgfridge', 'fridge', 'beam', 'debris', 'daPeep'}
local spritesToRemove2 = {'parents', 'scared', 'fg-scared', 'bg-scared'}
local spritesToRemove3 = {'t_bg', 't_floor', 't_shelf', 't_box', 'lucy', 'jasmin', 'boxfg'}

local allowCountdown, doDialogue = false, true;
local cameraMiddle, hasIntroStarted, dialogueDone, phoneRings = false, false, false, true

--stages
local isFirstStage, isSecondStage, secondStageAlreadySpawned, doIntro = true, false, false, false
local isScared, scaredStageAlreadySpawned, isTransStage, transStageAlreadySpawned = false, false, false, false

--custom functions
local shakeDuration, shakeTime, shakeStrength, shakeCam  = 0, 0, 0, 'camGame'; -- custom shake
local blurAlpha, blurActive = 1, false 

-- second stage
local noiseActive, noiseMisses, noiseLimit, noiseFailed = false, 0, 4, false 
local noiseDanger, noiseDangerT, iconBaseScale, noiseWarnAt = false, 0, 0.8, 2

local barX, barY = 1000, 100  
local shaderName, BAR_ID = 'uitest', 'progressBar'
haloNoteTotal, haloHits = 0, 0

haloNoteTotal = 0
haloHits = 0
haloNeeded = 0
--
local manualCam, camTargetName, closeZoom, midZoom = false, 'camTarget', 1.15, 1
local currentFocus, camTransition = 'lucy', ''
local wobbleTime, wobbleAmount = 0, 10

local lucyCamX, lucyCamY = 880, 550
local jasCamX,  jasCamY  = 1200, 570

-- tooltips
local tooltipPadding = 8
local tooltipWidth = 420
local tooltipY = 55
local tooltipX = 35

local phase = 1
local callNum = 1 -- file number

function onCreatePost()

	if isFirstStage then
		
		runIntroStuff()
	end

	removeLuaSprite('gf', true)
	runHaxeCode([[
		if (PlayState.instance.gf != null)
		{
			PlayState.instance.remove(PlayState.instance.gf, true);
			PlayState.instance.gf.destroy();
			PlayState.instance.gf = null;
		}
	]]);

	makeLuaSprite(camTargetName, nil, lucyCamX, lucyCamY)
	setProperty(camTargetName..'.visible', false)
	addLuaSprite(camTargetName, false)

	phase = 1
	if doIntro and not isStoryMode and not lowQuality then
		runTimer('introShow', 0.5, 1);
		runTimer('introFade', 4,1);
		runTimer('getOuttaHere', 3,1);
		runTimer('gameStart', 5,1);
	end

	precacheImage(stage..'peeps/NESSA')
	precacheImage(stage..'peeps/HEX')
	precacheImage(stage..'peeps/MEX')
	precacheImage(stage..'peeps/BG/FG_1')
	precacheImage(stage..'peeps/BG/FG_2')
	precacheImage(stage..'peeps/BG/FG_3')
	precacheImage(stage..'peeps/BG/FG_4')
	precacheImage(stage..'peeps/BG/FG_5')
	precacheImage(stage..'peeps/BG/FG_6')
	precacheImage(stage..'peeps/BG/FG_7')

	precacheImage(stage2..'shelfBG')
	precacheImage(stage2..'LUCY')
	precacheImage(stage2..'JASMINE')
	precacheImage(stage2..'shadow_1')
	precacheImage(stage2..'overlay_1')
	precacheImage(stage2..'boxFG')
	precacheImage(stage2..'DDHANDS')
	precacheImage(stage2..'MMHANDS')
	precacheImage(hud..'4-hudShit/SCREAM')


	addCharacterToList('jasmine-market-2', 'bf')
	addCharacterToList('lucy-market-2', 'dad')

end

function onCreate()

	if difficulty == 2 then
        noiseLimit = 4
    elseif difficulty == 1 then
        noiseLimit = 6
    else
        noiseLimit = 8
    end
	-------------------------------------------------------- ASSETS
	if isFirstStage then

		setPropertyFromClass('substates.GameOverSubstate', 'characterName', 'death-jasmine'); --Character json file for the death 
		setPropertyFromClass('substates.GameOverSubstate', 'deathSoundName', 'DEATH/duoDeath'); --put in mods/sounds/
		setPropertyFromClass('substates.GameOverSubstate', 'loopSoundName', 'DEATH/duo_death'); --put in mods/music/
		setPropertyFromClass('substates.GameOverSubstate', 'endSoundName', 'DEATH/duoDeathSound'); --put in mods/music/

		makeLuaSprite('bg', stage..'mainbg2', 0, 0);
		setScrollFactor('bg', 0.5, 1);
		addLuaSprite('bg', false);
		scaleObject('bg', '1.4','1');
		updateHitbox('bg')

		makeLuaSprite('bgfridge', stage..'fridgebg', 100, 620);
		setScrollFactor('bgfridge', 0.6, 1);
		addLuaSprite('bgfridge', false);
		scaleObject('bgfridge', '1.2','1.1');
		updateHitbox('bgfridge')

		local xPos = 1400
		for i = 1, #shelfNames do
			local name = shelfNames[i]
			local path = shelfPaths[i]

			makeLuaSprite(name, path, xPos, shelfY)
			setScrollFactor(name, 0.95, 1)
			scaleObject(name, 1, 1)
			addLuaSprite(name, false)

			local width = getProperty(name .. '.width') + 400
			shelfWidths[i] = width

			xPos = xPos + width
		end

		for i = 1, #bgPeopleSprites do
    		precacheImage(stage..'peeps/BG/' .. bgPeopleSprites[i])
		end

		makeLuaSprite('daPeepBG', stage..'peeps/BG/' .. bgPeopleSprites[1], -9999, -9999) --caching
		setScrollFactor('daPeepBG', 0.85, 0.9)
		scaleObject('daPeepBG', '1', '1')
		setProperty('daPeepBG.alpha', 0)
		addLuaSprite('daPeepBG', false)

		makeLuaSprite('fridge', stage..'fgfride', -700, 560);
		setScrollFactor('fridge', 1.2, 0.9);
		addLuaSprite('fridge', true);
		scaleObject('fridge', '1.1','1.1');

		makeLuaSprite('beam', stage..'beam', 1900, 0);
		setScrollFactor('beam', 1.2, 0.9);
		addLuaSprite('beam', true);
		setProperty('beam.alpha', 1)
		scaleObject('beam', '1.2','1.1');

		makeAnimatedLuaSprite('debris', stage..'DEBRIS', 100, -100);
		setScrollFactor('debris', 1.4, 0.7);
		scaleObject('debris', '1.3','1.2');
		addLuaSprite('debris', true);

		makeLuaSprite('overlay_one', '', -300, -100);
		setScrollFactor('overlay_one', 0, 0);
		addLuaSprite('overlay_one', true);
		scaleObject('overlay_one', '1','1');
		setBlendMode('overlay_one', 'MULTIPLY')
		scaleObject('overlay_one', '1.4','1.4');
		makeGraphic('overlay_one', screenWidth, screenHeight, 'f9c342')
		setProperty('overlay_one.alpha', 0.4)

		makeLuaSprite('light2', hud..'4-hudShit/LIGHTTEST', -700, -400);
		setScrollFactor('light2', 0, 0);
		addLuaSprite('light2', true);
		scaleObject('light2', '1.7','1.2');
		setBlendMode('light2', 'SCREEN')
		setProperty('light2.color', ambientLight)
		setProperty('light2.alpha', 0.85)

		makeLuaSprite('darkness', '', -300, -100);
		setScrollFactor('darkness', 0, 0);
		addLuaSprite('darkness', true);
		scaleObject('darkness', '1.35','1.35');
		makeGraphic('darkness', screenWidth, screenHeight, '000000')
		setProperty('darkness.alpha', 0)
		setObjectCamera('darkness', 'other')

	end

	makeLuaSprite('clipTop', '', 0, -35);
	setScrollFactor('clipTop', 0, 0);
	addLuaSprite('clipTop', true);
	scaleObject('clipTop', '1','1');
	makeGraphic('clipTop', screenWidth, 35, '000000')
	setObjectCamera('clipTop', 'other')

	makeLuaSprite('clipBottom', '', 0, screenHeight);
	setScrollFactor('clipBottom', 0, 0);
	addLuaSprite('clipBottom', true);
	scaleObject('clipBottom', '1','1');
	makeGraphic('clipBottom', screenWidth, 35, '000000')
	setObjectCamera('clipBottom', 'other')

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

	if downscroll then
		setProperty('tooltipBG.y', tooltipY)
		setProperty('tooltipText.y', tooltipY + tooltipPadding)
	else
		setProperty('tooltipText.y', screenHeight - getProperty('tooltipBG.height') - tooltipY + tooltipPadding)
		setProperty('tooltipBG.y', screenHeight - getProperty('tooltipBG.height') - tooltipY)
	end

	if not lowQuality and not isStoryMode and songName == 'intervention' and doIntro then

		makeLuaSprite('introHide', '', 0, 0);
		setScrollFactor('introHide', 0, 0);
		addLuaSprite('introHide', true);
		scaleObject('introHide', '1.3','1.3');
		makeGraphic('introHide', screenWidth, screenHeight, '000000')
		setObjectCamera('introHide', 'other')
		setObjectOrder('introHide', 2)

		makeLuaSprite('intro', hud..'4-hudShit/intros/intro_intervention', 0, 0);
		addLuaSprite('intro', true);
		scaleObject('intro', '0.6','0.6');
		screenCenter('intro')
		setObjectCamera('intro', 'other')
		setProperty('intro.alpha', 0)
		setProperty('intro.visible', false)
	
	end

end

function onUpdate(elapsed)

	if isStoryMode and doIntro then
		if dialogueDone and isFirstStage then
			dialogueDone = false
			runTimer('startIntroMove', 1)
		end
	else
		if dialogueDone and isFirstStage then
			dialogueDone = false
			runTimer('startIntroMove', 1)
		end
	end

	---------------------- 
	-- STAGE ONE
	----------------------
	if isFirstStage then
		phase = 1
		if not shelvesFrozen then
			for i = 1, #shelfNames do
				
				local name = shelfNames[i]
				local width = shelfWidths[i]
				local x = getProperty(name .. '.x') - (moveSpeedX * baseFPS * elapsed)

				setProperty(name .. '.x', x)

				if x + width <= 0 then
					local newX = getRightmostShelfX() + 10 -- spacing buffer
					setProperty(name .. '.x', newX)
				end
				
			end
		
			if scrollDirection == 1 then
				scrollEase = math.min(scrollEase + elapsed * 0.5, 1) -- ease in
			elseif scrollDirection == -1 then
				scrollEase = math.max(scrollEase - elapsed * 0.5, 0) -- ease out
			end
		
			if luaSpriteExists('daPeep') then
				local peepX = getProperty('daPeep.x')
				local peepSpeed = scrollEase * (4 * baseFPS)
				setProperty('daPeep.x', peepX - (peepSpeed * elapsed))
				
				if peepX < (-screenWidth * 1.5) then
					removeLuaSprite('daPeep', true)
					runTimer('nextNPCSpawn', getRandomFloat(7, 10)) -- seconds
				end

			end

			if luaSpriteExists('daPeepBG') then
				local peepBGX = getProperty('daPeepBG.x')
				local peepBGSpeed = scrollEase * (2.2 * baseFPS)
				setProperty('daPeepBG.x', peepBGX - (peepBGSpeed * elapsed))
				
				if peepBGX < (-screenWidth * 0.5) then
					setProperty('daPeepBG.alpha', 0)
					runTimer('nextNPCSpawn2', getRandomFloat(3, 6)) -- seconds
				end
			end

			local maxShelf = -99999 -- setting the character in front of the shelves, looks weird without it
			for i = 1, #shelfNames do
				if luaSpriteExists(shelfNames[i]) then
					local o = getObjectOrder(shelfNames[i])
					if o > maxShelf then maxShelf = o end
				end
			end
			if maxShelf > -9000 then
				if luaSpriteExists('daPeepBG') then setObjectOrder('daPeepBG', maxShelf + 1) end
			end
			--

			-- da speeds at which asset should move at, higher # is in front and should be moving faster

			local fridgeX, bg1X, bg2X, beamX = getProperty('fridge.x'), getProperty('bg.x'), getProperty('bgfridge.x'), getProperty('beam.x')
	
			beamSpeedX = scrollEase * 3 --beam
			fridgeSpeedX = scrollEase * 1.8 --dr.bob
			moveSpeedX = scrollEase * 1.3 --shelf
			bgfrideSpeedX = scrollEase * 0.2 --background fridge
			bgSpeedX = scrollEase * 0.1--wall

			setProperty('beam.x', beamX - (beamSpeedX * baseFPS * elapsed))
			setProperty('fridge.x', fridgeX - (fridgeSpeedX * baseFPS * elapsed))
			setProperty('bgfridge.x', bg2X - (bgfrideSpeedX * baseFPS * elapsed))
			setProperty('bg.x', bg1X - (bgSpeedX * baseFPS * elapsed))
			
			if fridgeX < -getProperty('fridge.width') - 500 then
				setProperty('fridge.x', screenWidth + 500)
			end
			if beamX < -getProperty('beam.width') - 2500 then
				setProperty('beam.x', screenWidth + 200)
			end
		end
		
		-- walk cycle
		local spriteY = getProperty('dad.y')
		local bottomLimit = 395

		setProperty('dad.y', spriteY + (moveSpeed * bounceDirection * baseFPS * elapsed))
		if spriteY <= topLimit then
			bounceDirection = 1  
		elseif spriteY >= bottomLimit then
			bounceDirection = -1  
		end

		if curStep  > 1  and  curStep  < 848 and doZoom then
			if mustHitSection == false  then
				setProperty('defaultCamZoom',1.45) -- this is jasmine (1.35)
				doTweenZoom('toJasmine', 'camGame', '1.2', 0.8, 'backOut')
			else
				setProperty('defaultCamZoom',1.35) -- this is lucy (1.25)
			end
		end

	end
	
	---------------------- 
	-- STAGE TWO
	----------------------

	if isSecondStage then
		setProperty('dad.x', 64)
		setProperty('dad.y', 332)

		setProperty('boyfriend.x', 870)
		setProperty('boyfriend.y', 322)

		setProperty('dad.scrollFactor.x', 1);
		setProperty('dad.scrollFactor.y', 1);
	
		setProperty('boyfriend.scrollFactor.x', 1);
		setProperty('boyfriend.scrollFactor.y', 1);

		if doZoom then
			if mustHitSection == false  then
				setProperty('defaultCamZoom',1.15) -- this is lucy (1.15)
				doTweenZoom('toLucy', 'camGame', '1.15', 0.4, 'circOut')
			else
				doTweenZoom('toJasmine', 'camGame', '1.25', 0.4, 'smootherStepIn')
				setProperty('defaultCamZoom',1.25) -- this is jasmine (1.05)
			end
		end

		-- if manualCam then
		-- 	forceCam = true
		-- 	local cx = getProperty(camTargetName..'.x')
		-- 	local cy = getProperty(camTargetName..'.y')
		-- 	--triggerEvent('Camera Follow Pos', cx, cy)

		-- 	camX = cx
		-- 	camY = cy
    	-- end

		if manualCam then

			followchars = false

			wobbleTime = wobbleTime + elapsed * 30

			local baseX = getProperty(camTargetName..'.x')
			local baseY = getProperty(camTargetName..'.y')

			local offX = math.sin(wobbleTime / 18) * wobbleAmount
			local offY = math.cos(wobbleTime / 23) * wobbleAmount

			--triggerEvent('Camera Follow Pos', baseX + offX, baseY + offY)

			camX = baseX + offX
			camY = baseY + offY
   	end

		setTextString('noiseCount', tostring(noiseMisses).."/"..tostring(noiseLimit))
		updateNoiseDanger(elapsed)

		addOffset('jasmineAlt','idle', 5, -22)
		addOffset('jasmineAlt','intro', 20, 5)
		addOffset('jasmineAlt','end', -10, 80)

		addOffset('lucyAlt','idle', -52, -40)
		addOffset('lucyAlt','intro', -28, 0)
		addOffset('lucyAlt','end', -45, -20)

		if mustHitSection == false  then
			focusLucy()
		else
			focusJasmine()
		end

	end
	---------------------- 
	-- SPAWNING STAGES
	----------------------

	if isScared and not scaredStageAlreadySpawned then
		scaredStageAlreadySpawned = true
		scaredShit()
	end

	if isTransStage and not transStageAlreadySpawned then
		transStageAlreadySpawned = true
		addTransitionStage()
	end

	if isSecondStage and not secondStageAlreadySpawned then
		secondStageAlreadySpawned = true
		addSecondStageFR()
	end
	---------------------- 
	-- CAMERA PANS
	----------------------
	if isSecondStage and doSecondStagePan then
		camX = 1000
	end

	if startPan then
		camX = 1500
	end

	if cameraMiddle then
		followchars = false

		camX = 1000
		camY = 600
	end

	---------------------- 
	-- CUSTOM FUNCTIONS
	----------------------

	if blurActive then
		blurAlpha = blurAlpha - (elapsed * 1)

		if blurAlpha <= 0 then
			blurAlpha = 0
			blurActive = false
			runHaxeCode("FlxG.camera.setFilters([]);")
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

		setProperty(shakeCam .. '.x', offsetX)
		setProperty(shakeCam .. '.y', offsetY)

	elseif isShaking then
		setProperty(shakeCam .. '.x', 0)
		setProperty(shakeCam .. '.y', 0)
		isShaking = false
   end

	-- if del > 0 then
	-- 	del = del - 1
	-- end
	-- if del2 > 0 then
	-- 	del2 = del2 - 1
	-- end
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
end


-- FIRST STAGE FUNCTIONS

	function getRightmostShelfX()
		local max = -99999

		for i = 1, #shelfNames do
			local name = shelfNames[i]
			local width = shelfWidths[i]
			local x = getProperty(name .. '.x') + width

			if x > max then max = x end
		end

		return max
	end

	function startSwaying()
		doTweenX('swayRight', 'boyfriend', centerX + swayAmount, swaySpeed, 'smootherStepOut')
		runTimer('swayTimer', swaySpeed, 1)
	end

	function resetShelves(spriteName)
		setProperty(spriteName..'.x', screenWidth + getProperty(spriteName..'.width'))
	end


-- SCARED & TRANSITION

	function scaredShit()
		
		makeLuaSprite('bg-scared', trans..'scared-BG', -200, 150); -- x 0, y 100
		setScrollFactor('bg-scared', 0.4, 0.5);
		addLuaSprite('bg-scared', false);
		scaleObject('bg-scared', '1.2','1.2');
		
		makeAnimatedLuaSprite('parents', trans..'parents', 300, 200);
		addLuaSprite('parents', false);
		setScrollFactor('parents', 0.7, 0.6);
		scaleObject('parents', '0.9','0.9');
		setProperty('parents.visible', true)
		setProperty('parents.alpha', 0)
		
		makeLuaSprite('fg-scared', trans..'scared-FG', 50, 650); -- x 180, y 400
		setScrollFactor('fg-scared', 0.9, 0.7);
		addLuaSprite('fg-scared', false);
		scaleObject('fg-scared', '1','1.2');

		makeAnimatedLuaSprite('scared', trans..'scaredLadies', 300,820);
		addLuaSprite('scared', false);
		setScrollFactor('scared', 0.9, 0.7);
		setProperty('scared.visible', true)

		runTimer('moveJasLucy', 1)

		runTimer('revealParents', 1.5)
		runTimer('shakeIt-1', 3.1)
		runTimer('zoomIn', 4)
		runTimer('shakeIt-2', 4.3)
		runTimer('removeScared', 5)
		
	end

	function addTransitionStage()

		makeLuaSprite('t_bg', trans..'trans_BG', 450, 110);
		setScrollFactor('t_bg', 0.4, 0.7);
		addLuaSprite('t_bg', false);
		scaleObject('t_bg', '1.15','1.1');

		makeLuaSprite('t_floor', trans..'trans_floor', 550, 550);
		setScrollFactor('t_floor', 0.45, 0.7);
		addLuaSprite('t_floor', false);
		scaleObject('t_floor', '1.1','1.1');

		makeLuaSprite('t_shelf', trans..'trans_shelf', -150, 100);
		setScrollFactor('t_shelf', 0.45, 0.7);
		addLuaSprite('t_shelf', false);
		scaleObject('t_shelf', '1.2','1.1');

		makeLuaSprite('t_box', trans..'trans_boxes', 1200, 500);
		setScrollFactor('t_box', 0.56, 0.7);
		addLuaSprite('t_box', false);
		scaleObject('t_box', '1.1','1.1');

		makeAnimatedLuaSprite('lucy', trans..'lucy', 150, 240); --0
		addLuaSprite('lucy', false);
		setScrollFactor('lucy', 0.9, 0.7);
		setProperty('lucy.visible', true)

		makeAnimatedLuaSprite('boxbg', trans..'boxBG', -730,-200);
		addLuaSprite('boxbg', false);
		setScrollFactor('boxbg', 0.9, 0.7);
		setProperty('boxbg.visible', true)

		makeAnimatedLuaSprite('jasmin', trans..'jasmine', 0, 0);
		addLuaSprite('jasmin', false);
		setScrollFactor('jasmin', 0.9, 0.7);
		setProperty('jasmin.visible', true)

		makeAnimatedLuaSprite('boxfg', trans..'boxFG', -400,-200);
		addLuaSprite('boxfg', false);
		setScrollFactor('boxfg', 0.9, 0.7);
		setProperty('boxfg.visible', true)

		playSound(sounds.. 'inter_transition', 0.8, 'transition_1')

		runTimer('cameraMove', 0.1)
		runTimer('hitAnimation', 0.2)
		runTimer('jasmineShake', 0.7)
		runTimer('lucyShake', 1.4)
		runTimer('removeTransition', 3.5)


	end
-- SECOND STAGE

	function addSecondStageFR()

		makeLuaSprite('bg2', stage2..'shelfBG', -100, 126);
		setScrollFactor('bg2', 0.8, 0.8);
		addLuaSprite('bg2', false);
		scaleObject('bg2', '1.2','1.1');

		makeAnimatedLuaSprite('lucyAlt', stage2..'LUCY', 34, 152);
		setScrollFactor('lucyAlt', 0.9, 0.9);
		addLuaSprite('lucyAlt', true);

		makeAnimatedLuaSprite('jasmineAlt', stage2..'JASMINE', 825, 362); -- 825, 382
		setScrollFactor('jasmineAlt', 0.9, 0.9);
		addLuaSprite('jasmineAlt', true);

		setProperty('lucyAlt.visible', false)
		setProperty('jasmineAlt.visible', false)

		makeLuaSprite('shadow', stage2..'shadow_1', -220, 230);
		setScrollFactor('shadow', 1.8, 1.3);
		addLuaSprite('shadow', true);
		scaleObject('shadow', '1.45','1.15');
		setBlendMode('shadow', 'MULTIPLY')
		setProperty('shadow.alpha', 0.8)

		makeLuaSprite('overlay2', stage2..'overlay_1', -22, 280); --52
		setScrollFactor('overlay2', 1.8, 1.3);
		addLuaSprite('overlay2', true);
		scaleObject('overlay2', '1.2','1.2');
		setBlendMode('overlay2', 'SCREEN')

		makeLuaSprite('boxFG', stage2..'boxFG', -170, 256);
		setScrollFactor('boxFG', 1.8, 1.4);
		addLuaSprite('boxFG', true);
		scaleObject('boxFG', '1.4','1.2');

		makeLuaSprite('overlay_two', '', -300, -100); -- tint
		setScrollFactor('overlay_two', 0, 0);
		addLuaSprite('overlay_two', true);
		scaleObject('overlay_two', '1','1');
		setBlendMode('overlay_two', 'MULTIPLY')
		scaleObject('overlay_two', '1.5','1.4');
		makeGraphic('overlay_two', screenWidth, screenHeight, '32CEEE')
		setProperty('overlay_two.alpha', 0.85)

		shadowFlick()

		makeAnimatedLuaSprite('ddHands', stage2..'DDHANDS', 725, 402); -- 825, 382
		setBlendMode('ddHands', 'SCREEN')
		setScrollFactor('ddHands', 0.9, 0.9);
		addLuaSprite('ddHands', true);

		makeAnimatedLuaSprite('mmHands', stage2..'MMHANDS', 55, 162); -- 825, 382
		setBlendMode('mmHands', 'SCREEN')
		setScrollFactor('mmHands', 0.9, 0.9);
		addLuaSprite('mmHands', true);

		setProperty('mmHands.visible', false)
		setProperty('ddHands.visible', false)

		makeLuaSprite('hidingIcon', hud..'4-hudShit/SCREAM', 0, 0) 
		setScrollFactor('hidingIcon', 0, 0)
		scaleObject('hidingIcon', 0.8, 0.8)
		addLuaSprite('hidingIcon', true)
		setProperty('hidingIcon.x', screenWidth - getProperty('hidingIcon.width') - 50)

		if downscroll then
			setProperty('hidingIcon.y', screenHeight - getProperty('hidingIcon.height') - 50)
		else
			setProperty('hidingIcon.y', 100)
		end

		makeLuaText('noiseCount', '', 100, 120, 55)
		setTextSize('noiseCount', 32)
		setTextColor('noiseCount', 'FFFFFF')
		setTextBorder('noiseCount', 2, '000000')
		setScrollFactor('noiseCount', 0, 0)
		addLuaText('noiseCount')
		setProperty('noiseCount.x', getProperty('hidingIcon.x') + (getProperty('hidingIcon.width')/2) - (getProperty('noiseCount.width')/2))
		setProperty('noiseCount.y', getProperty('hidingIcon.y') - 5)

		setObjectCamera('hidingIcon', 'camHUD')
		setObjectCamera('noiseCount', 'camHUD')

		makeLuaSprite('progressBar', hud..'4-hudShit/BAR', barX - 10, barY + 48)
		setScrollFactor('progressBar', 0, 0)
		setObjectCamera('progressBar', 'hud')
		addLuaSprite('progressBar', true) 

		makeLuaSprite('curvedBar', hud..'4-hudShit/SCREAM-BAR', barX - 15, barY - 2)
		setScrollFactor('curvedBar', 0, 0)
		setObjectCamera('curvedBar', 'hud')
		addLuaSprite('curvedBar', true) 

		doTweenAlpha('byebye', 'camHUD', 1, 2, 'smootherStepIn')

		for i = 0, getProperty('strumLineNotes.length')-1 do
			noteTweenAlpha('fadeN'..i, i, 0.5, 1, 'linear')
		end

		setProperty('curvedBar.alpha', 0)
		setProperty('progressBar.alpha', 0)
		setProperty('defaultCamZoom', closeZoom)
		setProperty(camTargetName..'.x', lucyCamX)
		setProperty(camTargetName..'.y', lucyCamY)
		triggerEvent('Camera Follow Pos', lucyCamX, lucyCamY)

		manualCam = true
		forceCam = true
		startPan = false
		doSecondStagePan = false
		noiseActive = true
		noiseMisses = 0
		noiseFailed = false
		setNoiseDanger(false)

		initLuaShader(shaderName)
		setSpriteShader('progressBar', shaderName)
		setBarProgress(0)
		
	end

	function shadowFlick()

		local baseAlpha = 0.8
		local range = 0.08
		local targetAlpha = baseAlpha + (math.random() * range * 2 - range)

		local dur = 0.08 + math.random() * 0.10

		doTweenAlpha('shadowFlicker', 'shadow', targetAlpha, dur, 'quadInOut')
	end

	function enterPanicMode()

		addAnimationByPrefix('jasmineAlt', 'idle', 'jasmineStartleLoop', 24, true)
		addAnimationByPrefix('jasmineAlt', 'intro', 'jasStartled', 24, false)
		addAnimationByPrefix('lucyAlt', 'idle', 'lucyStartleLoop', 24, true)
		addAnimationByPrefix('lucyAlt', 'intro', 'lucyStartle0', 24, false)
		
		addAnimationByPrefix('mmHands', 'grab', 'MM HANDS', 24, false)
		addAnimationByPrefix('ddHands', 'kill', 'DD HANDS',24, false)
		
		playAnim('lucyAlt', 'intro', true)
		playAnim('jasmineAlt', 'intro', true)

		runTimer('idleAnim', 1)
		startSmoothShake(8, 13)

		setProperty('lucyAlt.visible', true)
		setProperty('jasmineAlt.visible', true)
		setProperty('mmHands.visible', true)
		setProperty('ddHands.visible', true)

		playSound(sounds.. 'inter_GRAB', 0.6, 'grabbing')

		noiseActive = false
		forceCam = true
		manualCam = false
		cameraMiddle = true
		setProperty('boyfriend.alpha', 0)
		setProperty('dad.alpha', 0)
	end

	function killLucyJasmine()

		addAnimationByPrefix('jasmineAlt', 'kill', 'SNAP', 24, false)
		addAnimationByPrefix('lucyAlt', 'kill', 'SNAP', 24, false)
		addAnimationByPrefix('mmHands', 'grab', 'MM-SNAP', 24, false)
		addAnimationByPrefix('ddHands', 'kill', 'DD-SNAP',24, false)

		playAnim('lucyAlt', 'kill', true)
		playAnim('jasmineAlt', 'kill', true)
		playAnim('ddHands', 'kill', true)
		playAnim('mmHands', 'kill', true)

		cameraShake(0.6, 0.5)

		for i = 0, getProperty('strumLineNotes.length')-1 do -- even the notes react to ur death lol
			local x = getPropertyFromGroup('strumLineNotes', i, 'x')
			local y = getPropertyFromGroup('strumLineNotes', i, 'y')

			local offX = (math.random() * 400) - 200
			local offY = (math.random() * 200) - 100
			local ang  = math.random(-90, 90)

			noteTweenX('boomX'..i, i, x + offX, 0.4, 'circOut')
			noteTweenY('boomY'..i, i, y + offY, 0.4, 'circOut')
			noteTweenAngle('boomA'..i, i, ang, 0.4, 'quadOut')

			noteTweenAlpha('boomF'..i, i, 0, 1, 'linear')
		end

		playSound(sounds..'inter_SNAP')
		runHaxeCode([[
		FlxG.sound.music.fadeOut(0.2, 0.4); // fade to volume 0.2 over 0.2 seconds
		]]);

		doTweenZoom('shockKill', 'camGame', 0.95, 0.4, 'circOut')
		doTweenAngle('shockKill2', 'camGame', 2, 0.8, 'circOut')
		runTimer('killThem', 1)

	end

	function liveLucyJasmine()

		doTweenAlpha('hudGone', 'camHUD', 0, 1, 'quadOut')

		addAnimationByPrefix('jasmineAlt', 'end', 'JAMSINE-END', 24, false)
		addAnimationByPrefix('lucyAlt', 'end', 'LUCY-END', 24, false)

		playAnim('lucyAlt', 'end', true)
		playAnim('jasmineAlt', 'end', true)

		runTimer('jasmineFade', 4)
		runTimer('focusJasmineEnding',2.5)

	end

	function setNoiseDanger(state)
		noiseDanger = state
		noiseDangerT = 0

		if not luaSpriteExists('hidingIcon') then return end

		if state then
			setProperty('hidingIcon.color', getColorFromHex('FF2B2B'))
			setProperty('noiseCount.color', getColorFromHex('FF2B2B'))
		else
			setProperty('hidingIcon.color', getColorFromHex('FFFFFF'))
			setProperty('noiseCount.color', getColorFromHex('FFFFFF'))

			setProperty('hidingIcon.alpha', 1)
			setProperty('noiseCount.alpha', 1)
			setProperty('noiseCount.scale.x', 1)
			setProperty('noiseCount.scale.y', 1)
		end
	end

	function updateNoiseDanger(elapsed)
		if not noiseDanger then return end
		if not luaSpriteExists('hidingIcon') then return end

		noiseDangerT = noiseDangerT + elapsed

		local pulseIcon = 1 + (math.sin(noiseDangerT * 8) * 0.10)
		local pulseText = 1 + (math.sin(noiseDangerT * 8) * 0.12) 
		local flash = 0.65 + (math.sin(noiseDangerT * 12) * 0.66) 

		setProperty('noiseCount.scale.x', 1 * pulseText)
		setProperty('noiseCount.scale.y', 1 * pulseText)

		setProperty('hidingIcon.alpha', flash)
		setProperty('noiseCount.alpha', flash)
	end


-- MISC FUNCTIONS

	function letterBox(duration,time) 
		doTweenY('clip1Move', 'clipTop', 0, duration, 'smootherStepIn')
		doTweenY('clip2Move', 'clipBottom', screenHeight - 35, duration, 'smootherStepIn')
	end
	function letterBoxOut(duration,time) 
		doTweenY('clip1Move', 'clipTop', -35, duration, 'smootherStepIn')
		doTweenY('clip2Move', 'clipBottom', screenHeight, duration, 'smootherStepIn')
		doTweenAlpha('hellohello', 'camHUD', 1, time, 'circOut')
	end

	function startSmoothShake(strength, duration, cam)
		shakeCam = cam or 'camGame'
		shakeStrength = strength or 5
		shakeDuration = duration or 0.5
		shakeTime = shakeDuration
		isShaking = true
	end

	function triggerBlur()
		blurAlpha = 2 -- reset
		blurActive = true
	end

	function lerp(a, b, t)
		return a + (b - a) * t
	end

	function phoneCall()
		
		runTimer('movePhoneIn', 2,1);
		runTimer('showText', 2.5,1);

	
		local eggRoll = getRandomInt(1, 100)

		if eggRoll <= 15 then
			callNum = 4
		elseif eggRoll <= 30 then
			callNum = 5
		else
			callNum = getRandomInt(1, 3)
		end

		currentPhoneCall = callNum
		local subtitlesText = {
			[1] = "GF: You guys know what to do right? Supplies girls... supplies. Once you get that, come on right back so we can continue to step 2. Don't die please.",
			[2] = "GF: Don't forget yall, we need eggs, milk, soda... you know the rest, girlies. Just be careful out there, they might be watching...",
			[3] = "GF: Calling you guys so you just remember, we need FOOD, y'all! Hurry up and get what we need and make it back... ALIVE. THANK YOU.",
			[4] = "Unknown: This is for Rachel you big fat white nasty smelling fat bitch why you took me off the motherfucking schedule with your trifling dirty white racist ass you big fat bitch oomp-",
			[5] = "Unknown: Heyyyy Jasmine... ummmmmm I'm just calling to say... start digging in yo butt twinnnn!"
		}

		local callLengths = {
			[1] = 10,
			[2] = 10,
			[3] = 10,
			[4] = 12,
			[5] = 10
		}

		local callLength = callLengths[callNum]

		local phoneSprite = 'phone_gf'
		if callNum == 4 or callNum == 5 then
			phoneSprite = 'phone_unknown'
		end

		makeLuaSprite('phone', hud..'4-hudShit/phone/'..phoneSprite, -250, 200)
		setScrollFactor('phone', 0, 0)
		scaleObject('phone', '0.6','0.6')
		addLuaSprite('phone', true)
		setObjectCamera('phone', 'other')

		makeLuaText('subtitles', '', 300, 70, 320)
		setTextFont('subtitles', 'veteran typewriter.ttf')
		setTextAlignment('subtitles', 'left')
		setObjectCamera('subtitles', 'other')
		setTextSize('subtitles', 20)
		setTextString('subtitles', subtitlesText[callNum])
		setTextBorder('subtitles', 1, 'f566cc')
		setProperty('subtitles.visible', true)
		setProperty('subtitles.alpha', 0)
		addLuaText('subtitles')

		playSound(sounds .. 'inter_gfCall-' .. callNum, 1, 'call-' .. callNum)

		runHaxeCode([[
			FlxG.sound.music.fadeOut(1, 0.2);
		]])

		runTimer('restoreMusic', callLength)
		runTimer('fadeText', callLength - 1, 1)
		runTimer('movePhoneOut', callLength, 1)
		
	end

	function progressBarShow()
		doTweenX('moveInP', 'curvedBar', barX - 18, 0.5, 'smootherStepInOut')
		doTweenX('moveInC', 'progressBar', barX - 10, 0.5, 'smootherStepInOut')

		doTweenAlpha('fadeInC', 'curvedBar', 1, 1, 'smootherStepInOut')
		doTweenAlpha('fadeInP', 'progressBar', 1, 1, 'smootherStepInOut')

	end

	function flashGrab(duration, whiteAlpha)
		if duration == nil then duration = 0.8 end
		if whiteAlpha == nil then whiteAlpha = 0 end

		runHaxeCode([[
			import flixel.FlxG;
			import flixel.FlxSprite;
			import flixel.tweens.FlxTween;
			import flixel.tweens.FlxEase;
			import lime.app.Application;
			import openfl.display.BitmapData;
			import openfl.geom.Rectangle;
			import openfl.geom.Matrix;

			var win = Application.current.window;
			if (win == null) return;

			var w:Int = Std.int(win.width);
			var h:Int = Std.int(win.height);

			var img = win.readPixels(new Rectangle(0, 0, w, h));
			if (img == null) return;

			var shotWin = BitmapData.fromImage(img);

			var gw = FlxG.width;
			var gh = FlxG.height;
			var shotGame = new BitmapData(gw, gh, true, 0x00000000);
			var m = new Matrix();
			m.scale(gw / w, gh / h);
			shotGame.draw(shotWin, m, null, null, null, true);

			var overlay = new FlxSprite(0, 0);
			overlay.loadGraphic(shotGame);
			overlay.scrollFactor.set();
			overlay.cameras = [game.camOther];
			overlay.alpha = 1;
			game.add(overlay);

			var whiteAlpha:Float = ]] .. tostring(whiteAlpha) .. [[;
			var white:FlxSprite = null;
			if (whiteAlpha > 0) {
				white = new FlxSprite(-1, -1).makeGraphic(gw + 2, gh + 2, 0xFFFFFFFF);
				white.cameras = [game.camOther];
				white.alpha = whiteAlpha;
				game.add(white);
			}

			FlxTween.tween(overlay, { alpha: 0 }, ]] .. tostring(duration) .. [[, {
				ease: FlxEase.quadOut,
				onComplete: _ -> { overlay.kill(); overlay.destroy(); }
			});

			if (white != null) {
				FlxTween.tween(white, { alpha: 0 }, ]] .. tostring(duration * 0.6) .. [[, {
					ease: FlxEase.quadOut,
					onComplete: _ -> { white.kill(); white.destroy(); }
				});
			}
		]])
	end

	local function clamp01(x)
		return x < 0 and 0 or (x > 1 and 1 or x)
	end

	function setHaloProgress(p, hits, goal)
		setShaderFloat(BAR_ID, 'u_progress', clamp01(p or 0))

		-- if hits ~= nil then haloHits = hits end
		-- if goal ~= nil then haloNoteTotal = goal end

		if hits ~= nil then haloHits = hits end
		if total ~= nil then haloNoteTotal = total end
		if needed ~= nil then haloNeeded = needed end

	end

	function onSongStart()
		dialogueDone = true
	end

-- DIALOGUE

function onNextDialogue(lineNum)
	if lineNum == 1 then
		playSound(sounds..'dumbasskid', 1, 'kid')
	end

	if lineNum == 2 then
		stopSound('kid')
		cameraShake('camFilm', 0.003, 0.4)
	end

    if lineNum == 7 then

		local wow = getRandomInt(1, 6)
		playSound(sounds..'closeup-'..wow, 0.7, 'effectKid')

        cameraFlash('other', 'FFFFFF', 3)
		
		runHaxeCode([[
            FlxG.sound.music.fadeOut(1, 0, 0.5); // fade to volume 1 over 0.4 seconds
        ]])
    end

	if lineNum == 8 then
		stopSound('effectKid')
		runHaxeCode([[
            FlxG.sound.music.fadeIn(1, 0, 2); // fade to volume 1 over 0.4 seconds
        ]])
    end
end

function runIntroStuff()
	if hasIntroStarted then return end
	hasIntroStarted = true

	if isFirstStage then
		setProperty('boyfriend.x', getProperty('boyfriend.x') - 600)
		setProperty('dad.x', getProperty('dad.x') - 1300)

		runTimer('startIntro', 1.5)

	end
end

function onStartCountdown()

	if isStoryMode and not allowCountdown and songName == 'intervention' then
		if doDialogue and not seenCutscene then
			
			startDialogue('interventionShit', 'dialogueMusic/interventionDia')  
	
			doDialogue = false
			allowCountdown = true;
			
			return Function_Stop;
		end
		return Function_Continue
	end

	if songName == 'intervention' and not isStoryMode and doIntro then
		if not allowCountdown then
			return Function_Stop
		end

		if allowCountdown then
			return Function_Continue
		end
	end

end

-- ===================
-- REMOVING & ADDING ASSETS 
-- ===================
function removeStageSpritesOne()

	removeLuaSprite('daPeep', true)
	removeLuaSprite('daPeepBG', true)

	canSpawnNPC = false
	canSpawnNPC2 = false

    for i = 1, #spritesToRemove do
        removeLuaSprite(spritesToRemove[i], true)
    end

	for i = 1, #shelfNames do
		removeLuaSprite(shelfNames[i], true)
	end
end

function removeStageSpritesTwo()
    for i = 1, #spritesToRemove2 do
        removeLuaSprite(spritesToRemove2[i], true)
    end
end

function removeStageTransition()
    for i = 1, #spritesToRemove3 do
        removeLuaSprite(spritesToRemove3[i], true)
    end
end

function spawnRandomPeep() -- spawns in characters in the fg
	if not canSpawnNPC then return end
	local chosen = peopleSprites[getRandomInt(1, #peopleSprites)]

	if lastPeep ~= nil and #peopleSprites > 1 then
	for i = 1, 3 do
		if chosen ~= lastPeep then break end
		chosen = peopleSprites[getRandomInt(1, #peopleSprites)]
	end
	end
	lastPeep = chosen

	makeAnimatedLuaSprite('daPeep', stage..'peeps/' .. chosen, 2700, 250);
	addAnimationByPrefix('daPeep', 'walk', chosen, 18, true)
	playAnim('daPeep', 'walk', true)
	setScrollFactor('daPeep', 1.4, 0.9);
	addLuaSprite('daPeep', true);
	scaleObject('daPeep', '1','1');

	canSpawnNPC = false
end

function spawnRandomPeepBG()
	if not canSpawnNPC2 then return end

	local chosen2 = bgPeopleSprites[getRandomInt(1, #bgPeopleSprites)]
	if lastPeepBG ~= nil and #bgPeopleSprites > 1 then
		for i = 1, 4 do
			if chosen2 ~= lastPeepBG then break end
			chosen2 = bgPeopleSprites[getRandomInt(1, #bgPeopleSprites)]
		end
	end
	lastPeepBG = chosen2

	loadGraphic('daPeepBG', stage..'peeps/BG/' .. chosen2)
    updateHitbox('daPeepBG')
	setProperty('daPeepBG.x', 2200)
	setProperty('daPeepBG.alpha', 1)
	setScrollFactor('daPeepBG', 0.85, 0.9);
	addLuaSprite('daPeepBG', false);
	
	local peepBGH = getProperty('daPeepBG.height')
	setProperty('daPeepBG.y', screenHeight - peepBGH + 150)

	local maxShelf = -99999
	for i = 1, #shelfNames do
	if luaSpriteExists(shelfNames[i]) then
		local o = getObjectOrder(shelfNames[i])
		if o > maxShelf then maxShelf = o end
		end
	end

	if maxShelf > -9000 then
		setObjectOrder('daPeepBG', maxShelf + 1)
	end

	canSpawnNPC2 = false
end

function focusLucy()
    if currentFocus == 'lucy' then return end
    currentFocus = 'lucy'
	camTransition = 'jasToLucy'

	doTweenZoom('cut_zoomOut_jasToLucy', 'camGame', midZoom, 0.4, 'quadOut')
	setProperty('defaultCamZoom', midZoom)

	triggerBlur()
end

function focusJasmine()
    if currentFocus == 'jas' then return end
    currentFocus = 'jas'
	camTransition = 'lucyToJas'

    doTweenZoom('cut_zoomOut_lucyToJas', 'camGame', midZoom, 0.4, 'quadOut')
	setProperty('defaultCamZoom', midZoom)

	triggerBlur()
end

stepHitFuncs = { 

	[5] = function()
		if phoneRings then
			phoneCall()
		end
	end,


	[816] = function() --113

		playSound(sounds.. 'inter_introTrans', 0.8, 'transition_intro')
		startSmoothShake(10, 1)
		scrollDirection = -1
		moveSpeed = 0
		stillLooping = false
	
		
	end,

	[826] = function() -- debris

		letterBox(1,1)
		doTweenAlpha('byebye', 'camHUD', 0, 1, 'smootherStepIn')

		cameraMiddle = true
		forceCam = true

		addAnimationByPrefix('debris', 'oops', 'DEBRISFALL', 20, false);

		runTimer('firstFade', 2)
		runTimer('removeStageOne', 2.5)
		runTimer('addScared', 3.5)
		
		triggerEvent('Play Animation', 'CONFUSED', 'Dad')
		triggerEvent('Play Animation', 'CONFUSED', 'Boyfriend')
	end,

	[1020] = function()
		showTooltip("Be careful. The Parents know you're here, so try not miss too many notes and keep your voice low.", 7)
	end,

	[1120] = function()

		showTooltip("However, they WILL sense you. Be sure to hit nearly all the white Halo Notes to continue holding your breathe so they don't know you're there... or risk being found.", 10)
	end,

	[1631] = function()
		noiseActive = false
		setNoiseDanger(false)

		progressBarShow()
		enterPanicMode()
	end,

	[1762] = function()

	 	--debugPrint('TOTAL AMOUNT HIT: '..haloHits..' / '..haloNoteTotal)

		if haloHits < haloNeeded then
			killLucyJasmine()
		else

			doTweenZoom('flashGrab', 'camGame', 1.5, 0.5, 'quadOut')
			runTimer('startEnding', 6)
		
			playAnim('ddHands', 'grab', true, true)
			playAnim('mmHands', 'grab', true, true)

			doTweenAlpha('fadeMom', 'mmHands', 0, 2, 'quadOut')
			doTweenAlpha('fadeDad', 'ddHands', 0, 2, 'quadOut')

		end

	end,


}

function onStepHit()
	if stepHitFuncs[curStep] then
		stepHitFuncs[curStep]()
	end

end

function onTimerCompleted(tag, loops, loopsLeft)
	if isFirstStage then
		if tag == 'swayTimer' and stillLooping then
			doTweenX('swayLeft', 'boyfriend', centerX - swayAmount, swaySpeed, 'smootherStepInOut')
			runTimer('swayBack', swaySpeed)
		end

		if tag == 'swayBack' and stillLooping then
			startSwaying()
		end

		if tag == 'startIntroMove' then
		
			doTweenX('swayLeft', 'boyfriend', centerX - swayAmount, 3, 'smootherStepInOut')
			doTweenX('dadIntro', 'dad', 800, 3, 'smootherStepInOut')
			runTimer('unfreezeShelves', 2.5)
		end

		if tag == 'startIntro' then
			spawnRandomPeep()
			spawnRandomPeepBG()
		end

		if tag == 'unfreezeShelves' then
			fridgeSpeedX = 0
			bgSpeedX = 0
			bgfrideSpeedX = 0
			beamSpeedX = 0
			moveSpeedX = 0
			peepSpeedX = 0
			shelvesFrozen = false

			scrollDirection = 1
			
			runTimer('enable', 2)

			doTweenZoom('toJasmine', 'camGame', '1.2', 3, 'smootherStepInOut')
			startSwaying()
			letterBoxOut(1.5) 
		end
	end

	if tag == 'enable' then
		doZoom = true
	end

	if tag == 'cameraMove' then
		followchars = false
		startPan = true
		forceCam = true
		setProperty('cameraSpeed', 0.1)
   end


-- AFTER LIGHT FLICKERS, JASMINE AND LUCY MOVES UP AND PARENTS COME IN

	if tag == 'addScared' then -- ADDS SCARED HOES
		isFirstStage = false
		isScared = true
		doZoom = false
	
		runTimer('removeFading', 0.5)

		setProperty('defaultCamZoom', 0.9) -- this is lucy
		doTweenZoom('backOut', 'camGame', '0.9', 0.2, 'circOut')
   	end

	if tag == 'moveJasLucy' then
	
		setProperty('defaultCamZoom', 1) -- this is lucy
		doTweenZoom('backOut', 'camGame', '1', 1, 'quadInOut')

		addAnimationByPrefix('scared', 'fuh', 'scaredShitless', 24, false);
	
		doTweenY('moveEm', 'scared', 300, 1.4, 'smootherStepOut')
		doTweenY('moveBG1', 'fg-scared', 420, 1.8, 'smootherStepOut')
		doTweenY('moveBG2', 'bg-scared', 50, 2.5, 'smootherStepOut')
    end

	if tag == 'revealParents' then
		addAnimationByPrefix('parents', 'fuh', 'parents', 24, false);
		doTweenY('moveParents', 'parents', 80, 1, 'smootherStepInOut')
		doTweenAlpha('showParents', 'parents', 1, 0.5, 'quadOut')
	
    end

	if tag == 'shakeIt-1' then
		cameraShake('camGame', 0.004, 0.3)
    end

	if tag == 'zoomIn' then
		
		doTweenZoom('emphasis', 'camGame', 1.2, 0.7, 'circOut')
		setProperty('defaultCamZoom',1.2)
    end

	if tag == 'shakeIt-2' then -- SCREAMMSSS
		cameraShake('camGame', 0.003, 2)
    end

	if tag == 'removeScared' then
		doTweenAlpha('addDark', 'darkness', 1, 0.2, 'quadOut') -- FADES BLACK
		runTimer('removeStageTwo', 0.5) 
		cameraMiddle = false
    end

	if tag == 'removeStageTwo' then -- REMOVES THE SCARED HOES
		runTimer('addTransition', 0.2)
		removeStageSpritesTwo() 
    end

	if tag == 'addTransition' then
		runTimer('removeFading', 0.5)
		isTransStage = true
    end

	if tag == 'removeFading' then
		doTweenAlpha('removeDark', 'darkness', 0, 0.5, 'quadOut') --FADES OUT BLACK
	end

	
-- TRANSITION HIT BOXES

	if tag == 'hitAnimation' then
		doTweenX('movaja', 'jasmin', -700, 2, 'smootherStepIn')
		addAnimationByPrefix('lucy', 'hit', 'LUCY_TRANS', 24, false);
		addAnimationByPrefix('boxbg', 'hit', 'boxBG', 24, false);
		addAnimationByPrefix('jasmin', 'hit', 'JASMINE_TRANS', 24, false);
		addAnimationByPrefix('boxfg', 'hit', 'boxFG', 24, false);
    end

	if tag == 'jasmineShake' then
		startSmoothShake(5, 1, 'camGame')
    elseif tag == 'lucyShake' then
		startSmoothShake(10, 2, 'camGame')
    end

	if tag == 'firstFade' then
		doTweenAlpha('addDark', 'darkness', 1, 0.5, 'quadOut')
    end

	if tag == 'removeStageOne' then -- REMOVES THE OG STAGE AND JASMINE AND LUCY
		removeStageSpritesOne()
		setProperty('boyfriend.alpha', 0)
		setProperty('dad.alpha', 0)
    end

	if tag == 'removeTransition' then
		doTweenAlpha('removeBlack', 'darkness', 1, 0.5, 'quadOut')
		
		runTimer('actuallyRemove', 0.5)
		runTimer('addSecondStage', 1)
   	end

	if tag == 'actuallyRemove' then
		removeStageTransition()
	end

	
-- SECOND STAGE
	
	if tag == 'addSecondStage' then
		isSecondStage = true
		doSecondStagePan = true
		phase = 2
		
		removeLuaSprite('overlay_one', true)
		setProperty('light2.alpha', 0)
		setProperty('boyfriend.alpha', 1)
		setProperty('dad.alpha', 1)

		triggerEvent('Change Character', 0, 'jasmine-market-2');
		triggerEvent('Change Character', 1, 'lucy-market-2');

		triggerBlur()

		setProperty('cameraSpeed', 1.5)
		runTimer('removeFading', 0.5)
    end

	if tag == 'camMoveQuickOut' then
		setProperty('cameraSpeed', 0.4)
		letterBoxOut(1,2)
    end

-- PANIC
	if tag == 'idleAnim' then
		playAnim('lucyAlt', 'idle', true)
		playAnim('jasmineAlt', 'idle', true)

		doZoom = false

		doTweenZoom('panic', 'camGame', 1.2, 1, 'circOut')
		setProperty('defaultCamZoom',1.2)
    end

	if tag == 'killThem' then
		cameraFlash('other', 'f22424', 0.5)
		setProperty('health', 0);
	end
	if tag == 'startEnding' then
		liveLucyJasmine()
	end
	if tag == 'jasmineFade' then
		doTweenAlpha('sheGone', 'jasmineAlt', 0, 2, 'quadOut')
	end
	if tag == 'focusJasmineEnding' then
		cameraMiddle = false
		manualCam = true
	end

-- MEHCHANIC PHONE
	if tag == 'restoreMusic' then
        runHaxeCode([[
            FlxG.sound.music.fadeIn(1, 0, 1); // fade to volume 1 over 0.4 seconds
        ]])
    end
-- MISC
	if tag == 'nextNPCSpawn' then
		canSpawnNPC = true
		spawnRandomPeep()
	end

	if tag == 'nextNPCSpawn2' then
		canSpawnNPC2 = true
		spawnRandomPeepBG()
	end

	if tag == 'removePreloadNessa' then
        removeLuaSprite('preloadNessa', true)
    end

-- INTRO

	if tag == 'introShow' then
		setProperty('intro.visible', true)
		playSound('0-JINGLES/intervention', 0.7, 'intro')

		doTweenAlpha('introInterFade', 'intro', 1, 1, 'quadOut')
	end

	if tag == 'getOuttaHere' then
		doTweenAlpha('delete', 'introHide', 0, 2, 'backIn')
		runTimer('startIntroMove', 1)
	end

	if tag == 'introFade' then
		doTweenAlpha('goodbyeIntro', 'intro', 0, 1, 'quadOut')
	end

	if tag == 'gameStart' then
		allowCountdown = true

		setProperty('cameraSpeed', 0.8)

		letterBoxOut(2,2)
		startCountdown()
	end

	-- ==================================================================
	-- PHONE
	-- ==================================================================
	if tag == 'movePhoneIn' then

		doTweenX('tweenPhone', 'phone', 50, 1, 'circOut');

	elseif tag == 'movePhoneOut' then

		doTweenX('tweenPhone', 'phone', -250, 1, 'circIn');
		phoneRings = false
	end

	if tag == 'showText' then
		
		doTweenAlpha('tweenText', 'subtitles', 50, 1, 'smootherStepIn');
		
	elseif tag == 'fadeText' then

		doTweenAlpha('tweenText', 'subtitles', 0, 1, 'smootherStepIn');

	end

	-- ==================================================================
	-- TOOLTIP
	-- ==================================================================
	if tag == 'tooltipHide' then
		doTweenAlpha('tooltipBG_out',  'tooltipBG',  0.0, 0.25, 'quadIn')
		doTweenAlpha('tooltipText_out','tooltipText',0.0, 0.25, 'quadIn')
   end

	-- ==================================================================
	-- MECHANIC
	-- ==================================================================
	if tag == 'noiseMissDo' then
      
		setProperty('vocals.volume', 1)
		setProperty('vocals.pitch', 1.2)
		runTimer('resetVocalPitch', 0.12)
     
		cameraShake('hud', 0.0010, 0.15)

		--debugPrint('NOISE MISSES: '..tostring(noiseMisses)..' / '..tostring(noiseLimit))

	elseif tag == 'resetVocalPitch' then
      setProperty('vocals.pitch', 1.0)
	end
end

function onTweenCompleted(tag, loops, loopsLeft)
    if tag == 'cut_zoomOut_lucyToJas' then
        doTweenX('cut_panX_lucyToJas', camTargetName, jasCamX, 0.5, 'quadInOut')
        doTweenY('cut_panY_lucyToJas', camTargetName, jasCamY, 0.5, 'quadInOut')

    elseif tag == 'cut_zoomOut_jasToLucy' then
        doTweenX('cut_panX_jasToLucy', camTargetName, lucyCamX, 0.5, 'quadInOut')
        doTweenY('cut_panY_jasToLucy', camTargetName, lucyCamY, 0.5, 'quadInOut')
    end

    if tag == 'cut_panY_lucyToJas' then
        doTweenZoom('cut_zoomIn_jas', 'camGame', closeZoom, 0.45, 'circIn')
		setProperty('defaultCamZoom', closeZoom)

    elseif tag == 'cut_panY_jasToLucy' then
        doTweenZoom('cut_zoomIn_lucy', 'camGame', closeZoom, 0.45, 'circIn')
		setProperty('defaultCamZoom', closeZoom)
    end

	if tag == 'shadowFlicker' then
        shadowFlick()
   end

	if tag == 'flashGrab' then
		flashGrab(1,1)
		setProperty('curvedBar.alpha', 0)
		setProperty('progressBar.alpha', 0)
		doTweenZoom('reset', 'camGame', 1.25, 2, 'quadOut')
	end
end

function noteMiss(id, i, noteType, isSustainNote)
   	if not noiseActive or isSustainNote then return end

   	noiseMisses = noiseMisses + 1
	runTimer('noiseMissDo', 0.0)

	if noiseMisses >= noiseWarnAt and noiseMisses < noiseLimit then
		setNoiseDanger(true)
	end

	if noiseMisses >= noiseLimit and not noiseFailed then
		noiseFailed = true
		noiseActive = false
		setNoiseDanger(false)

		setProperty('health', 0)
	end
end

function onGameOver()
	scrollDirection = -1
	cameraMiddle = false
	isSecondStage = false
	manualCam = false
	setProperty('camGame.angle', 0)
	setProperty('camGame.zoom', 1)
	cameraShake(0, 0)

	return Function_Continue
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

function onPause()
	pauseSound('transition_intro')
	pauseSound('transition_1')
	pauseSound('grabbing')
	pauseSound('peaceOut')
	pauseSound('tool')

	pauseSound('call-' .. callNum)
end

function onResume()
	resumeSound('transition_intro')
	resumeSound('transition_1')
	resumeSound('grabbing')
	resumeSound('peaceOut')
	resumeSound('call-1')
	resumeSound('call-2')
	resumeSound('call-3')
	resumeSound('tool')
end