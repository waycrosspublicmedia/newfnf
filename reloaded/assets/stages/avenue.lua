local lightColor = getColorFromHex('7ae6e3')  -- victoria

local xx, yy = 740, 570; -- nikku
local xx2, yy2 = 1050, 600; -- jasmine
local ofs, ofs2 = 25, 45;
local followchars, forceCam = false, false
local doZoom, doIntro = false, true;
local zoomDad, zoomJas = 0.85, 1
local i = 0;

local isTestingMode = true
local isFirstStage, isTransStage, isVictoriaS = true, false, false;


local victoriaMade = false



local stage = 'stages/week10/avenue/'
local stage2 = 'stages/week10/victoria/'
local hud = 'stages/hudelements/4-hudShit/'
local fog = 'stages/week3/stripClub/'
local sounds = 'WEEK2/'

local speedTrans3Y = '0.1'
local speedTrans3X = '0.1'

local BEHIND_TAG  = 'screenBG'   -- hearts above this
local INFRONT_TAG = 'interior' 

local HEART1_TEX = stage2..'screen/heart-1'
local HEART2_TEX = stage2..'screen/heart-2'
local HEART3_TEX = stage2..'screen/heart-3'

local X_MIN, X_MAX = 140, 520
local START_Y = 760       -- start from below
local TOP_Y = -100 

local h1x,h1y,h1vx,h1vy = 0,0,0,0
local h2x,h2y,h2vx,h2vy = 0,0,0,0
local h3x,h3y,h3vx,h3vy = 0,0,0,0
local h4x,h4y,h4vx,h4vy = 0,0,0,0

--SHAKE & BLUR & WOBBLE
local shakeDuration, shakeTime, shakeStrength, doShake = 0, 0, 0, false
local blurAlpha, blurActive = 1, false
--typing
local fullTypedText = "3. Jasmine Cortez."
local currentTypedText = ""
local typedIndex, typedSpeed, typedTimer, isTypingText = 0, 0.04, 0, false
local attached = false
--removing stages
local spritesToRemove = {'sky', 'bg2', 'street', 'building', 'pole-1', 'light-1', 'pole-2', 'light-2', 'ground', 'tv', 'bills', 'fog1', 'fog2', 'fog3'}
local spritesToRemove2 = {'transBG', 'transSmoke', 'jazz', 'fogTrans', 'fogTrans2'}

function onCreatePost() 
	
	addCharacterToList('jasmineswitch', 'bf')
	addCharacterToList('nikkuswitch', 'dad')

	precacheImage(hud..'intros/intro_dsm')
	precacheImage(stage..'moneyFly')

	precacheImage(fog..'TEST/FOG-1')
	precacheImage(fog..'TEST/FOG-3')
	precacheSound(sounds.. 'machi_trans') 

	precacheImage(stage..'TRANSITION/trans-bgSmoke')
	precacheImage(stage..'TRANSITION/trans-bg')
	precacheImage(stage..'TRANSITION/JASMINE')
	precacheImage(stage..'TRANSITION/fgSmoke')

	setProperty('gf.visible', false)
	setProperty('dad.scrollFactor.x', 0.9);
	setProperty('dad.scrollFactor.y', 0.9);
	setProperty('boyfriend.scrollFactor.x', 0.9);
	setProperty('boyfriend.scrollFactor.y', 0.9);


	if doIntro then
		if not seenCutscene then
			forceCam = true
			followchars = false
			doZoom = false

			camY = -300
			camX = 800
		else
			followchars = true
			doZoom = true
		end
	end
end


