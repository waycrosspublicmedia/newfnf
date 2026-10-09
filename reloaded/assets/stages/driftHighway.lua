local xx, yy = 390, 600;
local xx2, yy2 = 530, 600;
local ofs = 45;
local del, del2, i, followchars = 0, 0, 0, false;
local doCopIntro, doDialogue, doEndingDialogue, doZoom = true, true, true, true
local showfirstStage, showSecondStage = true, false

local introCall, momSpeak = true, false

if not isStoryMode then
	local allowCountdown = false
end

local ambientLight, highwayColor = getColorFromHex('f2bfff'), getColorFromHex('80EDE9') 

local stage, stage2, ending, hud = 'stages/week2/HIGHWAY/', 'stages/week2/BRIDGE/', 'stages/week2/BRIDGE/ending/','stages/hudelements/'
local spritesToRemove = {'skySimple', 'buildingBG', 'leftB', 'rightB', 'ground', 'lightboounce', 'blurCar', 'helicopter', 'helicopter2', 'policeLucy', 'parents', 'comic', 'SMACKLOL', 'angeloPrep', 'policeLight'};
local spritesToRemove2 = {'carBG', 'swoopIn', 'frontCarBG', 'moms', 'seats', 'tintInCar'};

local shakeDuration, shakeTime, shakeStrength, shakeCam = 0, 0, 0, 'camGame';

local lastDadAnim = ''
local blastOffX = 0
local blastOffY = 0
local blastTargetX = 0
local blastTargetY = 0

local blastDelay = 0
local blastDelayMax = 0.07
local blastStrength = 38
local blastReturn = 16
local blastFollow = 5

function onCreatePost() 

	if showfirstStage then
		if songName == 'Drift' and doCopIntro and not isStoryMode then
			setProperty(camX, 800);
			setProperty(camY, -1700);

			setProperty('camGame.zoom',1.2)
			setProperty('camHUD.alpha', 0)

			runTimer('panDown', 3,1);
			letterBox(3, 3);
		end

		if songName == 'Drift' and isStoryMode then
			if enableLights then
				setProperty('lightTint.alpha', 0)
				setProperty('policeLight.alpha', 0)
			end
			setProperty('camGame.zoom',1.1)
			followchars = true;
			setProperty(camX, 400);
		end
	end

	if not lowQuality then
		------------- INSIDE CAR --------------------
		precacheImage(stage..'TRANSITION/textBG')
		precacheImage(stage..'TRANSITION/carshit2')
		precacheImage(stage..'TRANSITION/MOMMY')
		precacheImage(stage..'TRANSITION/carshit1')
		precacheImage(stage..'TRANSITION/ANGELO INTRO IN CAR')
		precacheImage(stage..'TRANSITION/carInterior')
		------------- SECOND STAGE --------------------
		precacheImage(stage2..'skyBG')
		precacheImage(stage2..'city')
		precacheImage(stage2..'street')
		precacheImage(stage2..'bridge')
		if enableLights then
			precacheImage(stage2..'lightsAbove')
		end
		precacheImage(stage2..'police')
		precacheImage(stage2..'car')
		------------- ENDING ------------------------
		precacheImage(stage2..'ending/sideProfileBG')
		precacheImage(stage2..'ending/bg')
		precacheImage(stage2..'ending/stephanieEnd')
		precacheImage(stage2..'ending/angeloEnd')
		precacheImage(stage2..'ending/car')

		addCharacterToList('nova-drift', 'bf')
	end

	if not doCopIntro then
		followchars = true;
		introCall = false
		momSpeak = true
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
end


function onCountdownStarted()
	if songName == 'drift' and isStoryMode then
		if enableLights then
			doTweenAlpha('comeBackLight1', 'lightTint', 1, 0.5, 'backIn')
			doTweenAlpha('comeBackLight2', 'policeLight', 1, 0.5, 'backIn')
		end
	end
end

