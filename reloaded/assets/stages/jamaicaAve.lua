local baseFPS = 144
ambientLight = getColorFromHex('52b0cd')

local intro, stage, hud = 'stages/week3/jamaica/intro/', 'stages/week3/jamaica/', 'stages/hudelements/'
local sounds, deathSound = 'WEEK2/', 'WEEK2/DEATH/'
local fogPaths = {
  'stages/week3/stripClub/TEST/FOG-1',
  'stages/week3/stripClub/TEST/FOG-3'
}

local firstPhase, secondPhase = false, false
local fogPool = {}
local fogCount = 6
local fogSpeedMin, fogSpeedMax = 250, 450
local fogYMin, fogYMax = 600, 920

--followchars
	local xx, yy = 2750, 500; -- henchman
	local xx2, yy2 = 1150, 780; --bf --1150, 780
	local xx3, yy3 = 1350, 760 -- nova
	local ofs, ofs2, ofs3 = 25, 35, 30;
	local i = 0;
	local followchars, forceCam, allowCountdown, allowDeath, doDialogue = false, false, false, false, true; 
	local doZoom, zoomNumDad, zoomNumBF, zoomNumNov = false, 0.85, 1.1, 1

	local lastSinger = 'dad'

-- main
	local doIntroShit, failedBru = true, false
	local introStage, mainStage, loopStage = true, false, false
	local scrollEase, scrollDirection, scrollEndNum, scroolEndNormal = 0, 0, 0.3, 0.8
	local fadeSpeedX, seatSpeedX, girlSpeedX, guySpeedX, busSpeedX, glassSpeedX, bgSpeedX, peepsSpeedX, fgSpeedX, bgCarSpeedX = 0, 0, 0, 0, 0, 0, 0, 0, 0, 0;
	local mainBGSpeedX, lightBGSpeedX, streetsSpeedX = 0, 0, 0;
	local pushX = 300

	--fg people
	local makeThemRun, reachedEnd = false, false
	local runner = {
		tag = 'running1',
		speed = 10,
		active = false,
		waiting = false,
		spawnMinX = 5000,
		spawnMaxX = 7000,
		offLeftPad = 3000,
		timerTag = 'resetRunningL'
	}
	local runnerR = {
		tag = 'running2',
		speed = 10,
		active = false,
		waiting = false,
		spawnMinX = -1000,
		spawnMaxX = -800,
		offRightPad = 3000,
		timerTag = 'resetRunningR'
	}
--custom functions
	local shakeDuration, shakeTime, shakeStrength, shakeCam  = 0, 0, 0, 'camGame'; -- custom shake
	local blurAlpha, blurActive = 1, false 

-- mashing
	local mashActive, mashDone  = false, false
	local mashNeed = 5
	local mashPresses, mashTimeMax, mashTimeLeft = 0, 3, 0
	local barW, barH, barGap, uiX = 25, 300, 10, 860

	local doFog = false

--removing
local spritesToRemoveIntro = {'introBG', 'glass', 'bus', 'guy', 'girl', 'seats', 'sedan'}

-- tooltips
local tooltipPadding = 8
local tooltipWidth = 420
local tooltipY = 55
local tooltipX = 35

local killNotesAtTime = 37339 -- milliseconds
local notesKilled = false
local muteVocalsNow = false

function onStartCountdown()

	if isStoryMode then
		if not allowCountdown and songName == 'slippin' then
			if doDialogue and not seenCutscene then
				setProperty('inCutscene', true);
				startDialogue('slippinShit', 'dialogueMusic/slippinDia')  
				doDialogue = false
				return Function_Stop
			end
			return Function_Continue
		end
	end

end

function onCreatePost() 
	if doIntroShit then
		introCutscene()
	else
	
		doZoom = true
		mainStage = true
		introStage = false
		makeThemRun = true
		scrollDirection = -1
		scrollEndNum = 0.15

		doFog = true
		if not lowQuality then
	
			firstPhase = false
			secondPhase = true
			followchars = true
			
			if not firstPhase then
				triggerEvent('Change Character', 0, 'bf-car-2'); -- bf
				triggerEvent('Change Character', 2, 'nova-car-2');

				doTweenX('henchCarMove1', 'carHench', 1820, 0.2, 'backOut')
				doTweenX('henchCarMove2', 'carHench2', -1320, 0.2, 'backOut')
			end
		end

		
	end
	
	precacheImage('noteSkins/Bullet_Note')
	precacheImage(stage..'peeps/bgPeeps/NPC1')
	precacheImage(stage..'peeps/bgPeeps/NPC2')
	precacheImage(stage..'peeps/bgPeeps/NPC3')
	precacheImage(stage..'peeps/bgPeeps/NPC4')

	precacheImage(stage..'NUT')
	precacheImage(stage..'TREE')
	precacheImage(stage..'MISC')
	precacheImage(stage..'peeps/bgPeeps/RUNNING')
	addCharacterToList('bf-car-2', 'bf')
	addCharacterToList('nova-car-2', 'gf')
end

function introCutscene()

	firstPhase = true
	forceCam = true
	followchars = false
	camX = 800
	camY = 660

	--setProperty('camHUD.alpha', 0)

	setProperty('street.alpha', 0)
	setProperty('mainBG.alpha', 0)
	setProperty('light.alpha', 0)
	setProperty('carHench.alpha', 0)
	setProperty('carHench2.alpha', 0)

	setProperty('dad.alpha', 0)

	if not lowQuality then
		setProperty('npc1.alpha', 0)
		setProperty('npc2.alpha', 0)
		setProperty('npc3.alpha', 0)
		setProperty('npc4.alpha', 0)
	end

	setProperty('boyfriend.alpha', 1)
	setProperty('gf.alpha', 1)
	setProperty('car.alpha', 1)
	setProperty('car.x', -2000)
	setProperty('car.y', 670 + 50)
end

function onSongStart()
	if doIntroShit then
		if introStage then
			letterBox(1,1,0)

			playSound(sounds.. 'OMG', 0.8, 'introSFX')

			addAnimationByPrefix('girl', 'intro', 'GIRL', 24, false)
			playAnim('girl', 'intro', true)

			addAnimationByPrefix('guy', 'intro', 'DUDE', 24, false)
			playAnim('guy', 'intro', true)

			runTimer('sheScream', 10.8)
			runTimer('showMainStgae', 12.5)
			runTimer('showNotes', 10.5)
			runTimer('speedUp', 13.5)
			doTweenX('introBox', 'wipeBox', '-2600', 5, 'quadInOut')
			runTimer('theyZoom', 7)

			showTooltip("For this song, you'll be playing as both Angelo and Boyfriend on the same side. Be ready to mash when prompted.", 7)
		
			runTimer('startSpeed', 1)
			runTimer('startSlow', 5)
			scrollDirection = -1
			scrollEndNum = 0
			
		end
	end
