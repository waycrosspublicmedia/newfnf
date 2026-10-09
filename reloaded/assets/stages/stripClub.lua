local baseFPS = 144 -- i worked on this fps so i have to account for other fpses

local stage = 'stages/week3/stripClub/'
local stagePeeps = 'stages/week3/stripClub/PEEPS/SHIMMER/'
local hud = 'stages/hudelements/4-hudShit/'
local sounds = 'WEEK2/'

local xx, yy = 480, 660 -- lucy
local xx2, yy2 = 750, 670 -- nova
local ofs, ofs2 = 15, 35
local followchars, forceCam = false, false

local showLucy, showNova, peepsBop, showPeeps, showShimmerPeeps = true, true, false, false, false
local allowCountdown, doDialogue = false, true
local doIntro, doZoom = true, true

--SHAKE & BLUR & WOBBLE
local shakeDuration, shakeTime, shakeStrength, doShake = 0, 0, 0, false
local blurAlpha, blurActive = 1, false
local wobbleAmount, wobbleSpeed = 1.2, 0.2
local i = 0
local lightColor = getColorFromHex('c88aff')  
local currentColorIndex = 1
local clubColors = {
	'00FFFF', -- cyan
    '8A2BE2', -- purple
   	'FFFF00', -- yellow
    'FF1493', -- hot pink
    'FF4500', -- orange-red
   	'FFFFFF'  -- white
}

local strumDefaultX = {}
local strumDefaultY = {}
local defaultNotePos = {};
local arrowMoveX = 30;
local arrowMoveY = 30;
local drunkMode, doThing = false, false

local doVideo = true
function onStartCountdown()

	if isStoryMode and songName == 'pop' then
	
		if doVideo and not seenCutscene then
			startVideo('lucyIntro');
			doVideo = false
			allowCountdown = true;
			return Function_Stop;
		end

		if doDialogue and not seenCutscene then
			startDialogue('popShit', 'dialogueMusic/popDia')
			doDialogue = false
			allowCountdown = true;
			return Function_Stop
		end
		return Function_Continue
	end

	if isStoryMode and songName == 'shimmer' then
		if not allowCountdown and not seenCutscene then
			if doDialogue and not seenCutscene then
				startDialogue('shimmerShit', 'dialogueMusic/shimDia')  
				doDialogue = false
				allowCountdown = true;
				return Function_Stop;
			end
			return Function_Continue
		end
	end
	
end

function onSongStart()
    for i = 0,7 do 
      	strumDefaultX[i] = getPropertyFromGroup('strumLineNotes', i, 'x')
        strumDefaultY[i] = getPropertyFromGroup('strumLineNotes', i, 'y')
		
    end

	if songName == 'shimmer' then
		doThing = true
	end

	if songName == 'pop' and doIntro and not seenCutscene then
		
		letterBox(1,1,0)
	
		runTimer('introShow', 1.2,1);
		runTimer('panDown', 2,1);
		runTimer('getOuttaHere', 3.1,1);
		runTimer('fuckingOff', 4.3,1);
		runTimer('fuckingOff2', 3,1);
		playSound(sounds.. 'stripClubIntro_2', 0.4, 'intro')

	end
end

function onCreatePost() 

	if songName == 'pop' and doIntro and not seenCutscene then

		if not lowQuality then
			showPeeps = true
			followchars = false;
			forceCam = true
			doZoom = false
			peepsBop = false
			

			camX = 650
			camY = -100
			setProperty('camGame.zoom',0.8)
			setProperty('camHUD.alpha',0)

		end 
	elseif songName == 'pop' then
		peepsBop = true
	end


	if songName == 'shimmer' then
		for i = 0,7 do 
			setPropertyFromGroup('strumLineNotes', i, 'alpha', alpha)
		end

		peepsBop = true
	end
	
	setProperty('gf.visible', false)
	setProperty('dad.scrollFactor.x', 0.9);
	setProperty('dad.scrollFactor.y', 0.9);
	setProperty('boyfriend.scrollFactor.x', 0.9);
	setProperty('boyfriend.scrollFactor.y', 0.9);
	
end