function onCreate()

	camX = 'camFollow.x';	
	camY = 'camFollow.y';

	setPropertyFromClass('substates.GameOverSubstate', 'deathSoundName', 'DEATH/novaDeath');
	setPropertyFromClass('substates.GameOverSubstate', 'loopSoundName', 'DEATH/reloadedGameOver'); --put in mods/music/

	if showfirstStage then

		makeLuaSprite('skySimple', stage..'SKYBOX', 100, 50);
		setScrollFactor('skySimple', 0, 0);
		addLuaSprite('skySimple', false);
		scaleObject('skySimple', '0.9','0.7');
		
		makeLuaSprite('buildingBG', stage..'BUILDINGS MAIN', -150, -350);
		setScrollFactor('buildingBG', 0.4, 0.6);
		addLuaSprite('buildingBG', false);
		scaleObject('buildingBG', '0.9','0.9');
		setProperty('buildingBG.alpha', 0.4)
		
		if not lowQuality then
			makeAnimatedLuaSprite('leftB', stage..'leftBuild', -570, -100) 
			addAnimationByPrefix('leftB', 'boppin', 'leftBuild', 24, true)
			setScrollFactor('leftB', 0.6, 0.9);
			scaleObject('leftB', '1','1.2');
			objectPlayAnimation('leftB', 'boppin', false)
			addLuaSprite('leftB', false)
			
			makeAnimatedLuaSprite('rightB', stage..'rightBuild', 970, -100) 
			addAnimationByPrefix('rightB', 'boppin', 'rightBuild', 24, true)
			setScrollFactor('rightB', 0.6, 0.9);
			scaleObject('rightB', '1','1.2');
			objectPlayAnimation('rightB', 'boppin', false)
			addLuaSprite('rightB', false)

			if enableLights then
				makeAnimatedLuaSprite('lightboounce', stage..'lightBounce', -470, 350) 
				addAnimationByPrefix('lightboounce', 'boppin', 'LIGHT N SMOOKE', 32, true)
				setScrollFactor('lightboounce', 0.4, 0.9);
				scaleObject('lightboounce', '1.1','1');
				objectPlayAnimation('lightboounce', 'boppin', false)
				setBlendMode('lightboounce', 'SCREEN')
				addLuaSprite('lightboounce', false)
			end

		end

		makeAnimatedLuaSprite('blastStreak', stage..'blasting', getProperty('dad.x'), 350) 
		addAnimationByPrefix('blastStreak', 'zoom', 'lineBoost', 28, true)
		setScrollFactor('blastStreak', 0.9, 0.7);
		scaleObject('blastStreak', '1.2','1.2');
		objectPlayAnimation('blastStreak', 'zoom', false)
		setBlendMode('blastStreak', 'SCREEN')
		addLuaSprite('blastStreak', true)

		makeAnimatedLuaSprite('ground', stage..'road', -600, 700) 
		addAnimationByPrefix('ground', 'boppin', 'highWay', 24, true)
		setScrollFactor('ground', 1, 0.9);
		scaleObject('ground', '1.25','1');
		objectPlayAnimation('ground', 'boppin', false)
		addLuaSprite('ground', false)

		if not lowQuality then -- blur cars, helicopters, lucys car
			makeLuaSprite('blurCar', stage..'lolblurCars', 500, 715);
			setScrollFactor('blurCar', 0.8, 1);
			addLuaSprite('blurCar', false);
			scaleObject('blurCar', '1','1');

			makeAnimatedLuaSprite('helicopter', stage..'heli2', 650, 80) --right
			addAnimationByPrefix('helicopter', 'hover', 'HELI 2', 24, true)
			setScrollFactor('helicopter', 1.4, 0.50);
			scaleObject('helicopter', '1','1');
			objectPlayAnimation('helicopter', 'hover',false)
			addLuaSprite('helicopter',false)

			makeAnimatedLuaSprite('helicopter2', stage..'heli1', -470, -70) --left
			addAnimationByPrefix('helicopter2', 'hover', 'HELI 1', 24, true)
			setScrollFactor('helicopter2', 1.2, 0.5);
			scaleObject('helicopter2', '0.8','0.8');
			objectPlayAnimation('helicopter2', 'hover',false)
			addLuaSprite('helicopter2',false)
			
			makeAnimatedLuaSprite('policeLucy', stage..'policeCar', 120, 630) -- 900x 620y
			addAnimationByPrefix('policeLucy', 'drivee', 'policeCar', 20, true)
			setScrollFactor('policeLucy', 0.9, 1);
			scaleObject('policeLucy', '1.15','1');
			addLuaSprite('policeLucy', false)
			playAnim('policeLucy', 'drivee',true)
		end

		makeAnimatedLuaSprite('parents', stage..'parentsCar', 787, 630) ------------- PARENTS CAR
		addAnimationByPrefix('parents', 'fly', 'CAR FLY0', 24, false)
		addAnimationByPrefix('parents', 'idle', 'PARENTS CAR0', 24, true)
		addAnimationByPrefix('parents', 'station', 'STATIONARY', 24, true)
		setScrollFactor('parents', 1.4, 1);
		scaleObject('parents', '1','1');
		addLuaSprite('parents', false)
		addOffset('parents','fly', 285, 345) -- x 295, y 315
		addOffset('parents','idle', 59, 5)
		setProperty('parents.visible', false)
		playAnim('parents', 'idle',true)

		if not lowQuality then

			makeLuaSprite('comic', stage..'TRANSITION/DINGG', -300, 0);
			setScrollFactor('comic', 0.2, 0);
			addLuaSprite('comic', false);
			scaleObject('comic', '1.2','1');
			setProperty('comic.visible', false)
		end

		makeAnimatedLuaSprite('SMACKLOL', stage..'TRANSITION/SMACK', -250, 400)
		addAnimationByPrefix('SMACKLOL', 'damn', 'SMACKCAM', 24, false)
		setScrollFactor('SMACKLOL', 0.9, 0.7);
		scaleObject('SMACKLOL', '0.6','0.6');
		addLuaSprite('SMACKLOL', true)
		setProperty('SMACKLOL.visible', false)

		makeAnimatedLuaSprite('angeloPrep', stage..'TRANSITION/ANGELO INTRO', 180, 110) 
		addAnimationByPrefix('angeloPrep', 'yup', 'ANGELO INTRO', 24, false)
		setScrollFactor('angeloPrep', 1.4, 0.9);
		scaleObject('angeloPrep', '0.9','0.9');
		addLuaSprite('angeloPrep', false)
		setProperty('angeloPrep.visible', false)


	end

	if not lowQuality then

		makeLuaSprite('tint', '', -300, -100);
		setScrollFactor('tint', 0, 0);
		makeGraphic('tint', screenWidth, screenHeight, 'fd67bd')
		setProperty('tint.alpha', 0.2)
		scaleObject('tint', '1.4','1.4');

		if enableLights then
			makeLuaSprite('lightTint', hud..'4-hudShit/LIGHTTEST', -700, 0);
			setScrollFactor('lightTint', 0, 0);
			scaleObject('lightTint', '1.7','1.2');
			setBlendMode('lightTint', 'SCREEN')
			setProperty('lightTint.color', ambientLight)
			setProperty('lightTint.alpha', 0.65)
			setProperty('lightTint.flipY', true)
		
			makeLuaSprite('policeLight', hud..'4-hudShit/copOverlay', 0, 0);
			setBlendMode('policeLight', 'ADD')
			setProperty('policeLight.alpha', 1)
			setObjectCamera('policeLight', 'camFilm')
		end

		setObjectOrder('tint', 70)
		setObjectOrder('lightTint', 70)
		addLuaSprite('lightTint', true);
		--setObjectCamera('lightTint', 'camFilm')

		addLuaSprite('tint', true);
	end

	makeLuaSprite('phone', hud..'4-hudShit/phone/phone_unknown', -250, 200); -- x is 50
	scaleObject('phone', '0.6','0.6');
	addLuaSprite('phone', true);
	setObjectCamera('phone', 'other')

	makeLuaText('subtitles', '', '300', '70', '320') -- x is 70
	setTextFont('subtitles', 'veteran typewriter.ttf')
	setTextAlignment('subtitles', 'left')
	setObjectCamera('subtitles', 'other')
	setTextSize('subtitles','20')
	setTextString('subtitles', 'Cop Pilot: My good sir, we have eyes on a caucasian woman and a gent of cinnamon-esque complexion down the boulevard. Deploy the artillery... POST HASTE! -british noises-')
	setTextBorder('subtitles', '1', 'f566cc')
	setProperty('subtitles.visible', true)
	setProperty('subtitles.alpha', 0)
	addLuaText('subtitles')

	makeLuaSprite('fade', '', 0, 0);
	scaleObject('fade', '1.2','1.2');
	makeGraphic('fade', screenWidth, screenHeight, '000000')
	setProperty('fade.alpha', 0)
	setObjectCamera('fade', 'other')
	addLuaSprite('fade', true);
	
	-- LETTERBOX
	makeLuaSprite('clipTop', '', 0, -50);
	makeGraphic('clipTop', screenWidth, 50, '000000')
	setObjectCamera('clipTop', 'other')

	makeLuaSprite('clipBottom', '', 0, screenHeight);
	makeGraphic('clipBottom', screenWidth, 50, '000000')
	setObjectCamera('clipBottom', 'other')

	addLuaSprite('clipTop', false);
	addLuaSprite('clipBottom', false);