end

function onCreate()

	setPropertyFromClass('substates.GameOverSubstate', 'characterName', 'death-bf'); --Character json file for the death 
	setPropertyFromClass('substates.GameOverSubstate', 'deathSoundName', 'DEATH/bfDeath');
	setPropertyFromClass('substates.GameOverSubstate', 'endSoundName', 'DEATH/slipConfirm');
	setPropertyFromClass('substates.GameOverSubstate', 'loopSoundName', 'DEATH/slipDeath');

	camX = 'camFollow.x';	
	camY = 'camFollow.y';

-- ========================================== INTRO ASSETS ==========================================
	if doIntroShit then
		if introStage then
			makeLuaSprite('introBG', intro..'BG', 100, 300);
			setScrollFactor('introBG', 0.3, 1);
			scaleObject('introBG', '1.3','1');
			addLuaSprite('introBG', false);

			if not lowQuality then 
				makeLuaSprite('sedan', 'stages/week2/NEWYORK/SEDAN', 800, 650);
				setScrollFactor('sedan', 0.3, 1);
				addLuaSprite('sedan', false);
				scaleObject('sedan', '1.1','1.1');
			end

			makeLuaSprite('glass', '', 200, 240);
			setScrollFactor('glass', 0.9, 1);
			addLuaSprite('glass', true);
			scaleObject('glass', '1.1','1.1');
			makeGraphic('glass', screenWidth, screenHeight * 0.8, '457c8d')
			setProperty('glass.alpha', 0.5)
			scaleObject('glass', '1.3','1');
			setBlendMode('glass', 'SCREEN')
			
			makeLuaSprite('bus', intro..'BUS', 170, 200);
			setScrollFactor('bus', 0.9, 1);
			scaleObject('bus', '1.3','1.2');
			addLuaSprite('bus', true);

			makeAnimatedLuaSprite('guy', intro..'peeps/GUY', 200, 400);
			setScrollFactor('guy', 0.9, 1);
			addLuaSprite('guy', true);
			scaleObject('guy', '1.1','1.1');

			makeAnimatedLuaSprite('girl', intro..'peeps/GIRL', 700, 400);
			setScrollFactor('girl', 0.9, 1);
			addLuaSprite('girl', true);
			scaleObject('girl', '1.1','1.1');

			makeLuaSprite('seats', intro..'SEAT', 1900, 200);
			setScrollFactor('seats', 1, 1);
			scaleObject('seats', '1.1','1.1');
			addLuaSprite('seats', true);

			setProperty('introBG.x', 90)
			setProperty('glass.x', 60)
			setProperty('bus.x', 30)
			setProperty('guy.x', 200 + pushX)
			setProperty('girl.x', 750 + pushX)
			setProperty('seats.x', 1900 + pushX)

			setObjectOrder('car', 10)
			setObjectOrder('glass', 12)
			setObjectOrder('bus', 13)
			setObjectOrder('guy', 14)
			setObjectOrder('girl', 15)
			setObjectOrder('seats', 16)
		
		end
	end


-- ========================================== MAIN STAGE ASSETS ==========================================

	scaleBG = '1.1'
	makeLuaSprite('street', stage..'SIDEWALK', 100, 650);
	setScrollFactor('street', 0.6, 0.8);

	makeLuaSprite('mainBG', stage..'MAINSTAGE', 100, -100);
	setScrollFactor('mainBG', 0.6, 0.8);

	makeLuaSprite('light', stage..'MAINSTAGE-LIGHTS', 1000, -90);
	setScrollFactor('light', 0.6, 0.8);
	setBlendMode('light', 'SCREEN')

	--NPCS
	if not lowQuality then
		makeAnimatedLuaSprite('npc1', stage..'peeps/bgPeeps/NPC1', 2000, 580) --wifi seller
		addAnimationByPrefix('npc1', 'intro', 'NPC_1', 24, true)
		
		makeAnimatedLuaSprite('npc2', stage..'peeps/bgPeeps/NPC2', 3000, 600) --nana
		addAnimationByPrefix('npc2', 'intro', 'NPC_20', 24, true)
		addAnimationByPrefix('npc2', 'shock', 'NPC_2-SHOCKED', 24, false)

		makeAnimatedLuaSprite('npc3', stage..'peeps/bgPeeps/NPC3', 3400, 620) --girl duo
		addAnimationByPrefix('npc3', 'intro', 'NPC_30', 24, true)
		addAnimationByPrefix('npc3', 'shock', 'NPC_3-SHOCKED', 24, false)
		addAnimationByPrefix('npc3', 'bop', 'NPC_3-BOP', 24, true)

		makeAnimatedLuaSprite('npc4', stage..'peeps/bgPeeps/NPC4', 3800, 570) --hood
		addAnimationByPrefix('npc4', 'intro', 'NPC_40', 24, true)
		addAnimationByPrefix('npc4', 'shock', 'NPC4-SHOCKED', 24, false)
		addAnimationByPrefix('npc4', 'bop', 'NPC_4-BOP', 24, true)

		setScrollFactor('npc1', 0.6, 0.8)
		setScrollFactor('npc2', 0.6, 0.8)
		setScrollFactor('npc3', 0.6, 0.8)
		setScrollFactor('npc4', 0.6, 0.8)
	end

	-- CARS
	makeAnimatedLuaSprite('car', stage..'CAR', 400, 670 + 50); -- main car
	addAnimationByPrefix('car', 'run', 'CAR_BASEMODEL', 18, true)
	addAnimationByPrefix('car', 'crash', 'CAR-CRASH', 24, false)
	objectPlayAnimation('car', 'run', true)
	setScrollFactor('car', 0.9, 0.9);
	--setObjectOrder('car', 10)
	makeAnimatedLuaSprite('carHench', stage..'CAR-HENCH', 1820 + 500, 470 + 120); -- main hench car
	addAnimationByPrefix('carHench', 'run', 'HENCHCAR', 24, false)
	setScrollFactor('carHench', 0.9, 0.9);
	setProperty('carHench.flipX', false)
	makeAnimatedLuaSprite('carHench2', stage..'CAR-HENCH', -1120 - 500, 470 + 120); -- behind car
	addAnimationByPrefix('carHench2', 'run', 'HENCHCAR', 24, false)
	setScrollFactor('carHench2', 0.9, 0.9);
	setProperty('carHench2.flipX', true)

	makeAnimatedLuaSprite('mommy', stage..'peeps/MM', 0, 0);
	addAnimationByPrefix('mommy', 'idle', 'MM-IDLE', 24, true)
	addAnimationByPrefix('mommy', 'shot', 'SHOT-MM', 24, false)
	addAnimationByPrefix('mommy', 'ending', 'END-MM', 24, false)
	setScrollFactor('mommy', 0.9, 0.9);
	setObjectOrder('mommy', 8)
	playAnim('mommy', 'idle',false, false, 1)

	makeAnimatedLuaSprite('shotImpact', stage..'IMPACT', getProperty('car.x') + 950, getProperty('car.y') - 30); -- main hench car
	addAnimationByPrefix('shotImpact', 'shot1', 'impact-1', 24, false)
	addAnimationByPrefix('shotImpact', 'shot2', 'impact-2', 24, false)
	setScrollFactor('shotImpact', 0.9, 0.9);

	scaleObject('light', scaleBG, 1.2);
	scaleObject('mainBG', scaleBG, 1.2);
	scaleObject('street', scaleBG, 1.2)

	--adding them
	addLuaSprite('street', false);
	addLuaSprite('mainBG', false);
	addLuaSprite('light', false);

	if not lowQuality then
		addLuaSprite('npc1', false);
		addLuaSprite('npc2', false);
		addLuaSprite('npc3', false);
		addLuaSprite('npc4', false);
	end

	addLuaSprite('carHench2', false);
	addLuaSprite('carHench', false);
	addLuaSprite('mommy', true);
	addLuaSprite('car', false);
	addLuaSprite('shotImpact', true);