function onCreate()
-- BG SHIT
	camX = 'camFollow.x'
	camY = 'camFollow.y'

	if songName == 'shimmer' then
		peepsBop = true;
		ofs = 25;  
		setProperty('cameraSpeed', 1.3)
	end

	if songName == 'pop' then
		followchars = false
		peepsBop = false
		showPeeps = true
	end


	makeLuaSprite('wall', stage..'WALL', -500, -250);
	setScrollFactor('wall', 0.45, 0.55);
	addLuaSprite('wall', false);
	scaleObject('wall', '1.1','1.1');

	makeLuaSprite('floor', stage..'GROUND', -650, 620);
	setScrollFactor('floor', 0.9,0.8);
	addLuaSprite('floor', false);
	scaleObject('floor', '1.2','1.1');

	makeLuaSprite('counterBacked', stage..'COUNTER WALL', -500, 280);
	setScrollFactor('counterBacked', 0.55, 0.7);
	addLuaSprite('counterBacked', false);
	scaleObject('counterBacked', '1.3','1');

	makeLuaSprite('counterStageShit', stage..'COUNTERSTAGE', -200, 380);
	setScrollFactor('counterStageShit', 0.7, 0.8);
	addLuaSprite('counterStageShit', false);
	scaleObject('counterStageShit', '1.3','1');

	makeLuaSprite('stage', stage..'STRIP STAGE', -350, -80);
	setScrollFactor('stage', 0.8, 0.9);
	scaleObject('stage', '1.15','1');

	makeLuaSprite('counter', stage..'BAR FG', -600, 550);
	setScrollFactor('counter', 0.8, 0.9);
	scaleObject('counter', '1.2','1');

	if not lowQuality then --BG PEEPS
		if showPeeps and songName == 'pop' then
			makeAnimatedLuaSprite('mind', stage..'PEEPS/MINDY', -50, 260); --left most
			addAnimationByPrefix('mind', 'bop1', 'MINDY', 24, true);
			setScrollFactor('mind', 0.7, 0.9);
			scaleObject('mind', '1.1','1.1');

			makeAnimatedLuaSprite('ash', stage..'PEEPS/ASH', 800,250); 
			addAnimationByPrefix('ash', 'bop3', 'ASH', 24, true);
			setScrollFactor('ash', 0.7, 0.9);
			scaleObject('ash', '1.1','1.1');

			makeAnimatedLuaSprite('dev', stage..'PEEPS/DEV', 240,270); 
			addAnimationByPrefix('dev', 'bop2', 'DEV', 24, true);
			setScrollFactor('dev', 0.7, 0.9);
			scaleObject('dev', '1.1','1.1');

			makeAnimatedLuaSprite('dar', stage..'PEEPS/DARIUS', 1250,220); --right most
			addAnimationByPrefix('dar', 'bop4', 'DARIUS', 24, true);
			setScrollFactor('dar', 0.7, 0.9);
			scaleObject('dar', '1.1','1.1');

			addLuaSprite('mind', false);
			addLuaSprite('ash', false);
			addLuaSprite('dev', false);
			addLuaSprite('dar', false);
		end
	end

	addLuaSprite('stage', false);

	if not lowQuality then -- FG PEEPS

		if showPeeps and songName == 'pop' then
			makeAnimatedLuaSprite('nik', stage..'PEEPS/NIKITA', 350,-70)
			addAnimationByPrefix('nik', 'brr', 'NIKITA',24,true)
			setScrollFactor('nik', 0.7, 0.9);
			scaleObject('nik', '1','1');

			makeAnimatedLuaSprite('numb', stage..'PEEPS/NUMB', 950,70)
			addAnimationByPrefix('numb', 'mulah', 'NUMBNUMB',24,true)
			setScrollFactor('numb', 0.8, 0.9);
			scaleObject('numb', '1','1');
			
			setProperty('nik.visible', true)
			setProperty('numb.visible', true)
			addLuaSprite('nik',false)
			addLuaSprite('numb',false)

		elseif songName == 'shimmer' then -- for shimmer stage

			makeAnimatedLuaSprite('numbShim', stagePeeps..'numb', 820, 280)
			addAnimationByPrefix('numbShim', 'dance', 'NUMB_BG',24,true)
			addAnimationByPrefix('numbShim', 'end', 'dance-NUMB',24,true)
			setScrollFactor('numbShim', 0.85, 0.9);

			makeAnimatedLuaSprite('nikShim', stagePeeps..'nikita', 90, 280) --180
			addAnimationByPrefix('nikShim', 'dance', 'NIKITA_BG',24,true)
			addAnimationByPrefix('nikShim', 'end', 'dance-NIKITA',24,true)
			setScrollFactor('nikShim', 0.85, 0.9);

			objectPlayAnimation('numbShim', 'dance', true);
			objectPlayAnimation('nikShim', 'dance', true);

			makeAnimatedLuaSprite('jer', stagePeeps..'jer', 900, 220)
			addAnimationByPrefix('jer', 'dance', 'JER_BG',24,true)
			setScrollFactor('jer', 0.65, 0.9);

			makeAnimatedLuaSprite('ash', stagePeeps..'ash', 600, 150)
			addAnimationByPrefix('ash', 'dance', 'ASH_BG',24,true)
			setScrollFactor('ash', 0.65, 0.9);

			makeAnimatedLuaSprite('dar', stagePeeps..'dar', 200, 250)
			addAnimationByPrefix('dar', 'dance', 'DAR_BG',24,true)
			setScrollFactor('dar', 0.65, 0.9);

			makeAnimatedLuaSprite('gen', stagePeeps..'gen', -120, 100)
			addAnimationByPrefix('gen', 'dance', 'crowdGen',24,true)
			setScrollFactor('gen', 0.55, 0.9);
			scaleObject('gen', '1.3','1.1');
		
			addLuaSprite('gen',false)
			addLuaSprite('dar',false)
			addLuaSprite('jer',false)
			addLuaSprite('ash',false)
			addLuaSprite('numbShim',false)
			addLuaSprite('nikShim',false)
		end

	end

	addLuaSprite('counter', false);

	if not lowQuality then 

		makeAnimatedLuaSprite('tanisha', stage..'PEEPS/TANISHA', 300, 280)
	    addAnimationByIndices('tanisha', 'half1', 'TANISHA', '0,1,2,3,4,5,6,7,8,9,10', 24)
   	 	addAnimationByIndices('tanisha', 'half2', 'TANISHA', '11,12,13,14,15,16,17,18,19,20,21', 24)
		addAnimationByPrefix('tanisha', 'shocked', 'TANISHA_SCARED',18,false)
		addAnimationByPrefix('tanisha', 'umm', 'TANISHA-WAIT',24,false)
		addAnimationByPrefix('tanisha', 'end', 'dance-TANISHA',24,true)
		setScrollFactor('tanisha', 0.85, 0.9);
		scaleObject('tanisha', '1.03','1.03');
		setProperty('tanisha.visible', true)

		playAnim('tanisha', 'half1', true)

		makeLuaSprite('bfsnooze', stage..'PEEPS/BF', -460, 300);
		setScrollFactor('bfsnooze', 0.85, 0.9);
		scaleObject('bfsnooze', '1','1');

		addLuaSprite('tanisha',false)
		addLuaSprite('bfsnooze', false);

		if songName == 'pop' then -- JAZZ AND GF

			makeAnimatedLuaSprite('jazz', stage..'PEEPS/JASMINE', 1000,350)
			addAnimationByPrefix('jazz', 'talking', 'JASMINE-CHAT',24,false)
			addAnimationByPrefix('jazz', 'wait', 'JASMINE-WAIT0',24,false)
			addAnimationByPrefix('jazz', 'shocked', 'JASMINE-SHOCKED',18,false)
			addAnimationByPrefix('jazz', 'baddiesit', 'JASMINE0',24,true)
			setScrollFactor('jazz', 0.85, 0.9);
			scaleObject('jazz', '0.95','0.95');
		
			makeAnimatedLuaSprite('dagf', stage..'PEEPS/GF', -200,350)
			setScrollFactor('dagf', 0.85, 0.9);
			scaleObject('dagf', '0.9','0.9');
			addAnimationByPrefix('dagf', 'talking', 'GF-CHAT',24,false)
			addAnimationByPrefix('dagf', 'wait', 'GF-WAIT0',24,false)
			addAnimationByPrefix('dagf', 'shocked', 'GF-SHOCKED',18,false)
			addAnimationByPrefix('dagf', 'baddie2sit', 'GF0',24,true)

			addLuaSprite('jazz',false)
			addLuaSprite('dagf',false)

		else

			makeAnimatedLuaSprite('jazz', stage..'PEEPS/JASMINE', 1000,350)
			addAnimationByPrefix('jazz', 'baddiesit', 'JASMINE0', 24, true)
			addAnimationByPrefix('jazz', 'end', 'JASMINE-DANCE', 24, true)
			addLuaSprite('jazz',false)
			setScrollFactor('jazz', 0.85, 0.9);
			scaleObject('jazz', '0.95','0.95');
			
			makeAnimatedLuaSprite('dagf', stage..'PEEPS/GF', -200,350)
			addAnimationByPrefix('dagf', 'baddie2sit', 'GF0', 24, true)
			addAnimationByPrefix('dagf', 'end', 'GF-DANCE', 24, true)
			addLuaSprite('dagf',false)
			setScrollFactor('dagf', 0.85, 0.9);
			scaleObject('dagf', '0.9','0.9');

			objectPlayAnimation('jazz', 'baddiesit',true)
			objectPlayAnimation('dagf', 'baddie2sit',true)

		end

		makeAnimatedLuaSprite('age', stage..'PEEPS/AGENT', 1400,590); --right most
		addAnimationByPrefix('age', 'bop5', 'AGENT', 24, true);
		addLuaSprite('age', false);
		setScrollFactor('age', 0.85, 0.9);
		scaleObject('age', '1.2','1.2');

		makeLuaSprite('rails', stage..'RAILINGS', -700, -250);
		setScrollFactor('rails', 0.8, 1.2);
		addLuaSprite('rails', true);
		scaleObject('rails', '1.1','1');

	end