end

function onUpdate(elapsed)

	-- ===================
	-- CUSTOM FUNCTIONS
	-- ===================

	-- shake
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

	-- blur
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

	-- ===================
	-- CHARACTER SHIT
	-- ===================
	setProperty('gf.alpha', 0)

	stephaniesX = getProperty('dad.x')
	stephaniesY = getProperty('dad.y')

	local anim = getProperty('dad.animation.curAnim.name')

	if anim ~= lastDadAnim then
		-- only add delay when ENTERING a sing anim
		if string.find(anim, 'sing') then
			blastDelay = blastDelayMax
		end
		lastDadAnim = anim
	end
	blastTargetX = 0
	blastTargetY = 0

	if anim == 'singLEFT' or anim == 'singLEFT-alt' then
		blastTargetX = -blastStrength

	elseif anim == 'singRIGHT' or anim == 'singRIGHT-alt' then
		blastTargetX = blastStrength

	elseif anim == 'singUP' or anim == 'singUP-alt' then
		blastTargetY = -blastStrength

	elseif anim == 'singDOWN' or anim == 'singDOWN-alt' then
		blastTargetY = blastStrength
	end

	-- delay countdown
	if blastDelay > 0 then
		blastDelay = blastDelay - elapsed
	else
		local speed = blastReturn
		if blastTargetX ~= 0 or blastTargetY ~= 0 then speed = blastFollow end

		local t = math.min(1, elapsed * speed)
		blastOffX = blastOffX + (blastTargetX - blastOffX) * t
		blastOffY = blastOffY + (blastTargetY - blastOffY) * t
	end

	setProperty('blastStreak.x', stephaniesX - 20 + blastOffX)
	setProperty('blastStreak.y', stephaniesY + 80 + blastOffY)
	
	setProperty('dad.scrollFactor.x', 0.7);
	setProperty('dad.scrollFactor.y', 0.7);

	setProperty('boyfriend.scrollFactor.x', 1.4);
	setProperty('boyfriend.scrollFactor.y', 0.9);

	if curStep > 1966 then
		setProperty('boyfriend.alpha', 0)
		setProperty('dad.alpha', 0)
	end

	-- ===================
	-- CAM ZOOMS
	-- ===================

	if doZoom then
		if curStep >= 0 and curStep < 1039 then
			if mustHitSection == false then
				doTweenX('dadscaleX', 'boyfriend.scale', 1, 0.5, 'linear');
				doTweenY('dadscaleY', 'boyfriend.scale', 1, 0.5, 'linear');
				
				setProperty('defaultCamZoom',1.3)
			else
				setProperty('defaultCamZoom',1.2)
				doTweenX('dadscaleX', 'boyfriend.scale', 0.8, 0.5, 'linear');
				doTweenY('dadscaleY', 'boyfriend.scale', 0.8, 0.5, 'linear');
			
			end

			if luaSpriteExists('buildingBG') then
				scaleX = getProperty('buildingBG.scale.x')
				scaleY = getProperty('buildingBG.scale.y')
				buildX = getProperty('buildingBG.x')
				buildY = getProperty('buildingBG.y')
				buildAlpha = getProperty('buildingBG.alpha')

				local t = math.min(1, elapsed * 0.03)

				scaleX = scaleX + (0.3 - scaleX) * t
				scaleY = scaleY + (0.3 - scaleY) * t
				buildY = buildY + (5 - buildY) * t
				buildX = buildX - (0.9 - buildX) * t
				buildAlpha = buildAlpha + (0 - buildAlpha) * t

				setProperty('buildingBG.scale.x', scaleX)
				setProperty('buildingBG.scale.y', scaleY)
				setProperty('buildingBG.x', buildX)
				setProperty('buildingBG.y', buildY)
				setProperty('buildingBG.alpha', buildAlpha)
			end

		elseif curStep > 1039 and curStep < 1152 then
			setProperty('defaultCamZoom',1)
			doTweenZoom('fixed', 'camGame', '1', 0.3, 'quadOut')
		
		elseif curStep > 1152 and curStep < 1968 then

			if mustHitSection == false then
				doTweenX('dadscaleX', 'dad.scale', 0.8, 0.5, 'quadIn');
				doTweenY('dadscaleY', 'dad.scale', 0.8, 0.5, 'quadIn');
				
				setProperty('defaultCamZoom',1.2)
			else
				setProperty('defaultCamZoom',1.1)
				doTweenX('dadscaleX', 'dad.scale', 0.6, 0.5, 'quadOut');
				doTweenY('dadscaleY', 'dad.scale', 0.6, 0.5, 'quadOut');
			
			end
		else
			setProperty('defaultCamZoom',1)
			doTweenZoom('fixed', 'camGame', '1.1', 0.3, 'quadOut')
		end

	end


	daElapsed = elapsed * 30
	i = i + daElapsed

	-- ===================
	-- PROPERTIES
	-- ===================

	if luaSpriteExists('seats') then
		setObjectOrder('tint', getObjectOrder('seats') + 20)
	end

	-- function for hovering stephanie and helicopters
	if curStep > 0 and curStep < 997 and songName == 'Drift' then

		setProperty('helicopter2.x', (math.sin(i/15)*50) - 450) -- left
		setProperty('helicopter2.y', (math.sin(i/5)*10) - 50)
		setProperty('helicopter.x', (math.sin(i/6)*19) + 650) -- right
		setProperty('helicopter.y', (math.sin(i/9)*17) + 100)

		setProperty('dad.y', (math.sin(i/20)*50) + 250)
		yy = (math.sin(i/20)*50) + 600

		if enableLights then
			setProperty('lightTint.flipY', true)
		end

	elseif curStep > 1040 and songName == 'Drift' then

		setProperty('dad.y', (math.sin(i/20)*30) + 250)
		yy = (math.sin(i/20)*30) + 600

		if enableLights then
			setProperty('lightTint.flipY', false)
		end
	end

	-- moving cameras for car trans
	if songName == 'Drift' then
		if curStep >= 912 and curStep < 920 then -- 8 steps hits
			setProperty('defaultCamZoom',1.2)
			setProperty('cameraSpeed', 1)
			setProperty(camX, 600);
			setProperty(camY, 300);
			followchars = false
		elseif curStep >= 920 and curStep < 936 then -- 16 hits i believe this is where the parents drop
			setProperty('defaultCamZoom',1.1)
			setProperty(camX, 800);
			setProperty(camY, 700);

		elseif curStep > 936 then
			followchars = true
		end

	end

	-- shaking moments
	if curStep > 996 and curStep < 1000 then 
		cameraShake('camGame', 0.03, 0.5)
	elseif curStep > 1020 and curStep < 1022 then 
		cameraShake('camGame', 0.01, 0.5)
	elseif curStep > 1042 then
		cameraShake('other', 0.0005, 0.5)
	else
		startSmoothShake(4, 0.2)
	end

	if curStep >= 1005 and curStep < 1040 and songName == 'Drift' then 
		setProperty('defaultCamZoom',1.2)
		setProperty('cameraSpeed', 0.4)
		followchars = false
		setProperty(camX, 800);
		setProperty(camY, 650);

	elseif curStep >= 1040 and curStep < 2000 and songName == 'Drift' then
		followchars = true
	end



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