-- ========================================== FG ASSETS ==========================================
	if not lowQuality then
		scaleFG = '1.5'
		makeLuaSprite('nut', stage..'NUT', 5000, 880);
		setScrollFactor('nut', 1.3, 1.6);
		addLuaSprite('nut', true);

		makeLuaSprite('misc', stage..'MISC', 7200, 1000);
		setScrollFactor('misc', 1.3, 1.6);
		addLuaSprite('misc', true);

		makeLuaSprite('tree', stage..'TREE', 9400, 600);
		setScrollFactor('tree', 1.3, 1.6);
		addLuaSprite('tree', true);

		makeLuaSprite('tree2', stage..'TREE', 11000, 600);
		setScrollFactor('tree2', 1.3, 1.6);
		addLuaSprite('tree2', true);

		makeAnimatedLuaSprite('running1', stage..'peeps/bgPeeps/RUNNING', 5000, 680); -- running guy
		addAnimationByPrefix('running1', 'scared', 'runningNPC_1', 32, true)
		objectPlayAnimation('running1', 'scared', true)
		setScrollFactor('running1', 1.4, 1.7);
		addLuaSprite('running1', true);

		makeAnimatedLuaSprite('running2', stage..'peeps/bgPeeps/RUNNING', -1500, 790)
		addAnimationByPrefix('running2', 'scared', 'runningNPC_1', 32, true)
		objectPlayAnimation('running2', 'scared', true)
		setScrollFactor('running2', 1.4, 1.7)
		setProperty('running2.flipX', true) -- flips him
		addLuaSprite('running2', true)

		scaleObject('nut', scaleFG, scaleFG);
		scaleObject('tree', scaleFG, scaleFG);
		scaleObject('tree2', scaleFG, scaleFG);
		scaleObject('misc', scaleFG, scaleFG);
		scaleObject('running1', '1.3', '1.3');
	end

-- ========================================== UI ==========================================
	if enableLights then
		makeLuaSprite('light2', hud..'4-hudShit/LIGHTTEST', -700, -200);
		setScrollFactor('light2', 0, 0);
		addLuaSprite('light2', true);
		scaleObject('light2', '1.7','1.1');
		setBlendMode('light2', 'SCREEN')
		setProperty('light2.color', ambientLight)
		setProperty('light2.alpha', 0.85)
	end

	makeLuaSprite('clipTop', '', 0, -50);
	makeGraphic('clipTop', screenWidth, 50, '000000')
	makeLuaSprite('clipBottom', '', 0, screenHeight);
	makeGraphic('clipBottom', screenWidth, 50, '000000')
	setObjectCamera('clipBottom', 'other')
	setObjectCamera('clipTop', 'other')

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

	if enableMinigame then
		--MASHING
		scaleUi = '0.8'
		makeLuaSprite('mash1', stage..'ui/mash-1', 0, 0)
		makeLuaSprite('mash2', stage..'ui/mash-2', 0, 0)
		scaleObject('mash1', scaleUi, scaleUi);
		scaleObject('mash2', scaleUi, scaleUi);
		setObjectCamera('mash1', 'camFilm')
		setObjectCamera('mash2', 'camFilm')

		addLuaSprite('mash2', true); -- open
		addLuaSprite('mash1', true); -- closed

		setProperty('mash1.x', -getProperty('mash1.width'))
		setProperty('mash2.x', -getProperty('mash1.width'))
		setProperty('mash1.y', screenHeight - getProperty('mash1.height') - 50)
		setProperty('mash2.y', screenHeight - getProperty('mash1.height') - 50)

		-- timer bar
		makeLuaSprite('mashBarTimeBG', nil)
		makeGraphic('mashBarTimeBG', barW, barH, '000000')
		setProperty('mashBarTimeBG.alpha', 0.55)
		makeLuaSprite('mashBarTimeFill', nil)
		makeGraphic('mashBarTimeFill', barW, barH, '#fc40d0')

		-- progress bar
		makeLuaSprite('mashBarProgBG', nil, 50)
		makeGraphic('mashBarProgBG', barW, barH, '000000')
		setProperty('mashBarProgBG.alpha', 0.55)
		makeLuaSprite('mashBarProgFill', nil, 50)
		makeGraphic('mashBarProgFill', barW, barH, 'FFFFFF')

		addLuaSprite('mashBarTimeBG', true)
		addLuaSprite('mashBarTimeFill', true)
		addLuaSprite('mashBarProgBG', true)
		addLuaSprite('mashBarProgFill', true)
		
		setObjectCamera('mashBarProgBG', 'camFilm')
		setObjectCamera('mashBarProgFill', 'camFilm')
		setObjectCamera('mashBarTimeFill', 'camFilm')
		setObjectCamera('mashBarTimeBG', 'camFilm')

		setProperty('mash1.alpha', 0)
		setProperty('mash2.alpha', 0)
		setProperty('mashBarProgBG.alpha', 0)
		setProperty('mashBarProgFill.alpha', 0)
		setProperty('mashBarTimeBG.alpha', 0)
		setProperty('mashBarTimeFill.alpha', 0)

		makeLuaSprite('glassBreaks', stage..'ui/glassBreak', 0, 0);
		setObjectCamera('glassBreaks', 'camHUD')
		setBlendMode('glassBreaks', 'SCREEN')
		setProperty('glassBreaks.scale.x', 1.8)
		setProperty('glassBreaks.scale.y', 1.8  )
		addLuaSprite('glassBreaks', true)
		setProperty('glassBreaks.alpha', 0)

		-- space button
		makeLuaSprite('qteSpaceIcon', hud..'4-hudShit/PUNCHICON', 0, 0);
		setObjectCamera('qteSpaceIcon', 'other')
		addLuaSprite('qteSpaceIcon', true)
		setProperty('qteSpaceIcon.alpha', 0)

		setProperty('qteSpaceIcon.x', (screenWidth * 0.5) - (getProperty('qteSpaceIcon.width') * 0.5))
		setProperty('qteSpaceIcon.y', screenHeight - 180)
	end