-- SPRITES FOR EVENTS

	if not lowQuality then
		if songName == 'pop' then

			if doIntro and not seenCutscene then
				makeAnimatedLuaSprite('lucyintro', stage..'PEEPS/LUCY-INTRO', -245, 338)
				addLuaSprite('lucyintro',true)
				setScrollFactor('lucyintro', 0.9, 0.9);
				scaleObject('lucyintro', '1.05','1.05');
				showLucy = false

				makeAnimatedLuaSprite('novaintro', stage..'PEEPS/NOVA-INTRO', 615, 378)
				addLuaSprite('novaintro',true)
				setScrollFactor('novaintro', 0.9, 0.9);
				showNova = false
			end

			makeAnimatedLuaSprite('lucyending', stage..'PEEPS/LUCY-ENDING', 72,345); 
			addLuaSprite('lucyending', true);
			setScrollFactor('lucyending', 0.9, 0.9);
			scaleObject('lucyending', '1.05','1.05');
			setProperty('lucyending.visible', false)

			makeAnimatedLuaSprite('novaending', stage..'PEEPS/NOVA-ENDING', 449,428);
			addLuaSprite('novaending', true);
			setScrollFactor('novaending', 0.9, 0.9);
			setProperty('novaending.visible', false)
		
	
		elseif songName == 'shimmer' then
			makeAnimatedLuaSprite('lucyDance', stage..'PEEPS/SHIMMER/LUCY-ENDING', -5, 355)
			addLuaSprite('lucyDance',true)
			setScrollFactor('lucyDance', 0.9, 0.9);
			scaleObject('lucyDance', '1.05','1.05');
			
			makeAnimatedLuaSprite('angeloDance', stage..'PEEPS/SHIMMER/ANGELO-ENDING', 755, 408)
			addLuaSprite('angeloDance',true)
			setScrollFactor('angeloDance', 0.9, 0.9);

			setProperty('lucyDance.visible', false)
			setProperty('angeloDance.visible', false)
		end

	-- EXTRA GRAPHICS

		if enableFog then
			makeLuaSprite('fog1', stage..'TEST/FOG-1', 0, 650);
			setScrollFactor('fog1', 1.1, 1.3);
			addLuaSprite('fog1', true);
			scaleObject('fog1', '1.1','1.1');
			setBlendMode('fog1', 'SCREEN')
			setProperty('fog1.x', -screenWidth - (getProperty('fog1.width')/2))

			makeLuaSprite('fog2', stage..'TEST/FOG-2', 0, 750);
			setScrollFactor('fog2', 1.3, 1.2);
			addLuaSprite('fog2', true);
			scaleObject('fog2', '1.8','1.4');
			setBlendMode('fog2', 'SCREEN')
			setProperty('fog2.alpha', 0.4)
			setProperty('fog2.x', -screenWidth - (getProperty('fog2.width')/4))

			makeLuaSprite('fog3', stage..'TEST/FOG-3', 800, 350);
			setScrollFactor('fog3', 1.1, 1.3);
			addLuaSprite('fog3', true);
			scaleObject('fog3', '1.2','1.3');
			setBlendMode('fog3', 'SCREEN')
			setProperty('fog3.x', -screenWidth + (getProperty('fog3.width')/2))

			makeLuaSprite('tree', stage..'TREE', 1150, -400);
			setScrollFactor('tree', 1.7, 0.7);
			addLuaSprite('tree', true);
			scaleObject('tree', '1.1','1.3');

			makeLuaSprite('tree2', stage..'TREE', -1650, -400);
			setScrollFactor('tree2', 1.7, 0.7);
			addLuaSprite('tree2', true);
			setProperty('tree2.flipX', true)
			scaleObject('tree2', '1.1','1.3');

			fogColor = getColorFromHex('FF6699') 
			fogColor2 = getColorFromHex('f49afc')

			setProperty('fog1.color', fogColor)
			setProperty('fog2.color', fogColor)
			setProperty('fog3.color', fogColor2)

			speed1 = '0.4'
			speed2 = '0.8'
			speed3 = '0.2'
		end

		if songName == 'pop' then
			makeLuaSprite('cutawaybg', stage..'HUD/OUTSIDE', -590, 210);
			setScrollFactor('cutawaybg', 1,1);
			addLuaSprite('cutawaybg', true);
			scaleObject('cutawaybg', '1.2','1.2');
			setProperty('cutawaybg.visible', false)

			makeLuaSprite('carcutaway2', stage..'HUD/OUTSIDE CAR', 1850, 650);
			setScrollFactor('carcutaway2', 1,1);
			addLuaSprite('carcutaway2', true);
			scaleObject('carcutaway2', '1','1');
			setProperty('carcutaway2.flipX', true)
			setProperty('carcutaway2.visible', false)

			makeLuaSprite('carcutaway', stage..'HUD/OUTSIDE CAR', -1950, 640);
			setScrollFactor('carcutaway', 1,1);
			addLuaSprite('carcutaway', true);
			scaleObject('carcutaway', '1.2','1.2');
			setProperty('carcutaway.visible', false)
		end
	end

	if not enableLight then
		makeLuaSprite('light', hud..'LIGHTTEST', -500, -100); -- -200
		setScrollFactor('light', 0, 0);
		addLuaSprite('light', true);
		scaleObject('light', '1.5','1');
		setBlendMode('light', 'SCREEN')
		setObjectOrder('light', 50)
		setProperty('light.color', lightColor)

		makeLuaSprite('overlay', '', -300, -100);
		setScrollFactor('overlay', 0, 0);
		addLuaSprite('overlay', true);
		scaleObject('overlay', '1','1');
		makeGraphic('overlay', screenWidth, screenHeight, '8c40ff')
		setProperty('overlay.alpha', 0.2)
		setBlendMode('overlay', 'MULTIPLY')
		scaleObject('overlay', '1.4','1.4');
	end

	makeLuaSprite('clipTop', '', 0, -50);
	addLuaSprite('clipTop', false);
	makeGraphic('clipTop', screenWidth, 50, '000000')
	setObjectCamera('clipTop', 'other')

	makeLuaSprite('clipBottom', '', 0, screenHeight);
	addLuaSprite('clipBottom', false);
	makeGraphic('clipBottom', screenWidth, 50, '000000')
	setObjectCamera('clipBottom', 'other')

	makeLuaSprite('fade', '', 0, 0);
	makeGraphic('fade', screenWidth, screenHeight, '000000')
	setObjectCamera('fade', 'other')
	setProperty('fade.alpha', 0)
	addLuaSprite('fade', true);

	if not lowQuality then
		if songName == 'pop' and doIntro and not seenCutscene then

			makeLuaSprite('introHide', '', 0, 0);
			setScrollFactor('introHide', 0, 0);
			addLuaSprite('introHide', true);
			scaleObject('introHide', '1.3','1.3');
			makeGraphic('introHide', screenWidth, screenHeight, '000000')
		
			makeLuaSprite('introPop', hud..'intros/intro_pop', 0, 0);
			setScrollFactor('introPop', 0, 0);
			addLuaSprite('introPop', true);
			scaleObject('introPop', '0.8','0.8');
			screenCenter('introPop')
			setProperty('introPop.alpha', 0)
		end
	
	end

	if songName == 'shimmer' then
		if not enableLight then
			startColorTween()
		end
		drunkMode = true
	end