stepHitFuncs = { 

	[912] = function() -- parents drop in
		doTweenZoom('goIn', 'camGame', '1.2', 0.5, 'bounceOut')
		playAnim('parents', 'fly', false)
		runTimer('shake', 0.9,1);
		runTimer('regularMotion', 1.7,1);
		setProperty('parents.visible', true)
		followchars = false;
		
		playSound('DRIFT/parentsDrop', 0.5) -- sfx
	end,
	

	[975] = function() 
		setUpTrans()
	end,


	[1966] = function() 
		daEnding()
	end,

}

function onStepHit()
	if stepHitFuncs[curStep] then
		stepHitFuncs[curStep]()
	end

end

------------------------------------------------- TWEENS AND TIMERS SHITS AND MISC
function onTweenCompleted(tag, loops, loopsLeft)
	if tag == 'impactshot' then
		doTweenZoom('moveBack', 'camOther', '1', 1, 'circOut')
		
	end

	if tag == 'moveBack' then -- turns back to nova

		setProperty('bgCity.visible', false)
		setProperty('stephanieShotBG.visible', false)
		setProperty('stephanieShot.visible', false)
		setProperty('car.visible', false)
		setProperty('car2.visible', false)
		setProperty('parentsCar.visible', false)
	
		setProperty('angeloShoot.visible', true)
		setProperty('carBehind.visible', true)

		addAnimationByPrefix('angeloShoot', 'heshot', 'novaBase', 24, false)
		objectPlayAnimation('angeloShoot', 'heshot',false)

		doTweenX('angeloMoveX', 'angeloShoot', 300, 4, 'quadOut')
		doTweenX('carMoveX', 'carBehind', -200, 4, 'quadOut')
		doTweenX('roadMoveX', 'road', -700, 4, 'quadOut')
		doTweenX('bridgeMoveX', 'bridgeLOL', -700, 4, 'quadOut')
		
		setProperty('road.flipX', true)
		setProperty('road.x', -600)--
		setProperty('road.y', 580) 
		setProperty('road.angle', -10)--

		setProperty('bridgeLOL.flipX', true)
		setProperty('bridgeLOL.angle', -10)--
		setProperty('bridgeLOL.x', -600)--
		setProperty('bridgeLOL.y', -100)

		setProperty('lights.x', -700)
		setProperty('lights.y', -250)
		setProperty('lights.flipX', true)
		setProperty('lights.angle', -10)

		setProperty('cityshart.x', 200)
		setProperty('cityshart.y', -100)
		setProperty('cityshart.flipX', true)
		setProperty('cityshart.angle', -10)
		
		cameraShake('other', 0.001, 4)

	end