-- ========================================== COVER UP ==========================================

	if doIntroShit then
		makeLuaSprite('wipeBox', nil, -150, -150)
		makeGraphic('wipeBox', 2500, 900, '000000')
		setObjectCamera('wipeBox', 'game')
		setScrollFactor('wipeBox', 0, 0)
		addLuaSprite('wipeBox', true)

	end

	addLuaSprite('clipBottom', true);
	addLuaSprite('clipTop', true);

end

function onUpdate(elapsed)

	if scrollDirection == 1 then
		scrollEase = math.min(scrollEase + elapsed * scroolEndNormal, 1) -- ease in
	elseif scrollDirection == -1 then
		scrollEase = math.max(scrollEase - elapsed * 0.5, scrollEndNum) -- ease out
	end
-- ========================================== INTRO ==========================================
	if doIntroShit then
		if introStage then

			local girlX, guyX, seatX, glassX, busX, bgX, carX = getProperty('girl.x'),  getProperty('guy.x'),  getProperty('seats.x'), getProperty('glass.x'), getProperty('bus.x'), getProperty('introBG.x'), getProperty('sedan.x')
		
			smoothSpeedX = scrollEase * 0.8 
			bgSpeedX = scrollEase * 0.6 
			bgCarSpeedX = scrollEase * 0.8 --car
		
			setProperty('seats.x', seatX - (smoothSpeedX * baseFPS * elapsed))
			setProperty('girl.x', girlX - (smoothSpeedX * baseFPS * elapsed))
			setProperty('guy.x', guyX - (smoothSpeedX * baseFPS * elapsed))
			setProperty('bus.x', busX - (smoothSpeedX * baseFPS * elapsed))
			setProperty('glass.x', glassX - (smoothSpeedX * baseFPS * elapsed))
			setProperty('introBG.x', bgX - (bgSpeedX * baseFPS * elapsed))
			setProperty('sedan.x', carX - (bgCarSpeedX * baseFPS * elapsed))
			
		end
	end
-- ========================================== MAIN ==========================================
	if mainStage then
		
		-- moving assets
		local mainBGX, lightsBGX, streetsX = getProperty('mainBG.x'), getProperty('light.x'),  getProperty('street.x')
		local peepsX1, peepsX2, peepsX3, peepsX4 = getProperty('npc1.x'), getProperty('npc2.x'), getProperty('npc3.x'), getProperty('npc4.x')
		local nutX, treeX, tree2X, miscX, runningX = getProperty('nut.x'), getProperty('tree.x'), getProperty('tree2.x'), getProperty('misc.x'), getProperty('running1.x')

		mainBGSpeedX = scrollEase * 3
		lightBGSpeedX = scrollEase * 3
		streetsSpeedX = scrollEase * 3 
		peepsSpeedX = scrollEase * 3
		fgSpeedX = scrollEase * 8

		setProperty('mainBG.x', mainBGX - (mainBGSpeedX * baseFPS * elapsed))
		setProperty('light.x', lightsBGX - (lightBGSpeedX * baseFPS * elapsed))
		setProperty('street.x', streetsX - (streetsSpeedX * baseFPS * elapsed))
		if not lowQuality then
			setProperty('npc1.x', peepsX1 - (peepsSpeedX * baseFPS * elapsed))
			setProperty('npc2.x', peepsX2 - (peepsSpeedX * baseFPS * elapsed))
			setProperty('npc3.x', peepsX3 - (peepsSpeedX * baseFPS * elapsed))
			setProperty('npc4.x', peepsX4 - (peepsSpeedX * baseFPS * elapsed))
		end
		setProperty('nut.x', nutX - (fgSpeedX * baseFPS * elapsed))
		setProperty('tree.x', treeX - (fgSpeedX * baseFPS * elapsed))
		setProperty('tree2.x', tree2X - (fgSpeedX * baseFPS * elapsed))
		setProperty('misc.x', miscX - (fgSpeedX * baseFPS * elapsed))

		if not lowQuality then
			if makeThemRun then
				if not runner.waiting then
					if not runner.active then
						spawnRunnerLeft()
					else
						local x = getProperty(runner.tag..'.x')
						setProperty(runner.tag..'.x', x - (runner.speed * baseFPS * elapsed))

						if x < (0 - runner.offLeftPad) then
							runner.active = false
							runner.waiting = true
							runTimer(runner.timerTag, getRandomFloat(3, 7))
						end
					end
				end
			end

			if makeThemRun then
				if not runnerR.waiting then
					if not runnerR.active then
						spawnRunnerRight()
					else
						local x2 = getProperty(runnerR.tag..'.x')
						setProperty(runnerR.tag..'.x', x2 + (runnerR.speed * baseFPS * elapsed))

						if x2 > (screenWidth + runnerR.offRightPad) then
							runnerR.active = false
							runnerR.waiting = true
							runTimer(runnerR.timerTag, getRandomFloat(3, 7))
						end
					end
				end
			end
		end
	end


-- ========================================== CAMERA ==========================================
	if doZoom then
		if mustHitSection == false  then
			setProperty('defaultCamZoom', zoomNumDad) -- henchman (1.35)
			doTweenZoom('toHench', 'camGame', zoomNumDad, 0.8, 'backOut')
		else
			if firstPhase then
				if lastSinger == 'bf' then
					setProperty('defaultCamZoom', 1.1)
					doTweenZoom('toBF1', 'camGame', '1.1', 0.8, 'quadIn')
					cancelTween('toNova1')
				elseif lastSinger == 'gf' then
					setProperty('defaultCamZoom', 1.2)
					doTweenZoom('toNova1', 'camGame', '1.2', 0.8, 'circOut')
					cancelTween('toBF1')
				end
			
			else
					
				if lastSinger == 'bf' then
					setProperty('defaultCamZoom', zoomNumBF)
					doTweenZoom('toBF', 'camGame', zoomNumBF, 0.8, 'quadIn')
					cancelTween('toNova')
				elseif lastSinger == 'gf' then
					setProperty('defaultCamZoom', zoomNumNov)
					doTweenZoom('toNova', 'camGame', zoomNumNov, 0.8, 'circOut')
					cancelTween('toBF')
				end
				
			end
		end
	end

	if failedBru then
		setProperty('defaultCamZoom', 1.1) -- henchman (1.35)
		doTweenZoom('him', 'camGame', 1.1, 0.8, 'backOut')
	end