end

function onUpdate(elapsed)

	if songName == 'shimmer' then
		songPos = getSongPosition();
   		local currentBeat = (songPos / 1000) * (bpm / 120)

		if drunkMode then

			daElapsed = elapsed * 30
			i = i + daElapsed

			local wobbleOffsetX = math.sin(currentBeat + i/10) * wobbleAmount * wobbleSpeed
			local wobbleOffsetY = math.cos(currentBeat + i/10) * wobbleAmount * wobbleSpeed

			local baseX = getProperty('camFollow.x') 
			local baseY = getProperty('camFollow.y')

			triggerEvent('Camera Follow Pos', baseX + wobbleOffsetX, baseY + wobbleOffsetY)

		end

		if doThing == true then
			for i = 0,7 do 
				setPropertyFromGroup('strumLineNotes', i, 'x',	strumDefaultX[i] + arrowMoveX * math.sin((currentBeat + i*0.25) * math.pi))
				setPropertyFromGroup('strumLineNotes', i, 'y',	strumDefaultY[i] + arrowMoveY* math.cos((currentBeat + i*0.25) * math.pi))
				noteTweenAlpha("movementAlpha " .. i, i, 1, 2, "linear")
			end

		else
			for i = 0,7 do 
                setPropertyFromGroup('strumLineNotes', i, 'alpha', alpha)
            end
		end
		
	end