end

function onTimerCompleted(tag, loops, loopsLeft)

	if tag == 'comicAppear' then
	
		setProperty('comic.visible', true)
		doTweenX('comicmove', 'comic', -450, 1, 'smootherStepOut')
		setProperty('dad.alpha', 0)
		playAnim('SMACKLOL', 'damn',true)
		setProperty('SMACKLOL.visible', true)
		playAnim('parents', 'station',true)

		setProperty('blastStreak.alpha', 0)
		
		doTweenZoom('impact', 'camGame', '1.4', 0.4, 'circOut')
		cameraFlash('other', 'ffffff', 0.5, false)
		setProperty('cameraSpeed', 0.1)
	
		runTimer('comicbye', 0.7,1);
		runTimer('cameramove', 1.2,1);

		followchars = false
	end

	if tag == 'cameramove' then
		
		setProperty(camX, 800);
		setProperty(camY, 650);
		
	end


	if tag == 'comicbye' then
		
		doTweenAlpha('comicbyebye', 'comic', 0, 0.5, 'smootherStepOut')
		doTweenX('stepbye', 'SMACKLOL', -100, 0.5, 'backOut')
		setProperty('SMACKLOL.visible', false)
		runTimer('delete', 2.8,1);
		
	end
	if tag == 'delete' then -- he enters the car and all the assets are removed
	
		removeStageSpritesMain()
		insideCar()
		
	end
	if tag == 'jumpin' then
	
		setProperty('swoopIn.visible', true)
		playAnim('swoopIn', 'wee',true)
		
	end

	if tag == 'setparents' then
	
		setProperty('frontCarBG.visible', true)
		setProperty('moms.visible', true)
		setProperty('seats.visible', true)
		setProperty('swoopIn.visible', false)
		
		playAnim('moms', 'blah',true)

	end

	if tag == 'deleteparents' then
		setProperty('frontCarBG.visible', false)
		setProperty('moms.visible', false)
		setProperty('seats.visible', false)
		setProperty('swoopIn.visible', true)
	end

	if tag == 'fadeIn' then
		doTweenAlpha('transIn', 'fade', '1', 0.5, 'circOut')

		runTimer('fadeOut', 1,1);
	elseif tag == 'fadeOut' then
		doTweenAlpha('transIn', 'fade', '0', 0.5, 'circIn')
	end

	if tag == 'spawnNextStage' then ------------ THIS SPAWNS IN THE SECOND STAGE ---------------
	
		removeCarTransition()
		secondStage()

		followchars = false
		if enableLights then
			setProperty('lightTint.alpha', 0.7)
		end

		setProperty('boyfriend.alpha', 1)
		doTweenZoom('hiii', 'camGame', '0.9', 1, 'bounceIn')
	
		triggerEvent('Change Character', 0, 'nova-drift');
		setProperty('boyfriend.y', 180)
		setProperty('dad.alpha', 1)
	
		letterBoxOut(3, 1);

	end
	
	if tag == 'regularMotion' then
	
		playAnim('parents', 'idle', true)

	end
	if tag == 'shake' then
		cameraShake('camGame', 0.006, 0.5)
	
	end

	-- ===================
	-- INTRO
	-- ===================
	if tag == 'panDown' then
		if not lowQuality then 
			phoneCall()
		end
		followchars = true;
		setProperty('cameraSpeed', 0.2)
		runTimer('gameStart', 8,1);

	end
	if tag == 'gameStart' then
		
		doTweenZoom('begin', 'camGame', '1.1', 1, 'bounceIn')
		doTweenAlpha('hello', 'camHUD', 1, 0.5, 'backIn')
		setProperty('cameraSpeed', 1)
		
		introCall = false
		letterBoxOut(3, 3)
		
	end

	-- ===================
	-- ENDING
	-- ===================

	if tag == 'flashandshake' then -- when stephanie gets shot in the end
		doTweenZoom('impactshot', 'camOther', '1', 1, 'circOut')
		startSmoothShake(4, 7)
		flashGrab(2, 1)
	end

	if tag == 'fadeOutEnding' then
		doTweenAlpha('transIn', 'fade', '1', 2, 'quadOut')
		doTweenAlpha('fadeOutLight', 'lights', '0', 1, 'quadOut')
	end

	-- ===================
	-- PHONE
	-- ===================
	if tag == 'movePhoneIn' then
		doTweenX('tweenPhone', 'phone', 50, 1, 'circOut');
	elseif tag == 'movePhoneOut' then
		doTweenX('tweenPhone', 'phone', -250, 1, 'circIn');
	end

	if tag == 'showText' then
		doTweenAlpha('tweenText', 'subtitles', 50, 1, 'smootherStepIn');
	elseif tag == 'fadeText' then
		doTweenAlpha('tweenText', 'subtitles', 0, 1, 'smootherStepIn');
	end

	if tag == 'talks' then

		if doCopIntro then
			momSpeak = true
		else
			momSpeak = true
		end
		phoneCall()
	end