function onCreate()

	--cameraShit
	camX = 'camFollow.x';	
	camY = 'camFollow.y';


	makeLuaSprite('sky', stage.. 'SKY', -430, -200);
	setScrollFactor('sky', 0.3, 0.7);
	addLuaSprite('sky', false);
	scaleObject('sky', '1.3','1.2');

	makeLuaSprite('bg2', stage.. 'BG_TREES', 410, -50);
	setScrollFactor('bg2', 0.6, 0.8);
	addLuaSprite('bg2', false);
	scaleObject('bg2', '1.1','1.1');

	makeLuaSprite('street', stage.. 'BG_GROUND', -480, 630);
	setScrollFactor('street', 0.85, 0.9);
	addLuaSprite('street', false);
	scaleObject('street', '1.3','1');

	makeLuaSprite('building', stage.. 'BG_BUILDINGS', -480, -130);
	setScrollFactor('building', 0.85, 0.9);
	addLuaSprite('building', false);
	scaleObject('building', '1.3','1');

	makeLuaSprite('pole-1', stage.. 'BG_POLE', -485, -230);
	setScrollFactor('pole-1', 0.85, 0.9);
	addLuaSprite('pole-1', false);
	scaleObject('pole-1', '1.3','1');

	makeLuaSprite('light-1', stage.. 'LIGHT_POLE', 510, 135);
	setScrollFactor('light-1', 0.85, 0.9);
	addLuaSprite('light-1', false);
	scaleObject('light-1', '1.3','1');
	setBlendMode('light-1', 'SCREEN')

	makeLuaSprite('pole-2', stage.. 'BG_POLE', 1165, -230);
	setScrollFactor('pole-2', 0.85, 0.9);
	addLuaSprite('pole-2', false);
	setProperty('pole-2.flipX', true)
	scaleObject('pole-2', '1.3','1');

	makeLuaSprite('light-2', stage.. 'LIGHT_POLE', 1110, 135);
	setScrollFactor('light-2', 0.85, 0.9);
	addLuaSprite('light-2', false);
	setProperty('light-2.flipX', true)
	scaleObject('light-2', '1.3','1');
	setBlendMode('light-2', 'SCREEN')

	makeLuaSprite('ground', stage.. 'FG_CAR', -370, 800);
	setScrollFactor('ground', 0.9, 0.9);
	addLuaSprite('ground', false);
	scaleObject('ground', '1.2','1.2');

	makeAnimatedLuaSprite('bills', stage..'moneyFly', 830, 300) 
	setScrollFactor('bills', 0.9, 0.9);
	scaleObject('bills', '1','1');
	objectPlayAnimation('bills', 'flexing', false)
	setProperty('bills.visible', false)
	addLuaSprite('bills', true)

	if enableFog then
		makeLuaSprite('fog1', fog..'TEST/FOG-1', 0, 650);
		setScrollFactor('fog1', 1.1, 1.3);
		addLuaSprite('fog1', true);
		scaleObject('fog1', '1.1','1.1');
		setBlendMode('fog1', 'SCREEN')
		setProperty('fog1.x', -screenWidth - (getProperty('fog1.width')/2))

		makeLuaSprite('fog2', fog..'TEST/FOG-2', 0, 550);
		setScrollFactor('fog2', 1.3, 1.2);
		addLuaSprite('fog2', true);
		scaleObject('fog2', '1.8','1.4');
		setBlendMode('fog2', 'SCREEN')
		setProperty('fog2.alpha', 0.4)
		setProperty('fog2.x', -screenWidth - (getProperty('fog2.width')/4))

		makeLuaSprite('fog3', fog..'TEST/FOG-3', 0, 250);
		setScrollFactor('fog3', 1.1, 1.3);
		addLuaSprite('fog3', true);
		scaleObject('fog3', '1.2','1.3');
		setBlendMode('fog3', 'SCREEN')
		setProperty('fog3.x', -screenWidth + (getProperty('fog3.width')/2))

		fogColor = getColorFromHex('e0e6fa') 
		fogColor2 = getColorFromHex('96a3d1')

		setProperty('fog1.color', fogColor)
		setProperty('fog2.color', fogColor)
		setProperty('fog3.color', fogColor2)

		speed1 = '0.4'
		speed2 = '0.8'
		speed3 = '0.2'

	end

	makeLuaSprite('transBG', stage.. 'TRANSITION/trans-bg', -150, -100);
	setScrollFactor('transBG', 0, 0);
	scaleObject('transBG', '1.2','1.2');

	makeLuaSprite('transSmoke', stage.. 'TRANSITION/trans-bgSmoke', -200, 50);
	setScrollFactor('transSmoke', 0.4, 0.4);
	scaleObject('transSmoke', '1.4','1.4');

	makeAnimatedLuaSprite('jazz', stage.. 'TRANSITION/JASMINE', 450, -1000) -- og Y is 0, X 380
	setScrollFactor('jazz', 0.9, 0.9);
	scaleObject('jazz', '1','1');
	
	makeLuaSprite('fogTrans', fog..'TEST/FOG-1', 0, 0); -- back
	setScrollFactor('fogTrans', 1.3, 1.3);
	scaleObject('fogTrans', '2','1.4');
	setBlendMode('fogTrans', 'SCREEN')
	setProperty('fogTrans.x', -900)
	setProperty('fogTrans.y', screenHeight - (getProperty('fogTrans.height')/2))
	setProperty('fogTrans.alpha', 0.2)
	setProperty('fogTrans.angle', -45)

	makeLuaSprite('fogTrans2', fog..'TEST/FOG-3', 0, 0); -- front
	setScrollFactor('fogTrans2', 1.3, 1.3);
	scaleObject('fogTrans2', '3.5','2.1');
	setBlendMode('fogTrans2', 'SCREEN')
	setProperty('fogTrans2.x', 3000)
	setProperty('fogTrans2.y', screenHeight - (getProperty('fogTrans2.height')/2))
	setProperty('fogTrans2.alpha', 0.2)
	setProperty('fogTrans2.angle', -45)

	addLuaSprite('transBG', false);
	addLuaSprite('transSmoke', false);
	addLuaSprite('fogTrans', true);
	addLuaSprite('jazz', false)
	addLuaSprite('fogTrans2', true);

	setProperty('transBG.visible', false)
	setProperty('transSmoke.visible', false)
	setProperty('jazz.visible', false)
	setProperty('fogTrans.visible', false)
	setProperty('fogTrans2.visible', false)

	