------------------ SHAKE

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

------------------ CHARACTERS PROPERTIES
	if showLucy then
		setProperty('dad.alpha', 1)
	else
		setProperty('dad.alpha', 0)
	end

	if showNova then
		setProperty('boyfriend.alpha', 1)
	else
		setProperty('boyfriend.alpha', 0)
	end
	
	
------------------ ASSETS PROPERTIES
	addOffset('dagf','baddie2sit', 15, 30)
	addOffset('jazz','baddiesit', 12, -15)
	addOffset('jazz','talking', 12, -5)
	addOffset('dagf','talking', 17, 30)
	addOffset('jazz','wait', 13, 35)
	addOffset('dagf','wait', 32, 16)
	addOffset('jazz','end', 13, 35)
	addOffset('dagf','end', 45, 46) 
	addOffset('jazz','shocked', 12, 58) 
	addOffset('dagf','shocked', 63, 23)

	addOffset('tanisha','umm', -160, 0)
	addOffset('tanisha','end', -50, 130)

	--fog
	if not lowQuality then
		if enableFog then
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

			if songName == 'shimmer' then
				addOffset('nikShim','end', 100, 0)
				addOffset('numbShim','end', 100, 20)
			end
		end
	end

------------------ ASSETS PROPERTIES
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

		[128] = function() --testing space
			cameraFlash('other', 'FFFFFF', 1, false)
		end,


		[919] = function() --913
			if songName == 'pop' and not lowQuality then
				forceCam = true
				followchars = false

				camX = 600
				camY = 650

				letterBox(1,1,0)
				doTweenAlpha('cyaHUD', 'camHUD', 0, 0.5, 'backIn')

				runTimer('startTheDrawSFX', 0.5,1);
				runTimer('startTheDraw', 1,1);
			end
		end,

		
		[1152] = function() --ending dance
			if songName == 'shimmer' and not lowQuality then
				letterBox(2,2,0)
				startDancing()
				triggerBlur()
			end
		end,

	}