end

-- ===================
-- STAGES
-- ===================

function setUpTrans()
	runTimer('comicAppear', 2,1);
	setProperty('boyfriend.alpha', 0)
	playAnim('angeloPrep', 'yup',true)
	setProperty('angeloPrep.visible', true)

	letterBox(1, 1)
end

function insideCar()

	local scaleShit, xMove = 1, 0
	makeLuaSprite('carBG', stage..'TRANSITION/carInterior', 0, 0);
	scaleObject('carBG', scaleShit, scaleShit);
	addLuaSprite('carBG', false);

	makeAnimatedLuaSprite('swoopIn', stage..'TRANSITION/ANGELO INTRO IN CAR', 40, -140) -- -100x -200y
	addAnimationByPrefix('swoopIn', 'wee', 'angeloJumpIn', 24, false)
	scaleObject('swoopIn', 0.8, 0.8);
	addLuaSprite('swoopIn', false)
	setProperty('swoopIn.visible', false)

	makeLuaSprite('frontCarBG', stage..'TRANSITION/carshit1', xMove, 0);
	addLuaSprite('frontCarBG', false);
	scaleObject('frontCarBG', scaleShit, scaleShit);
	setProperty('frontCarBG.visible', false)

	makeAnimatedLuaSprite('moms', stage..'TRANSITION/MOMMY', 800, -150) -- 800x 620y
	addAnimationByPrefix('moms', 'blah', 'MOMMY TALK', 24, false)
	scaleObject('moms', scaleShit, scaleShit);
	setProperty('moms.visible', false)
	addLuaSprite('moms', false)

	makeLuaSprite('seats', stage..'TRANSITION/carshit2', 100, 0);
	addLuaSprite('seats', false);
	scaleObject('seats', scaleShit, scaleShit);
	setProperty('seats.visible', false)

	makeLuaSprite('tintInCar', '');
	makeGraphic('tintInCar', screenWidth, screenHeight, '33615f')
	setProperty('tintInCar.alpha', 0.2)
	scaleObject('tintInCar', '1','1');
	addLuaSprite('tintInCar', false)

	setScrollFactor('carBG', 0, 0);
	setScrollFactor('swoopIn', 0, 0);
	setScrollFactor('frontCarBG', 0, 0);
	setScrollFactor('moms', 0, 0);
	setScrollFactor('seats', 0, 0);
	setScrollFactor('tintInCar', 0, 0);

	if enableLights then
		setProperty('lightTint.alpha', 0)
	end

	runTimer('jumpin', 0.5,1); -- angelo shows up and jumps in
	runTimer('setparents', 1.5,1); -- shows the parents in their seat
	runTimer('talks', 1,1); -- when mm starts talking
	runTimer('deleteparents', 4.5,1); -- get rid of parents and shows angelo again

	runTimer('fadeIn', 9,1); 
	runTimer('spawnNextStage', 10,1); 