---------- UI SHIT

	makeLuaSprite('overlay', '', -300, -100);
	setScrollFactor('overlay', 0, 0);
	scaleObject('overlay', '1','1');
	makeGraphic('overlay', screenWidth, screenHeight, '27e7d7')
	setProperty('overlay.alpha', 0.6)
	setBlendMode('overlay', 'MULTIPLY')
	scaleObject('overlay', '1.6','1.6');
	addLuaSprite('overlay', true);

	makeLuaSprite('tint', '', -300, -100);
	setScrollFactor('tint', 0, 0);
	scaleObject('tint', '1','1');
	makeGraphic('tint', screenWidth, screenHeight, '616678')
	setProperty('tint.alpha', 0.15)
	scaleObject('tint', '1.6','1.6');
	addLuaSprite('tint', true);

	makeLuaSprite('whiteBG', '', 0, 0);
	makeGraphic('whiteBG', screenWidth, screenHeight, 'FFFFF')
	setObjectCamera('whiteBG', 'other')
	addLuaSprite('whiteBG', false);

	makeLuaSprite('hoText', stage.. 'UI/ho', 0, 0);
	setObjectCamera('hoText', 'other')
	addLuaSprite('hoText', false);
	scaleObject('hoText', '0.7','0.7');

	makeLuaText('jasmineName', '', 0, 0, 0)
	setTextSize('jasmineName', 24)
	setTextFont('jasmineName', 'dialogue.ttf')
	setTextAlignment('jasmineName', 'center')
	setObjectCamera('jasmineName', 'other')
	setTextColor('jasmineName', 'black')
	setTextBorder('jasmineName', 0, 'white', 'none')
	addLuaText('jasmineName')

	setProperty('whiteBG.visible', false)
	setProperty('hoText.visible', false)
	setProperty('jasmineName.visible', false)

	if not lowQuality then
		if songName == 'machina' and doIntro and not seenCutscene then

			makeLuaSprite('introHide', '', 0, 0);
			setScrollFactor('introHide', 0, 0);
			addLuaSprite('introHide', true);
			scaleObject('introHide', '1.3','1.3');
			makeGraphic('introHide', screenWidth, screenHeight, '000000')
			setObjectCamera('introHide', 'other')
			setObjectOrder('introHide', 2)

			makeLuaSprite('intro', hud..'intros/intro_dsm', 0, 0);
			addLuaSprite('intro', true);
			scaleObject('intro', '0.6','0.6');
			screenCenter('intro')
			setObjectCamera('intro', 'other')
			setProperty('intro.visible', false)
		end
	
	end

	makeLuaSprite('clipTop', '', 0, -50);
	makeGraphic('clipTop', screenWidth, 50, '000000')
	makeLuaSprite('clipBottom', '', 0, screenHeight); 
	makeGraphic('clipBottom', screenWidth, 50, '000000')

	setObjectCamera('clipTop', 'other')
	setObjectCamera('clipBottom', 'other')
	addLuaSprite('clipBottom', false);
	addLuaSprite('clipTop', false);

	makeLuaSprite('endingFade', '', 0, 0);
	addLuaSprite('endingFade', true);
	makeGraphic('endingFade', screenWidth, screenHeight, '000000')
	setObjectCamera('endingFade', 'other')
	setProperty('endingFade.alpha', 0)

	makeLuaText('thanks', 'Thanks for playing!', 0, 0, 0)
	setTextSize('thanks', 30)
	setTextFont('thanks', 'dialogue.ttf')
	setTextAlignment('thanks', 'left')
	setObjectCamera('thanks', 'other')
	setTextColor('thanks', 'white')
	setTextBorder('thanks', 0, 'black', 'none')
	addLuaText('thanks')
	setProperty('thanks.alpha', 0)
	setProperty('thanks.x',	(screenWidth/2) - (getProperty('thanks.width')/2))
	setProperty('thanks.y', screenHeight - getProperty('thanks.height') - 80)