-- EVENT FUNCTIONS
	function startDraw()
		doZoom = false
		peepsBop = false
		showLucy = false
		showNova = false

		--camera
		startSmoothShake(2, 1)
		cancelTween('toLucy')
		cancelTween('toNova')

		setProperty('defaultCamZoom',0.85) 
		doTweenZoom('panOut', 'camGame', '0.85', 0.5, 'quadOut')

		--sprite
		setProperty('lucyending.visible', true)
		setProperty('novaending.visible', true)
		addAnimationByPrefix('lucyending', 'end', 'DRAW', 24, false);
		addAnimationByPrefix('novaending', 'end', 'DRAW', 24, false);

		playAnim('dagf', 'shocked',false, false, 1)
		playAnim('jazz', 'shocked',false, false, 1)
		objectPlayAnimation('tanisha', 'shocked',false)

		runTimer('startCutaway', 6,1);
		runTimer('impactZoom', 0.3,1);
		
	end

	function startDancing()

		forceCam = true
		followchars = false
		drunkMode = false
		
		showLucy = false
		showNova = false
		peepsBop = false

		setProperty('defaultCamZoom',0.85) 

		cameraFlash('other', 'FFFFFF', 1, false)
		doTweenAlpha('cyaHUD', 'camHUD', 0, 1, 'backIn')

		setProperty('lucyDance.visible', true)
		setProperty('angeloDance.visible', true)
		addAnimationByPrefix('lucyDance', 'dance', 'DANCE', 24, true);
		addAnimationByPrefix('angeloDance', 'dance', 'DANCE', 24, true);

		playAnim('tanisha', 'end', true, false, 1)
		playAnim('numbShim', 'end', true, false, 1)
		playAnim('nikShim', 'end', true, false, 1)
		playAnim('dagf', 'end', true, false, 1)
		playAnim('jazz', 'end', true, false, 1)

		makeLuaSprite('endingFade', '', 0, 0);
		setScrollFactor('endingFade', 0, 0);
		addLuaSprite('endingFade', true);
		scaleObject('endingFade', '1.3','1.3');
		makeGraphic('endingFade', screenWidth, screenHeight, '000000')
		setObjectCamera('endingFade', 'other')
		setObjectOrder('endingFade', 2)
		setProperty('endingFade.alpha', 0)

		camX = 550
		camY = 650
		setProperty('cameraSpeed', 0.3)

		runTimer('panUp', 5.5,1);
		runTimer('fadeAway', 9.5,1);
		runTimer('endSong', 15,1);
	end


	function startColorTween()

		currentColorIndex = currentColorIndex + 1
		if currentColorIndex > #clubColors then currentColorIndex = 1 end

		local nextColor = clubColors[currentColorIndex]
		doTweenColor('colorTween', 'light', nextColor, 1.5, 'linear')

	end

	function letterBox(speed, time, alpha) 
		doTweenY('clip1Move', 'clipTop', 0, speed, 'smootherStepIn')
		doTweenY('clip2Move', 'clipBottom', screenHeight - 50, speed, 'smootherStepIn')
		doTweenAlpha('byebye', 'camHUD', time, alpha, 'backIn')
	end

	function letterBoxOut() 
		doTweenY('clip1Move', 'clipTop', -50, 1, 'smootherStepIn')
		doTweenY('clip2Move', 'clipBottom', screenHeight, 1, 'smootherStepIn')
		doTweenAlpha('hellohello', 'camHUD', 1, 1, 'circOut')
	end