end

function secondStage()

	makeLuaSprite('sky', stage2..'skyBG', -550, 150);
	setScrollFactor('sky', 0.7, 0.8);
	addLuaSprite('sky', false);
	scaleObject('sky', '1','1');
	
	makeLuaSprite('cityshart', stage2..'city', -600, 150);
	setScrollFactor('cityshart', 0.8, 0.7);
	addLuaSprite('cityshart', false);
	scaleObject('cityshart', '1','1');

	makeAnimatedLuaSprite('road', stage2..'street', -670,690)
	addAnimationByPrefix('road', 'moving', 'streetMove',24,true)
	setScrollFactor('road', 0.9, 0.9);
	addLuaSprite('road',false)
	scaleObject('road', '1.1','1');
	objectPlayAnimation('road', 'moving',false)

	makeAnimatedLuaSprite('bridgeLOL', stage2..'bridge', -700,0)
	addAnimationByPrefix('bridgeLOL', 'chuga', 'layer1BG',24,true)
	setScrollFactor('bridgeLOL', 0.9, 0.9);
	addLuaSprite('bridgeLOL',false)
	scaleObject('bridgeLOL', '1.1','1');
	objectPlayAnimation('bridgeLOL', 'chuga',false)
	
	if not lowQuality then
		if enableLights then
			makeAnimatedLuaSprite('lights', stage2..'lightsAbove', 200,0) 
			addAnimationByPrefix('lights', 'wee', 'lightsmove',24,true)
			setScrollFactor('lights', 0.9, 0.9);
			addLuaSprite('lights',false)
			scaleObject('lights', '1.1','1');
			objectPlayAnimation('lights', 'wee',false)
		end

		makeAnimatedLuaSprite('car2', stage2..'police', 590,630)
		addAnimationByPrefix('car2', 'omglucy', 'policeCarMoving',28,true)
		setScrollFactor('car2', 0.9, 0.9);
		addLuaSprite('car2',false)
		scaleObject('car2', '0.35','0.35');
		objectPlayAnimation('car', 'omglucy',false)

		makeAnimatedLuaSprite('car', stage2..'police', 340,530)
		addAnimationByPrefix('car', 'omglucy', 'policeCarMoving',24,true)
		setScrollFactor('car', 0.9, 0.9);
		addLuaSprite('car',false)
		scaleObject('car', '0.9','0.9');
		objectPlayAnimation('car', 'omglucy',false)
	end

	makeLuaSprite('parentsCar', stage2..'car', 590, 180);
	setScrollFactor('parentsCar', 0.9, 0.9);
	addLuaSprite('parentsCar', false);
	scaleObject('parentsCar', '1.2','1');

	makeLuaSprite('highwayTint', '', 0, 0);
	setScrollFactor('highwayTint', 0, 0);
	addLuaSprite('highwayTint', true);
	scaleObject('highwayTint', '1.2','1.2');
	makeGraphic('highwayTint', screenWidth, screenHeight, '80EDE9')
	setProperty('highwayTint.alpha', 0.5)
	setBlendMode('highwayTint', 'MULTIPLY')

	if enableLights then
		setProperty('lightTint.color', highwayColor)
		setProperty('lightTint.alpha', 0.3)
	end
	setProperty('blastStreak.alpha', 1)

end