end

function startTypingText()
	currentTypedText = ""
	typedIndex = 0
	typedTimer = 0
	isTypingText = true
	setTextString('jasmineName', '')
end

function rundatHoe()

	forceCam = true
	followchars = false
	doZoom = false

	camX = 1000
	camY = 600

	setProperty('defaultCamZoom',0.9) -- this is lucy
	doTweenZoom('setUp', 'camGame', '0.9', 1, 'circInOut')

	setProperty('dad.visible', false)
	setProperty('boyfriend.alpha', 0)
	setProperty('boyfriend.visible', false)
	
	setProperty('whiteBG.visible', true)
	setProperty('hoText.visible', true)
	setProperty('jasmineName.visible', true)

	setProperty('hoText.x', (screenWidth / 2) - (getProperty('hoText.width')/2))
	setProperty('hoText.y', (screenHeight / 2) - (getProperty('hoText.height')/2))

	runTimer('startTypingJasmine', 1, 1)
	runTimer('hoMoveUp', 3, 1)
	runTimer('addTransition', 4, 1)
	runTimer('stageTwoSpawn', 11, 1)
end

function spawnTransition()
	setProperty('transBG.visible', true)
	setProperty('transSmoke.visible', true)
	setProperty('jazz.visible', true)
	setProperty('fogTrans.visible', true)
	setProperty('fogTrans2.visible', true)
end

function setUpTransEvent()

	setProperty('defaultCamZoom',1) 
	doTweenZoom('toJasmine', 'camGame', '1.2', 1, 'circInOut')

	runTimer('blurIt',0.5,1)
	runTimer('zoomIt',2.5,1)

	letterBox(1,1) 

	addAnimationByPrefix('jazz', 'fall', 'FALLING', 24, true)
	doTweenY('tweenInJasmine', 'jazz', 0, 3, 'backOut')
	doTweenX('tweenInJasmineX', 'jazz', 380, 2, 'smootherStepOut')
end

function spawnTransitionTwo()

	
	isTransStage = false
	isVictoriaS = true
	xx = 500 -- nikku
	xx2, yy2 = 1000, 600; --jasmine
	zoomDad = 0.85
	zoomJas = 1

	makeVictoriaStage()

	makeGraphic('overlay', screenWidth, screenHeight, '#fcd0f9')
	makeGraphic('tint', screenWidth, screenHeight, '#fd8de1')

	runTimer('playAnimationPotty', 1, 1)
	runTimer('playJasmine', 1.4, 1)
	runTimer('showReal', 3, 1)

end

function onUpdate(elapsed)

	daElapsed = elapsed * 30
	i = i + daElapsed
	yy = (math.sin(i/20)*45) + 300

	if isFirstStage then
		setProperty('dad.y', (math.sin(i/20)*45) + 50)
	else
		setProperty('dad.y', (math.sin(i/20)*45) - 0)
		setProperty('dad.x', 100);
	end

	if isTypingText then
		typedTimer = typedTimer + elapsed

		while typedTimer >= typedSpeed do
			typedTimer = typedTimer - typedSpeed
			typedIndex = typedIndex + 1

			setTextString('jasmineName', string.sub(fullTypedText, 1, typedIndex))

			if typedIndex >= string.len(fullTypedText) then
				isTypingText = false
				break
			end
		end
	end

	if attached then
		setProperty('jasmineName.x', getProperty('hoText.x') + ((getProperty('hoText.width')/2) - (getProperty('jasmineName.width')/2)))
		setProperty('jasmineName.y', getProperty('hoText.y') + getProperty('hoText.height') + 3)
	end

	-- for i = 0,3 do 
	-- 	setPropertyFromGroup('strumLineNotes', i, '0', 0)
	-- end

	if isFirstStage then
		if enableFog then
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