-- MISC FUNCTIONS
	function startSmoothShake(strength, duration)
		shakeStrength = strength or 5
		shakeDuration = duration or 0.5
		shakeTime = shakeDuration
	end

	function triggerBlur()
		runHaxeCode([[
			FlxG.camera.setFilters([new openfl.filters.BlurFilter(12, 12, 2)]);
		]])
		runTimer('clearBlur', 0.25, 1)
	end

	function lerp(a, b, t)
		return a + (b - a) * t
	end

	function onPause()
		pauseSound('buss')
	end

	function onResume()
		resumeSound('buss')
	end

	function onStepHit()
		if stepHitFuncs[curStep] then
			stepHitFuncs[curStep]()
		end

	end

	function onTweenCompleted(tag, loops, loopsLeft)
		
		if tag == 'colorTween' then
			startColorTween()
		end
	end

	function onTimerCompleted(tag, loops, loopsLeft)
	-- INTRO
	
		if tag == 'introShow' then
			setProperty('introPop.alpha', 1)
			runTimer('introFade', 3,1);
		end

		if tag == 'getOuttaHere' then
			doTweenAlpha('delete', 'introHide', 0, 0.5, 'backIn')
			playAnim('jazz', 'talking', false, false, 1)
			playAnim('dagf', 'talking', false, false, 1)
		end

		if tag == 'introFade' then
			doTweenAlpha('goodbyeIntro', 'introPop', 0, 3.5, 'backIn')
		end

		if tag == 'panDown' then
			camY = 650
			setProperty('cameraSpeed', 0.3)
			doTweenZoom('begin', 'camGame', '0.9', 3, 'quadOut')
			runTimer('gameStart', 8,1);
		end

		if tag == 'fuckingOff' then
			addAnimationByPrefix('novaintro', 'intro', 'intro',24,false)
			objectPlayAnimation('novaintro', 'intro',false)
			setProperty('novaintro.visible', true)

			runTimer('removeNovaIntro', 6.4,1);
			runTimer('removeLucyIntro', 5,1);
			runTimer('glassCrashLOL', 3.8,1);
		end

		if tag == 'fuckingOff2' then
			addAnimationByPrefix('lucyintro', 'intro', 'INTRO',24,false)
			objectPlayAnimation('lucyintro', 'intro',false)
			setProperty('lucyintro.visible', true)

		end

		if tag == 'glassCrashLOL' then
			startSmoothShake(10, 0.4)
		end

		if tag == 'fuckingOffGFJazz' then

			debugPrint('do they talk?')
			playAnim('jazz', 'talking', false, false, 1)
			playAnim('dagf', 'talking', false, false, 1)
			runTimer('removeJasGFIntro', 6.5,1);
		
		end

		if tag == 'removeLucyIntro' then
			setProperty('lucyintro.visible', false)
			showLucy = true
		end

		if tag == 'removeNovaIntro' then
			setProperty('novaintro.visible', false)
			showNova = true
		end

		if tag == 'removeJasGFIntro' then
			playAnim('jazz', 'baddiesit',false, false, 1)
			playAnim('dagf', 'baddie2sit',false, false, 1)
			
		end

		if tag == 'gameStart' then
			forceCam = false
			peepsBop = true
			doZoom = true

			setProperty('cameraSpeed', 0.8)
			letterBoxOut()
		end

		
	--CUTAWAY

	
		if tag == 'startTheDrawSFX' then
			playSound(sounds.. 'stripClubEnding', 1, 'buss')
		end

		if tag == 'startTheDraw' then
			startDraw()
		end

		if tag == 'startCutaway' then
			setProperty('cutawaybg.visible', true)
			setProperty('carcutaway2.visible', true)
			setProperty('carcutaway.visible', true)
			runTimer('drivecar1', 1,1);
			runTimer('drivecar2', 2,1);
			runTimer('cutback', 6,1);
		end

		if tag == 'impactZoom' then
			setProperty('defaultCamZoom',0.9) -- this is lucy
			doTweenZoom('moveOut', 'camGame', '0.9', 1, 'quadOut')
		end

		if tag == 'drivecar1' then
			doTweenX('carmove', 'carcutaway', 1700, 4, 'smootherStepIn')
		end

		if tag == 'drivecar2' then
			doTweenX('carmove2', 'carcutaway2', -1900, 4, 'smootherStepIn')
		end

		if tag == 'cutback' then
			setProperty('cutawaybg.visible', false)
			setProperty('carcutaway2.visible', false)
			setProperty('carcutaway.visible', false)
			peepsBop = false
			
			playAnim('tanisha', 'umm',false, false, 1)
			playAnim('jazz', 'wait',false, false, 1)
			playAnim('dagf', 'wait',false, false, 1)

			setProperty('age.visible', false)
			setProperty('ash.visible', false)
			setProperty('nikShim.visible', false)
			setProperty('numbShim.visible', false)
			setProperty('dar.visible', false)
			setProperty('dev.visible', false)
			setProperty('mind.visible', false)

			setProperty('clipTop.visible', true)
			setProperty('clipBottom.visible', true)
		
		end

	--SHIMMER END
		if tag == 'panUp' then
			camY = -400
			setProperty('cameraSpeed', 0.1)
		end

		if tag == 'startFade' then
			doTweenAlpha('goodbye2', 'fadeOut', 0, 1, 'linear')
		end

		if tag == 'fadeAway' then
			doTweenAlpha('endingShart', 'endingFade', 1, 2, 'quadOut')
		end

		if tag == 'endSong' then
			endSong()
		end

		if tag == 'clearBlur' then
			runHaxeCode("FlxG.camera.setFilters([]);")
		end
	end

	function onBeatHit()
		if curBeat % 1 == 0 then
			objectPlayAnimation('nik', 'brr',true)
			objectPlayAnimation('numb', 'mulah',true)
			objectPlayAnimation('age', 'bop5', true);

			if peepsBop then
				playAnim('jazz', 'baddiesit', false, false, 1)
				playAnim('dagf', 'baddie2sit', false, false, 1)
				
				objectPlayAnimation('numbShim', 'dance', true);
				objectPlayAnimation('nikShim', 'dance', true);
			end

			if showPeeps then
				objectPlayAnimation('dar', 'bop4', true);
				objectPlayAnimation('mind', 'bop1', true);
				objectPlayAnimation('ash', 'bop3', true);
				objectPlayAnimation('dev', 'bop2', true);
			end

			objectPlayAnimation('dar', 'dance', true);
			objectPlayAnimation('ash', 'dance', true);
			objectPlayAnimation('jer', 'dance', true);
			objectPlayAnimation('gen', 'dance', true);

		
			if songName == 'pop' or songName == 'shimmer' then
				if getProperty('dad.animation.curAnim.name') == 'idle' then
					characterPlayAnim('dad','idle',true)
				end
			end
		end

		if peepsBop then
			if curBeat % 2 == 0 then
				objectPlayAnimation('tanisha', 'half1', false);
			else
				objectPlayAnimation('tanisha', 'half2', false);
			end
		end


	end

	function onSectionHit()
		if not doZoom then return end

		if mustHitSection == false then
			doTweenZoom('toLucy', 'camGame', '0.9', 1, 'circOut')
			setProperty('defaultCamZoom',0.9)
			cancelTween('toNova')
		else
			doTweenZoom('toNova', 'camGame', '0.95', 1, 'circIn')
            setProperty('defaultCamZoom',0.95) 
			cancelTween('toLucy')
        end
	end