function daEnding()
	makeLuaSprite('bgCity', ending..'sideProfileBG', 0, 0);
	setScrollFactor('bgCity', 0, 0);

	makeAnimatedLuaSprite('stephanieShotBG', ending..'bg', -150, 50)
	setScrollFactor('stephanieShotBG', 0, 0);
	addAnimationByPrefix('stephanieShotBG', 'bgrunning', 'bgMoving', 24, false)

	makeAnimatedLuaSprite('stephanieShot', ending..'stephanieEnd', 100, 50)
	setScrollFactor('stephanieShot', 0, 0);
	addAnimationByPrefix('stephanieShot', 'sheshot', 'stephanieEnding', 24, false)

	makeLuaSprite('carBehind', ending..'car', 100 + -200, 100);
	setScrollFactor('carBehind', 0, 0);
	
	makeAnimatedLuaSprite('angeloShoot', ending..'angeloEnd', 100 + 300, 0)
	setScrollFactor('angeloShoot', 0, 0);

	makeLuaSprite('highwayTint3', '');
	setScrollFactor('highwayTint3', 0, 0);
	scaleObject('highwayTint3', '1.2','1.2');
	makeGraphic('highwayTint3', screenWidth, screenHeight, '69d1ab')
	setProperty('highwayTint3.alpha', 0.2)

	addLuaSprite('bgCity', false);
	addLuaSprite('stephanieShotBG', false)
	addLuaSprite('stephanieShot', false)
	addLuaSprite('carBehind', false);
	addLuaSprite('angeloShoot', false)
	addLuaSprite('highwayTint3', true);
	
	
	setProperty('bgCity.visible', true)
	setProperty('stephanieShotBG.visible', true)
	setProperty('stephanieShot.visible', true)
	setProperty('carBehind.visible', false)
	setProperty('angeloShoot.visible', false)
	setProperty('blastStreak.visible', false)

	scaleObject('bgCity', '1','1');
	scaleObject('stephanieShotBG', '1','0.8');
	scaleObject('stephanieShot', '0.8','0.8');
	scaleObject('carBehind', '1','1');
	scaleObject('angeloShoot', '0.9','0.9');

	cameraShake('camGame', 0.002, 5)
	runTimer('flashandshake', 0.5,1)
	runTimer('fadeOutEnding', 5, 1)

	triggerBlur()
	letterBox(1,1)
	doTweenAlpha('byebye', 'camHUD', 0, 0.5, 'backIn')

end

function onEndSong()
	if doEndingDialogue and isStoryMode and not censored then
		startDialogue('conclusion', 'dialogueMusic/driftDia') 

		removeEnding()

		letterBoxOut(2, 2);
		setProperty('healthBar.alpha', 0)
		setProperty('scoreTxt.alpha', 0)
		setProperty('missesTxt.alpha', 0)
		doEndingDialogue = false
		return Function_Stop
	end
	if doEndingDialogue and isStoryMode and censored then
		startDialogue('conclusionCensored', 'dialogueMusic/driftDia') 
	
		removeEnding()

		letterBoxOut(2, 2);
		setProperty('healthBar.alpha', 0)
		setProperty('scoreTxt.alpha', 0)
		setProperty('missesTxt.alpha', 0)
		doEndingDialogue = false
		return Function_Stop
	end

	return Function_Continue
end

-- ===================
-- MISC FUNCTIONS
-- ===================

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


function phoneCall()
	
	if introCall then
		runTimer('movePhoneIn', 0.5,1);
		runTimer('showText', 1,1);

		playSound('DRIFT/poshPolice', 1, 'lol')

		runTimer('fadeText', 8,1);
		runTimer('movePhoneOut', 9 ,1);
	elseif momSpeak or isStoryMode then

		setTextString('subtitles', '???: Hey sweetie, underneath you is an AK. Look don’t ask, I made some pretty bad decisions. Just finish the job will you?')
		runTimer('showText', 1,1);
		runTimer('fadeText', 7,1);
	end
	
end

function letterBox(duration, fade) 
	doTweenY('clip1Move', 'clipTop', 0, duration, 'smootherStepIn')
	doTweenY('clip2Move', 'clipBottom', screenHeight - 50, duration, 'smootherStepIn')
	doTweenAlpha('byebye', 'camHUD', 0, 1, 'backIn')
end

function letterBoxOut(duration, fade) 
	doTweenY('clip1Move', 'clipTop', -50, duration, 'smootherStepIn')
	doTweenY('clip2Move', 'clipBottom', screenHeight, duration, 'smootherStepIn')
	doTweenAlpha('hellohello', 'camHUD', 1, 1, 'circOut')
end

function onPause()
	pauseSound('lol')
	pauseSound('intro')
	cameraShake('other', 0, 1)
	return Function_Continue;
end

function onResume()
	resumeSound('lol')
	resumeSound('intro')
end

function removeStageSpritesMain()
    for i = 1, #spritesToRemove do
        removeLuaSprite(spritesToRemove[i], true)
    end
end

function removeCarTransition()
    for i = 1, #spritesToRemove2 do
        removeLuaSprite(spritesToRemove2[i], true)
    end
end

function removeEnding()
	removeLuaSprite('sky', true)
	removeLuaSprite('cityshart', true)
	removeLuaSprite('road', true)
	removeLuaSprite('bridgeLOL', true)
	if not lowQuality then
		if enableLights then 
			removeLuaSprite('lights', true)
		end
		removeLuaSprite('car2', true)
		removeLuaSprite('car', true)
	end
	removeLuaSprite('parentsCar', true)
	removeLuaSprite('highwayTint', true)

	removeLuaSprite('bgCity', true)
	removeLuaSprite('stephanieShotBG', true)
	removeLuaSprite('stephanieShot', true)
	removeLuaSprite('carBehind', true)
	removeLuaSprite('angeloShoot', true)
	removeLuaSprite('highwayTint2', true)

	removeLuaSprite('blastStreak', true)
	if enableLights then
		removeLuaSprite('policeLight', true)
		removeLuaSprite('lightTint', true)
	end

end