------------------------------------------------- STAGES 2
	if isTransStage then
		
		local fog1Y, fog1X, fog2Y, fog2X = getProperty('fogTrans.y'), getProperty('fogTrans.x'), getProperty('fogTrans2.y'), getProperty('fogTrans2.x')
		local fog1YSpeed, fog1XSpeed, fog2YSpeed, fog2XSpeed = 160, 100, 160 * 8, 100 * 14
		setProperty('fogTrans.y', fog1Y - (fog1YSpeed * elapsed))
		setProperty('fogTrans.x', fog1X + (fog1XSpeed * elapsed))
		setProperty('fogTrans2.y', fog2Y - (fog2YSpeed * elapsed))
		setProperty('fogTrans2.x', fog2X + (fog2XSpeed * elapsed))

		setProperty('transSmoke.y', (getProperty('transSmoke.y') - speedTrans3Y))
		setProperty('transSmoke.x', (getProperty('transSmoke.x') + speedTrans3X))


		if getProperty('fogTrans2.y') < -3000 then -- front
			setProperty('fogTrans2.y', (screenHeight) + getProperty('fogTrans2.height'))
			setProperty('fogTrans2.x', 1600 - getProperty('fogTrans2.width'))
		end

		if getProperty('fogTrans.y') < -1800 then -- done
			setProperty('fogTrans.y', (screenHeight) + getProperty('fogTrans2.height'))
			setProperty('fogTrans.x', -100 - getProperty('fogTrans2.width'))
		end

	end

	if isVictoriaS then
	
		setProperty('heart1.x', (math.sin(i/25)*200) + 300)
		setProperty('heart1.y', getProperty("heart1.y") - 0.8); 
		if getProperty("heart1.y") < -300 then
			resetHeart(1) 
		end

		setProperty('heart2.x',(math.sin(i/10)*40) + 50)
		setProperty('heart2.y', getProperty("heart2.y") - 0.6); 
		if getProperty('heart2.y') < -500 then 
			resetHeart(2) 
		end

		setProperty('heart3.x', (math.sin(i/25)*100) + 700)
		setProperty('heart3.y', getProperty("heart3.y") - 0.8); 
		if getProperty("heart3.y") < -300 then
			resetHeart(3) 
		end
		
		setProperty('heart4.x', (math.sin(i/30)*600) + 500)
		setProperty('heart4.y', getProperty("heart4.y") - 0.8); 
		if getProperty("heart4.y") < -300 then
			resetHeart(4) 
		end

	end

------------------------------------------------- CUSTOM FUNCTIONS

	-- CUSTOM SHAKE
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

------------------------------------------------- FORCE CAM & FOLLOW
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

function onPause()
	pauseSound('transition')
end

function onResume()
	resumeSound('transition')
end

-- EVENTS
	stepHitFuncs = { 
		[1] = function()
			if isFirstStage and doIntro then
				if not seenCutscene then
					triggerEvent('Play Animation', 'HOE', 'Dad')

					runTimer('introShow', 0.8,1);
					runTimer('panDown', 2,1);
					runTimer('getOuttaHere', 3,1);
				end
			end
		end,

		[170] = function()
			if isFirstStage then
				followchars = false
				forceCam = true

				camX = 800
				camY = 300
				
			end
		end,

		[202] = function()
			if isFirstStage then
				followchars = true
				forceCam = false
			end
		end,


		[224] = function() --113
			if isFirstStage then
				followchars = false
				forceCam = true

				camX = 1100
				camY = 560
				runTimer('sheFlex', 1,1);

				zoomDad = 0.8
			end
		end,
		
		[1515] = function() --113
			runTimer('aintno', 1,1);
			followchars = false
			forceCam = true
			attached = true
			camX = 1100
			camY = 560

			doTweenAlpha('ohdamn', 'camHUD', 0, 2, 'quadOut')
			setProperty('cameraSpeed', 0.4)
			
		end,

		[1540] = function() --113
			precacheVictoriaStage()
			rundatHoe()
		end,

		[1944] = function() -- PAPI
			triggerEvent('Play Animation', 'PAPI', 'BF')

			doZoom = false
			cancelTween('toJasmine')
			cancelTween('toNikku')

			doTweenZoom('ayeee', 'camGame', '1.2', 1, 'bounceOut')
			letterBox(0.3, 0.3)
			runTimer('awayBox', 1,1);
		end,

		[2628] = function()
			
			endingShit()
		end

	}