-- ========================================== BOYFRIEND NOVA HENCHMAN =========================
	if not inGameOver then
		if firstPhase then
			setProperty('boyfriend.x', getProperty('car.x') + getProperty('boyfriend.width') + 230)
			setProperty('boyfriend.y', getProperty('car.y') - 200)

			setProperty('gf.x', getProperty('car.x') + getProperty('gf.width') + 450) -- nova
			setProperty('gf.y', getProperty('car.y') - 200)

			xx2 = 1150
			yy2 = 800

			xx3 = 1250
			yy3 = 810
		
		else
			setProperty('boyfriend.x', getProperty('car.x') + getProperty('boyfriend.width') + 630) --standing up
			setProperty('boyfriend.y', getProperty('car.y') - 290)

			setProperty('gf.x', getProperty('car.x') + getProperty('gf.width') + 50) -- nova
			setProperty('gf.y', getProperty('car.y') - 340)

			if secondPhase then
				xx = 2500
				yy = 500

				xx2 = 2200
				yy2 = 590

				xx3 = 2000
				yy3 = 590
			else
				xx2 = 1350
				yy2 = 710

				xx3 = 1000
				yy3 = 670
			end
		end
	end

	setProperty('boyfriend.scrollFactor.x', 0.9);
	setProperty('boyfriend.scrollFactor.y', 0.9);
	setProperty('gf.scrollFactor.x', 0.9);
	setProperty('gf.scrollFactor.y', 0.9);
	setProperty('dad.scrollFactor.x', 0.9);
	setProperty('dad.scrollFactor.y', 0.9);

	setProperty('dad.x', getProperty('carHench.x') + getProperty('dad.width') + 180)
	setProperty('dad.y', getProperty('carHench.y') - 378)
	setProperty('mommy.x', getProperty('carHench.x') + getProperty('mommy.width') + 350)
	setProperty('mommy.y', getProperty('carHench.y') - 73)