-- FUNCTIONS
	function moneySpread()
		runTimer('playMoney',0.15,1)
		triggerEvent('Play Animation', 'FLEX', 'BF')
	end

	function endingShit()
		makeLuaSprite('endingCard', hud..'ending-machina', 0, 0);
		addLuaSprite('endingCard', true);
		scaleObject('endingCard', '0.5','0.5');
		screenCenter('endingCard')
		setObjectCamera('endingCard', 'other')
		setProperty('endingCard.angle', 3)
		setProperty('endingCard.alpha', 0)

		doTweenAlpha('fadeBG', 'endingFade', 1, 3, 'quadOut')
		runTimer('showCard', 4, 1)
		runTimer('showText', 5.5, 1)
		runTimer('fadeTextCard', 8, 1)
	end


	function goodNoteHit(id, direction, noteType, isSustainNote)

		setProperty('health', getProperty('health')+0.035);
	end

	function opponentNoteHit(id, direction, noteType, isSustainNote)

		if getProperty('health') > 0.2 then
			setProperty('health', getProperty('health')-0.025);
		end

	end

	function onBeatHit()

		if curBeat % 2 == 0 then
			if getProperty('dad.animation.curAnim.name') == 'idle' then
				characterPlayAnim('dad','idle',true)
			end
		
			-- if getProperty('boyfriend.animation.curAnim.name') == 'idle' then
			-- 	characterPlayAnim('boyfriend','idle',true)
			-- end
		end

	end

	function letterBox(duration,time) 
		doTweenY('clip1Move', 'clipTop', 0, duration, 'smootherStepIn')
		doTweenY('clip2Move', 'clipBottom', screenHeight - 50, duration, 'smootherStepIn')
		doTweenAlpha('byebye', 'camHUD', 0, time, 'backIn')
	end
	function letterBoxOut(duration,time) 
		doTweenY('clip1Move', 'clipTop', -80, duration, 'smootherStepIn')
		doTweenY('clip2Move', 'clipBottom', screenHeight, duration, 'smootherStepIn')
		doTweenAlpha('hellohello', 'camHUD', 1, time, 'circOut')
	end


	function onStepHit()
		if stepHitFuncs[curStep] then
			stepHitFuncs[curStep]()
		end

	end

	function onTimerCompleted(tag, loops, loopsLeft)
	------------- INTRO
		if tag == 'introShow' then
			setProperty('intro.visible', true)
			runTimer('introFade', 3,1);
		end

		if tag == 'getOuttaHere' then
			doTweenAlpha('delete', 'introHide', 0, 2, 'backIn')
		end

		if tag == 'introFade' then
			doTweenAlpha('goodbyeIntro', 'intro', 0, 3.5, 'backIn')
		end

		if tag == 'moveTagOut' then
			doTweenY('moveTag2', 'winner', 850, 0.6, 'circIn')
		end

		if tag == 'panDown' then
			
			camY = 300
			doZoom = true; 
			runTimer('gameStart', 8,1);

			setProperty('cameraSpeed', 0.2)
			
		end

		if tag == 'gameStart' then

			followchars = true; 
			forceCam = false;
			setProperty('cameraSpeed', 0.8)
		end

	------------- FIRST STAGE EVENTS
		if tag == 'sheFlex' then
			moneySpread()
		end

		if tag == 'playMoney' then
			addAnimationByPrefix('bills', 'flexing', 'MONEY-FLY', 24, false)
			setProperty('bills.visible', true)

			runTimer('sceneOver', 2,1);
		end

		if tag == 'sceneOver' then
			followchars = true
			forceCam = false
		end

		if tag == 'aintno' then
			triggerEvent('Play Animation', 'BRUH', 'BF')
		end

		if tag == 'startTypingJasmine' then
			startTypingText()
		end

		if tag == 'hoMoveUp' then
			doTweenY('hoMoveOut', 'hoText', -400, 2, 'quadIn')
			playSound(sounds.. 'machi_trans', 1, 'transition')
		end

		if tag == 'addTransition' then
			isTransStage = true
			isFirstStage = false
			removeFirstStage()
			spawnTransition()
		end


	------------- TRANSITION
		if tag == 'blurIt' then
			triggerBlur()
		end

		if tag == 'zoomIt' then
			doTweenAlpha('bye', 'whiteBG', 1, 1, 'quadOut')
			doTweenZoom('emphasis', 'camGame', '1.2', 1, 'circOut')
			setProperty('defaultCamZoom',1.2)
		end

		if tag == 'stageTwoSpawn' then
			doTweenAlpha('finalFade', 'whiteBG', 0, 1, 'quadOut')
		end

		if tag == 'backToNormal' then
			setProperty('cameraSpeed', 1)
			
			doTweenAlpha('finalFade', 'whiteBG', 0, 1, 'quadOut')
			setProperty('hoText.visible', false)
			setProperty('jasmineName.visible', false)

		end

		if tag == 'playAnimationPotty' then
			addAnimationByPrefix('pottyBG', 'appear', 'pottyLOL', 24, false)
			playAnim('pottyBG', 'appear',false, false, 1)
			doTweenZoom('hola', 'camGame', '0.95', 1, 'quadOut')
			startSmoothShake(8, 1)

		end

		if tag == 'playJasmine' then
			addAnimationByPrefix('jasmineAnim', 'dance', 'TRANS', 24, false)
			playAnim('jasmineAnim', 'dance',false, false, 1)

			debugPrint('HEY!')
		end

		if tag == 'showReal' then
			setProperty('boyfriend.alpha', 1)
			setProperty('boyfriend.visible', true)
			setProperty('jasmineAnim.alpha', 0)

			followchars = true; 
			forceCam = false;
			doZoom = true; 
		end

		if tag == 'awayBox' then
			doZoom = true
			letterBoxOut(0.5, 0.5)
		end

	------------- ENDING

		if tag == 'showCard' then
			doTweenAlpha('fadeincard', 'endingCard', 1, 1, 'quadOut')
			doTweenX('cardX', 'endingCard.scale', 0.3, 1, 'bounceOut')
			doTweenY('cardY', 'endingCard.scale', 0.3, 1, 'bounceOut')
		end

		if tag == 'showText' then
			doTweenAlpha('thanksfade', 'thanks', 1, 1, 'quadOut')
		end
			
		if tag == 'fadeTextCard' then
			doTweenAlpha('fadeCardOut', 'endingCard', 0, 1, 'quadOut')
			doTweenAlpha('fadeTextOut', 'thanks', 0, 1, 'quadOut')
		end

	-------------- FUNCTIONS
		if tag == 'clearBlur' then
			runHaxeCode("FlxG.camera.setFilters([]);")
		end
			
	end

	function onTweenCompleted(tag, loops, loopsLeft)
		if tag == 'hoMoveOut' then
			doTweenAlpha('removeWhite', 'whiteBG', 0, 2, 'quadOut')
			debugPrint('remove white?')
			startSmoothShake(7, 12)
		end

		if tag == 'removeWhite' then
			setUpTransEvent()
		end

		if tag == 'emphasis' then
			debugPrint('ZOOM DONE?')
			letterBoxOut(1, 1)
			camX = 1000
			camY = 600
			attached = false

			removeSecondStage()
			spawnTransitionTwo()
			runTimer('backToNormal', 2,1);

			setProperty('dad.alpha', 1)
			setProperty('dad.visible', true)

			triggerEvent('Change Character', 1, 'nikkuswitch');
			triggerEvent('Change Character', 0, 'jasmineswitch');
		end
	end

	function triggerBlur()
		runHaxeCode([[
			FlxG.camera.setFilters([new openfl.filters.BlurFilter(12, 12, 2)]);
		]])
		runTimer('clearBlur', 0.25, 1)
	end

	function startSmoothShake(strength, duration, cam)
		shakeCam = cam or 'camGame'
		shakeStrength = strength or 5
		shakeDuration = duration or 0.5
		shakeTime = shakeDuration
		isShaking = true
	end

	function frand(a,b) return a + math.random()*(b-a) end

	function resetHeart(id)
		if id == 1 then
			h1x = frand(X_MIN, X_MAX); h1y = START_Y + frand(0,40)
			h1vx = frand(-18,18);      h1vy = frand(70,120)
			setProperty('heart1.x', h1x); setProperty('heart1.y', h1y)
		elseif id == 2 then
			h2x = frand(X_MIN, X_MAX); h2y = START_Y + frand(0,40)
			h2vx = frand(-18,18);      h2vy = frand(70,120)
			setProperty('heart2.x', h2x); setProperty('heart2.y', h2y)
		elseif id == 3 then
			h3x = frand(X_MIN, X_MAX); h3y = START_Y + frand(0,40)
			h3vx = frand(-18,18);      h3vy = frand(70,120)
			setProperty('heart3.x', h3x); setProperty('heart3.y', h3y)
		else
			h4x = frand(X_MIN, X_MAX); h4y = START_Y + frand(0,40)
			h4vx = frand(-18,18);      h4vy = frand(70,120)
			setProperty('heart4.x', h4x); setProperty('heart4.y', h4y)
		end
	end

	function onSectionHit()
		if not doZoom then return end

		if mustHitSection == false then
			cancelTween('toJasmine')
			doTweenZoom('toNikku', 'camGame', zoomDad, 1, 'backInOut')
			setProperty('defaultCamZoom', zoomDad)
		else
			cancelTween('toNikku')
			doTweenZoom('toJasmine', 'camGame', zoomJas, 1, 'circInOut')
			setProperty('defaultCamZoom', zoomJas)
		end
	end

-- STAGES
	function makeVictoriaStage()

		if victoriaMade then return end
		victoriaMade = true

		makeLuaSprite('screenBG', stage2.. 'screen/SCREEN', -200, -100); -- hearts bg
		setScrollFactor('screenBG', 0.7, 1);
		scaleObject('screenBG', '1.3','1.1')
		addLuaSprite('screenBG', false);

		makeLuaSprite('heart1', HEART1_TEX, 100, 500); 
		addLuaSprite('heart1', false)
		makeLuaSprite('heart2', HEART2_TEX, 0, 0); 
		addLuaSprite('heart2', false)
		makeLuaSprite('heart3', HEART3_TEX, 0, 0); 
		addLuaSprite('heart3', false)
		makeLuaSprite('heart4', HEART1_TEX, 0, 0); 
		addLuaSprite('heart4', false)

		setBlendMode('heart1', 'SCREEN')
		setBlendMode('heart2', 'SCREEN')
		setBlendMode('heart3', 'SCREEN')
		setBlendMode('heart4', 'SCREEN')

		makeLuaSprite('black', '', -500, -600);
		setScrollFactor('black', 0.7, 1);
		addLuaSprite('black', false);
		makeGraphic('black', screenWidth, 500, "#000000")
		scaleObject('black', '1.3','1');

		makeLuaSprite('interior', stage2.. 'BG', -530, -200);  -- main bg
		setScrollFactor('interior', 0.7, 1);
		addLuaSprite('interior', false);
		scaleObject('interior', '1.3','1.2')

		makeLuaSprite('mani', stage2.. 'MANNY', -500, 320);
		setScrollFactor('mani', 0.75, 1);
		addLuaSprite('mani', false);

		makeLuaSprite('chair', stage2.. 'CHAIR', 250, 300);
		setScrollFactor('chair', 0.8, 0.9);
		scaleObject('chair', '1.1','1.1')
		addLuaSprite('chair', false);

		makeLuaSprite('chand', stage2.. 'CHAND', 350, -400);
		setScrollFactor('chand', 0.8, 1.1);
		scaleObject('chand', '1.2','1.2')
		addLuaSprite('chand', false);

		if enableLights then
			makeLuaSprite('chand-light', stage2.. 'CHAND-LIGHT', 250, -400);
			setScrollFactor('chand-light', 0.8, 1.1);
			setBlendMode('chand-light', 'SCREEN')
			scaleObject('chand-light', '1.2','1.2')
			addLuaSprite('chand-light', true);
		end

		makeLuaSprite('fg-man1', stage2.. 'FGMANNY',150, 200);
		setScrollFactor('fg-man1', 1.5, 1.3);
		setBlendMode('fg-man1', 'SCREEN')
		scaleObject('fg-man1', '1.2','1.2')
		addLuaSprite('fg-man1', true);

		makeAnimatedLuaSprite('pottyBG', stage2.. 'POTTY', 1173, 218) 
		setScrollFactor('pottyBG', 0.9, 0.9);
		addLuaSprite('pottyBG', false)

		makeAnimatedLuaSprite('jasmineAnim', stage2.. 'JASMINESWITCH', 926, 358) 
		setScrollFactor('jasmineAnim', 0.9, 0.9);
		addLuaSprite('jasmineAnim', false)


		local lightColor = getColorFromHex('f0804e')  

		if enableLights then
			makeLuaSprite('light', hud..'LIGHTTEST', -190, -80); -- -200
			setScrollFactor('light', 0, 0);
			addLuaSprite('light', true);
			scaleObject('light', '1.2','1');
			setBlendMode('light', 'SCREEN')
			setProperty('light.alpha', 0.8)
			setProperty('light.color',lightColor)
		end
	end

	function precacheVictoriaStage()
		precacheImage(stage2..'screen/SCREEN')
		precacheImage(stage2..'BG')
		precacheImage(stage2..'MANNY')
		precacheImage(stage2..'CHAIR')
		precacheImage(stage2..'CHAND')
		precacheImage(stage2..'CHAND-LIGHT')
		precacheImage(stage2..'FGMANNY')
		precacheImage(stage2..'POTTY')
		precacheImage(stage2..'JASMINESWITCH')
	end
-- REMOVING STAGES

	function removeFirstStage()
		for i = 1, #spritesToRemove do
			removeLuaSprite(spritesToRemove[i], true)
		end
	end

	function removeSecondStage()
		for i = 1, #spritesToRemove2 do
			removeLuaSprite(spritesToRemove2[i], true)
		end
	end