-- ========================================== FUNCTIONS ==========================================
	if doFog then
		if not lowQuality then -- for fog
			local screenW = getPropertyFromClass('flixel.FlxG', 'width')

			for i = 1, #fogPool do
				local spr = fogPool[i]

				local vx = getProperty(spr .. '.velocity.x')
				setProperty(spr .. '.x', getProperty(spr .. '.x') + vx * elapsed)

				local w = getProperty(spr .. '.width') * getProperty(spr .. '.scale.x')
				if getProperty(spr .. '.x') < -w - 300 then
				-- swap fog graphic for variation
				loadGraphic(spr, fogPaths[randi(1, #fogPaths)])
				resetFog(i, false)
				end
			end
		end
	end

	-- custom functions
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
			
			elseif lastSinger == 'bf' then

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

			elseif lastSinger == 'gf' then
				if getProperty('gf.animation.curAnim.name') == 'singLEFT' then
				    triggerEvent('Camera Follow Pos',xx3-ofs3,yy3)
				end
				if getProperty('gf.animation.curAnim.name') == 'singRIGHT' then
				    triggerEvent('Camera Follow Pos',xx3+ofs3,yy3)
				end
				if getProperty('gf.animation.curAnim.name') == 'singUP' then
				    triggerEvent('Camera Follow Pos',xx3,yy3-ofs3)
				end
				if getProperty('gf.animation.curAnim.name') == 'singDOWN' then
				    triggerEvent('Camera Follow Pos',xx3,yy3+ofs3)
				end
				if getProperty('gf.animation.curAnim.name') == 'idle' then
				    triggerEvent('Camera Follow Pos',xx3,yy3)
				end
				--
		
			end
	else
		triggerEvent('Camera Follow Pos','','') -- self explanatory
	end

-- ========================================== BUTTONS ==========================================
	if enableMinigame then
		updateMash(elapsed)
	end

	addOffset('car','crash', 0, 365)
	addOffset('mommy','idle', 0, 0)
	addOffset('mommy','shot', 0, -15)
	addOffset('mommy','ending', 0, 0)
	setProperty('gf.flipX', false)

end



function revealMainStage()
	setProperty('street.alpha', 1)
	setProperty('mainBG.alpha', 1)
	setProperty('light.alpha', 1)
	setProperty('bfCar.alpha', 1)
	setProperty('novaCar.alpha', 1)
	setProperty('car.alpha', 1)
	setProperty('boyfriend.alpha', 1)

	if not lowQuality then
		setProperty('npc1.alpha', 1)
		setProperty('npc2.alpha', 1)
		setProperty('npc3.alpha', 1)
		setProperty('npc4.alpha', 1)

		objectPlayAnimation('npc1', 'intro', false)
		objectPlayAnimation('npc2', 'intro', false)
		objectPlayAnimation('npc3', 'intro', false)
		objectPlayAnimation('npc4', 'intro', false)
	end

end

stepHitFuncs = { 


	[103] = function()
		if doIntroShit then
			if introStage then
				startSmoothShake(8,2)
				runTimer('resetZoom', 0.2)
				doTweenZoom('oof', 'camGame', '0.9', 0.2, 'circOut')
			end
		end
	end,

	[120] = function()
		if doIntroShit then
			if introStage then
				setProperty('car.x', 400)
				setProperty('car.y', 670 + 50)

				setProperty('gf.alpha',1)
			end
		end
	end,


	[150] = function() --113
		
		scrollDirection = -1
		scrollEndNum = 0.25
	
	end,

	[385] = function() -- crash prep
		
		scrollEndNum = 0
		fogSpeedMin = 12
		fogSpeedMax = 45
		
	end,

	[390] = function()
		carTest()
	end,

	[461] = function()
		if not enableMiniGame then
			letterBoxOut(0.5,0.5,1)
		end
	end,

	[472] = function() -- they running
		if enableMinigame then
			if not failedBru then
				if not lowQuality then
					setRunnerEnabled(true)
				end
				objectPlayAnimation('npc3', 'bop', true)
				objectPlayAnimation('npc4', 'bop', true)
			end
		else
			setRunnerEnabled(true)
			objectPlayAnimation('npc3', 'bop', true)
			objectPlayAnimation('npc4', 'bop', true)
		end

	end,

	[727] = function() -- where shit begins
		secondPhase = true
		zoomNumDad = 0.65
		zoomNumBF = 0.65
		zoomNumNov = 0.65
	end,

	[1383] = function() -- where shit begins
		secondPhase = false
		zoomNumDad = 0.85
		zoomNumBF = 1.1
		zoomNumNov = 1
	end,

	[1624] = function() -- henchman prep for yeah
		
		forceCam = true
		followchars = false
		doZoom = false

		setProperty('defaultCamZoom', 1.1) 
		doTweenZoom('impactHench', 'camGame', '1.1', 3, 'quadOut')
		cancelTween('toHench')
		cancelTween('toNova')
		cancelTween('toBF')

		camX = 2950
		camY = 500
	
	end,

	[1638] = function() -- henchman prep for yeah
		
		triggerEvent('Play Animation', 'YEAH', 'Dad') 
		
	end,

	[1651] = function() -- henchman go crazy in the studio
		forceCam = false
		followchars = true
		doZoom = true
		zoomNumDad = 1
		xx = 3050
		yy = 500
		ofs = 45
		setProperty('cameraSpeed', 1.6)
	
	end,

	[1780] = function() -- where shit begins
		zoomNumBF = 1.3
		zoomNumNov = 1.2
	
	end,

	[1909] = function() -- where shit begins
		followchars = false
		forceCam = true
		doZoom = false
		cancelTween('toHench')
		cancelTween('toNova')
		cancelTween('toBF')

		setProperty('cameraSpeed', 0.1)
		playAnim('mommy', 'ending',false, false, 1)

		setProperty('defaultCamZoom',0.9)
		doTweenZoom('daEnding', 'camGame', '0.9', 4, 'quadOut')

		camX = 3000
		camY = 500
	end,

	[2030] = function() -- where shit begins
		endingShit()
		secondPhase = true
	end,
}

function onStepHit()
	if stepHitFuncs[curStep] then
		stepHitFuncs[curStep]()
	end

end

function onTimerCompleted(tag, loops, loopsLeft)
------------------------------------------------ INTRO
	if tag == 'sheScream' then
		cameraShake('camGame', 0.007, 1)
		setProperty('defaultCamZoom',0.95)
		doTweenZoom('yikes', 'camGame', '0.95', 0.5, 'backOut')
	end

	if tag == 'speedUp' then
		scrollDirection = -1
	end

	if tag == 'startSpeed' then
		scrollDirection = 1
		scroolEndNormal = 2
	end

	if tag == 'startSlow' then
		scrollDirection = -1
		scrollEndNum = 0.25
	end

	if tag == 'startSlowMain' then
		scrollDirection = -1
		scrollEndNum = 0.33
	end

	if tag == 'theyZoom' then
		doTweenX('theygone', 'car', '3000', 1, 'quadOut')
	end
------------------------------------------------ MAIN
	if tag == 'showMainStgae' then

		removeIntroSprite()

		setObjectOrder('car', 15)
		allowDeath = true
		mainStage = true
		followchars = true
		forceCam = false
		doZoom = true
		doFog = true

		if not lowQuality and doFog then
			for i = 1, fogCount do
				local path = fogPaths[randi(1, #fogPaths)]
				local name = 'fog_' .. i
				fogPool[i] = name

				makeLuaSprite(name, path, 0, 0)
				
				setBlendMode(name, 'ADD')

				addLuaSprite(name, true)
				setObjectOrder(name, 20)

				resetFog(i, false)
			
			end
		end

		revealMainStage()
		
	end

	if tag == 'showNotes' then
		letterBoxOut(1,1,1)
		setProperty('wipeBox.x', screenWidth + 500)
		doTweenX('finalSwipe', 'wipeBox', '-2600', 4, 'quadInOut')
				
	end
	
	if tag == 'hideBoys' then
		setProperty('boyfriend.alpha', 0)
		setProperty('gf.alpha', 0)
	end

	if tag == 'henchShow' then
		setProperty('dad.alpha', 1)
		setProperty('carHench.alpha', 1)
		letterBoxOut(1,1,1)

	end

	if tag == 'revealBoys' then
		setProperty('boyfriend.alpha', 1)
		setProperty('gf.alpha', 1)
		doTweenAngle('camCrash', 'camHUD', 0, 0.5, 'backOut')
	end

	if tag == 'moveOutUI' then
		doTweenX('mash_out_1', 'mash1', -getProperty('mash1.width') - 50, 0.35, 'quadIn')
		doTweenX('mash_out_2', 'mash2', -getProperty('mash2.width') - 50, 0.35, 'quadIn')
		doTweenX('mash_out_barA', 'mashBarTimeBG', -300, 0.35, 'quadIn')
		doTweenX('mash_out_fillA', 'mashBarTimeFill', -300, 0.35, 'quadIn')
		doTweenX('mash_out_barB', 'mashBarProgBG', -300, 0.35, 'quadIn')
		doTweenX('mash_out_fillB', 'mashBarProgFill', -300, 0.35, 'quadIn')
	end

	if tag == 'resetZoom' then
		setProperty('defaultCamZoom',1)
		doTweenZoom('backIn', 'camGame', '1', 1, 'quadOut')
	end

	if tag == 'comeInMash' then
    	doTweenX('moveInMash1', 'mash1', 0, 1, 'smootherStepOut')
		doTweenX('moveInMash2', 'mash2', 0, 1, 'smootherStepOut')
  	   
	 	runTimer('startMashNow', 0.5, 1)
	end

	if tag == 'startMashNow' then
		startMash()
	end

	if tag == runner.timerTag then
		if makeThemRun then spawnRunnerLeft() else runner.waiting = false end
	end

	-- right runner
	if tag == runnerR.timerTag then
		if makeThemRun then spawnRunnerRight() else runnerR.waiting = false end
	end
------------------------------------------------ ENDING
	if tag == 'shakeBlur' then
		triggerBlur()
		startSmoothShake(5, 1)


   	end
	--tooltips
	if tag == 'tooltipHide' then
		doTweenAlpha('tooltipBG_out',  'tooltipBG',  0.0, 0.25, 'quadIn')
		doTweenAlpha('tooltipText_out','tooltipText',0.0, 0.25, 'quadIn')
   end

   	if tag == 'switchPeeps' then
		firstPhase = false
		triggerEvent('Change Character', 0, 'bf-car-2'); -- bf
		triggerEvent('Change Character', 2, 'nova-car-2'); -- nova
	end

	-- death
   	if tag == 'doDeath' then
		runHaxeCode([[
            game.health = 0;
            game.doDeathCheck();
        ]])
	end

end

function onTweenCompleted(tag, loops, loopsLeft)
	

	if tag == 'oof' then
		runTimer('startSpeed', 1)
		runTimer('startSlowMain', 2.5)
	end

	if tag == 'finalSwipe' then
		setProperty('wipeBox.alpha', 0)
		setProperty('wipeBox.visible', false)
	end

	if tag == 'theygone' then
		setProperty('boyfriend.alpha', 0)
		setProperty('gf.alpha', 0)
		setProperty('car.alpha', 0)
	end
end


function resetFog(i, scatter)
	local spr = fogPool[i]
	local screenW = getPropertyFromClass('flixel.FlxG', 'width')

	local x

	x = screenW + randi(450, 600)

	setProperty(spr .. '.x', x)
	setProperty(spr .. '.y', randf(fogYMin, fogYMax))

	local sc = randf(0.8, 1.35)
	scaleObject(spr, sc, sc)

	setProperty(spr .. '.alpha', randf(0.12, 0.25))
	setProperty(spr .. '.velocity.x', -randf(fogSpeedMin, fogSpeedMax))
end

-- ========================================== MASHING ==========================================

	function setBarFillClip(sprName, pct)
		if pct < 0 then pct = 0 end
		if pct > 1 then pct = 1 end

		runHaxeCode([[
			var n = "]]..sprName..[[";
			var s = game.getLuaObject(n);
			if (s == null && game.modchartSprites.exists(n)) s = game.modchartSprites.get(n);
			if (s == null) {
			FlxG.log.warn("clipRect missing sprite: " + n);
			return;
			}

			var fh = s.frameHeight;
			var fw = s.frameWidth;
			var vis = Std.int(fh * ]]..tostring(pct)..[[);

			if (vis <= 0) {
			s.visible = false;
			s.clipRect = null;
			return;
			}

			s.visible = true;
			s.clipRect = new flixel.math.FlxRect(0, fh - vis, fw, vis);
		]])
	end

	function startMash()

		mashActive = true
		mashDone = false

		mashPresses = 0
		mashTimeLeft = mashTimeMax

		letterBox(0.5,0.5,0)
		setProperty('mash1.alpha', 1)
		setProperty('mash2.alpha', 0)

		local barsX = getProperty('mash1.x') + getProperty('mash1.width') + 130
		local barsY = getProperty('mash1.y') + (getProperty('mash1.height')) - (barH * 1.1)

		-- time bar
		setProperty('mashBarTimeBG.x', barsX)
		setProperty('mashBarTimeBG.y', barsY)
		setProperty('mashBarTimeFill.x', barsX)
		setProperty('mashBarTimeFill.y', barsY)

		-- progress bar (next to it)
		setProperty('mashBarProgBG.x', barsX + barW + barGap)
		setProperty('mashBarProgBG.y', barsY)
		setProperty('mashBarProgFill.x', barsX + barW + barGap)
		setProperty('mashBarProgFill.y', barsY)

		setBarFillClip('mashBarTimeFill', 1)
		setBarFillClip('mashBarProgFill', 0)

		doTweenAlpha('fadeIconIn', 'qteSpaceIcon', 1, 0.5, 'quadOut')
		doTweenAlpha('fadeMashTimeBG', 'mashBarTimeBG', 1, 0.5, 'quadOut')
		doTweenAlpha('fadeMashTimeFill', 'mashBarTimeFill', 1, 0.5, 'quadOut')
		doTweenAlpha('fadeMashProgBG', 'mashBarProgBG', 0.55, 0.5, 'quadOut')
		doTweenAlpha('fadeMashProgFill', 'mashBarProgFill', 1, 0.5, 'quadOut')
	end

	function endMash(success)
		if not mashActive then return end
		mashActive = false
		mashDone = true

		mashTimeLeft = 0

		if not success then

			--letterBox(1,1,0)

			forceCam = true
			followchars = false
			doZoom = false
			failedBru = true
			cancelTween('toBF1')
			cancelTween('toBF')
			cancelTween('toNova')
			cancelTween('toNova1')
			cancelTween('toHench')
			
			camX = 3150
			camY = 500

			runHaxeCode([[
				var curTime = Conductor.songPosition;
				var keptEvents = [];

				for (event in game.eventNotes)
				{
					if (!(event.strumTime >= curTime && event.event == "Add Camera Zoom"))
						keptEvents.push(event);
				}

				game.eventNotes = keptEvents;
				FlxTween.tween(FlxG.sound.music, {volume: 0.2}, 1);

			]])

			playSound(deathSound.. 'GOTTEM', 1, 'henchWin')
			triggerEvent('Play Animation', 'DEATH', 'Dad') 

			runTimer('doDeath', 8, 1)

			doTweenX('mash_out_1', 'mash1', -getProperty('mash1.width') - 50, 0.35, 'quadIn')
			doTweenX('mash_out_2', 'mash2', -getProperty('mash2.width') - 50, 0.35, 'quadIn')
			doTweenX('mash_out_barA', 'mashBarTimeBG', -300, 0.35, 'quadIn')
			doTweenX('mash_out_fillA', 'mashBarTimeFill', -300, 0.35, 'quadIn')
			doTweenX('mash_out_barB', 'mashBarProgBG', -300, 0.35, 'quadIn')
			doTweenX('mash_out_fillB', 'mashBarProgFill', -300, 0.35, 'quadIn')
			
		else

			setProperty('mash2.alpha', 1)
			setProperty('mash1.alpha', 0)
			setProperty('qteSpaceIcon.alpha', 0)
			runTimer('moveOutUI', 2, 1)
			letterBoxOut(0.5,0.5,1)
		end
	end

	function updateMash(elapsed)
		if not mashActive then return end

		mashTimeLeft = (mashTimeLeft) - elapsed
		if mashTimeLeft < 0 then mashTimeLeft = 0 end

		-- input
		if getPropertyFromClass('flixel.FlxG', 'keys.justPressed.SPACE') then
			mashPresses = mashPresses + 1
			playSound('tap', 0.6)
		end

		if keyboardPressed('SPACE') then
			setProperty('qteSpaceIcon.scale.x', 0.8)
			setProperty('qteSpaceIcon.scale.y', 0.8)
			setProperty('qteSpaceIcon.color', getColorFromHex('52b0cd'))
			
		else
			setProperty('qteSpaceIcon.scale.x', 1)
			setProperty('qteSpaceIcon.scale.y', 1)
			setProperty('qteSpaceIcon.color', getColorFromHex('FFFFFF'))
		end

		setBarFillClip('mashBarTimeFill', mashTimeLeft / mashTimeMax)
		setBarFillClip('mashBarProgFill', mashPresses / mashNeed)

		-- win/lose
		if mashPresses >= mashNeed then
			endMash(true)
			doTweenAlpha('fadeIconOut', 'qteSpaceIcon', 0, 0.5, 'quadOut')
			return
		end

		if mashTimeLeft <= 0 then
			endMash(false)
			doTweenAlpha('fadeIconOut', 'qteSpaceIcon', 0, 0.5, 'quadOut')
			return
		end

	end

-- ========================================== CUSTOM FUNCTIONS ==========================================
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

-- ========================================== BG FUNCTIONS ==========================================

function carTest()
	triggerBlur()
	startSmoothShake(7, 1)
	cameraShake('camGame', 0.003, 0.15)

	triggerEvent('Play Animation', 'carCrash', 'Boyfriend') 
	triggerEvent('Play Animation', 'carCrash', 'GF') 
	playAnim('car', 'crash',false, false, 1)
	playAnim('carHench', 'run',true, false, 3)

	if not lowQuality then
		objectPlayAnimation('npc2', 'shock', false)
		objectPlayAnimation('npc3', 'shock', false)
		objectPlayAnimation('npc4', 'shock', false)

		local shockSound = getRandomInt(1, 3)
		playSound(sounds..'NPCSHOCK_SHOCK-'..shockSound, 0.8, 'crowd')
	end

	doTweenX('henchCarMove1', 'carHench', 1820, 0.2, 'backOut')
	doTweenX('henchCarMove2', 'carHench2', -1320, 0.2, 'backOut')

	setProperty('dad.alpha', 1)
	setProperty('carHench.alpha', 1)
	setProperty('carHench2.alpha', 1)
	setProperty('glassBreaks.alpha', 0.8)

	runTimer('hideBoys', 0.5)
	runTimer('switchPeeps', 2, 1)
	runTimer('revealBoys', 6)
	runTimer('comeInMash', 2, 1) -- start mashing

	doTweenAngle('camCrash', 'camHUD', 3, 0.5, 'backOut')
end

function endingShit()
	forceCam = true
	followchars = false
	doZoom = false
	cancelTween('toHench')
	cancelTween('toNova')
	cancelTween('toBF')

	setProperty('defaultCamZoom', 1.1) 
	doTweenZoom('impactHench', 'camGame', '1.1', 3, 'quadOut')

	letterBox(1,1,0)

	runTimer('shakeBlur', 0.5)

	xx = 3050
	yy = 500
end

function spawnRunnerLeft()
	local x = getRandomInt(runner.spawnMinX, runner.spawnMaxX)
	setProperty(runner.tag..'.x', x)
	runner.active = true
	runner.waiting = false
end

function spawnRunnerRight()
	local x = getRandomInt(runnerR.spawnMinX, runnerR.spawnMaxX)
	setProperty(runnerR.tag..'.x', x)
	runnerR.active = true
	runnerR.waiting = false
end

function setRunnerEnabled(on)
	makeThemRun = on

	if not on then
		runner.active = false
		runner.waiting = false
	else
		spawnRunnerLeft()
	end
end

function removeIntroSprite()

    for i = 1, #spritesToRemoveIntro do
        setProperty(spritesToRemoveIntro[i]..'.alpha', 0)
    end

end

-- ========================================== MISC FUNCTIONS ==========================================

function onPause()
	pauseSound('introSFX')
	pauseSound('henchWin')
	pauseSound('crowd')
end

function onResume()
	resumeSound('introSFX')
	resumeSound('henchWin')
	resumeSound('crowd')
end

function opponentNoteHit(id, direction, noteType, isSustainNote)
    lastSinger = 'dad'

	if getProperty('health') > 0.2 then
		setProperty('health', getProperty('health')-0.03);
	end
end

function goodNoteHit(id, direction, noteType, isSustainNote)
    if noteType == '2Player_Note' then
        lastSinger = 'gf'
	elseif noteType ~= 'Bullet_Note' then
        lastSinger = 'bf'
    end
end

function randf(a, b) return a + (b-a) * getRandomFloat(0, 1) end
function randi(a, b) return getRandomInt(a, b) end

function clamp(v, a, b)
	if v < a then return a end
	if v > b then return b end
	return v
end
function lerp(a, b, t)
    return a + (b - a) * t
end

function onGameOver()
	onPause()
	setProperty('car.x', 600)
	mainStage = true
	followchars = true
	forceCam = false
	doZoom = true

	return Function_Continue;
end


function onUpdatePost(elapsed)
	if failedBru then
		if not notesKilled and getSongPosition() >= killNotesAtTime then
			notesKilled = true
			muteVocalsNow = true
			removeFutureNotes()
		end

		if muteVocalsNow then
			setProperty('vocals.volume', 0)
		end
	end
end

function removeFutureNotes()
	local songPos = getSongPosition()

	for i = getProperty('unspawnNotes.length') - 1, 0, -1 do
		if getPropertyFromGroup('unspawnNotes', i, 'strumTime') > songPos then
			setPropertyFromGroup('unspawnNotes', i, 'mustPress', false)
			setPropertyFromGroup('unspawnNotes', i, 'ignoreNote', true)
			setPropertyFromGroup('unspawnNotes', i, 'visible', false)
			setPropertyFromGroup('unspawnNotes', i, 'active', false)
			setPropertyFromGroup('unspawnNotes', i, 'tooLate', true)
			removeFromGroup('unspawnNotes', i)
		end
	end

	for i = getProperty('notes.length') - 1, 0, -1 do
		if getPropertyFromGroup('notes', i, 'strumTime') > songPos then
			setPropertyFromGroup('notes', i, 'mustPress', false)
			setPropertyFromGroup('notes', i, 'ignoreNote', true)
			setPropertyFromGroup('notes', i, 'visible', false)
			setPropertyFromGroup('notes', i, 'active', false)
			setPropertyFromGroup('notes', i, 'tooLate', true)
			removeFromGroup('notes', i)
		end
	end
end

function onNextDialogue(lineNum)
	if lineNum == 5 then
		cameraShake('camHUD', 0.003, 0.4)
	end
    if lineNum == 9 then
		playSound(sounds.. 'clip', 0.6) -- play gun clip
      
    end

	if lineNum == 12 then
		cameraShake('camHUD', 0.003, 0.4)
	end

	if lineNum == 16 then
		cameraShake('camHUD', 0.003, 0.4)
		playSound(sounds.. 'GROWL', 1)
	end
end