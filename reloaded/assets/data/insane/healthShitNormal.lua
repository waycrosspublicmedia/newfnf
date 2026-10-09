specialIcons = false

local bfname = getProperty('boyfriend.curCharacter')
local dadname = getProperty('dad.curCharacter')
local regularStage = 'timesquarelol'
local doDamage = true;

function onCreatePost()


	if curStage == regularStage then
	
	
		specialIcons = true;

		if specialIcons == true then 
			loadImages()
		end
	
	end

	
end
function loadImages()

	if curStage == regularStage then

	
		bfname = getProperty('boyfriend.curCharacter')
		dadname = getProperty('dad.curCharacter')

		makeAnimatedLuaSprite('move2', 'misc/3-healthShit/' ..bfname..'-animated', getProperty('iconP1.x'),getProperty('iconP1.y'))
		addAnimationByPrefix('move2', 'idle', 'idle',24,false)
		addAnimationByPrefix('move2', 'win', 'win',24,false)
		addAnimationByPrefix('move2', 'lose', 'lose',24,false)

		makeAnimatedLuaSprite('move', 'misc/3-healthShit/' ..dadname..'-animated', getProperty('iconP2.x'),getProperty('iconP2.y'))
		addAnimationByPrefix('move', 'idle', 'idle',24,false)
		addAnimationByPrefix('move', 'win', 'win',24,false)
		addAnimationByPrefix('move', 'lose', 'lose',24,false)
					
		setObjectCamera('move', 'hud')
		setObjectCamera('move2', 'hud')
					
		objectPlayAnimation('move','idle',true);
		objectPlayAnimation('move2','idle',true);

		addLuaSprite('move', true);
		addLuaSprite('move2', true);
	end

end

function opponentNoteHit()
	if curStep > 768 and curStep < 1024 then
		health = getProperty('health')
		if getProperty('health') > 0.2 then
			setProperty('health', health- 0.010);
		end
	end

	if curStep > 1024 and curStep < 1152 then
		health = getProperty('health')
		if getProperty('health') > 0.2 then
			setProperty('health', health- 0.02);
		end
	end

	if curStep > 1152 then
		health = getProperty('health')
		if getProperty('health') > 0.2 then
			setProperty('health', health- 0.03);
		end
	end
end

function onUpdate(elapsed)

	if specialIcons then 
		if curStep >= 1 then

			health = getProperty('health')

			if getProperty('health') < 1.6 then
				runTimer('LOSE2',0.1,1)
			elseif getProperty('health') >= 1.4 then
				runTimer('WIN2',0.1,1)
			elseif getProperty('health') == 1 then
				objectPlayAnimation('move2','idle',true);
			end
			if getProperty('health') == 1 then
				objectPlayAnimation('move','idle',true);
			elseif getProperty('health') < 0.4 then
				runTimer('WIN1',0.1,1)
			elseif getProperty('health') > 0.5 then
				runTimer('LOSE1',0.1,1)
			end

		end

	
		setProperty('move.flipX', false)
		setProperty('move.visible', true)
		setProperty('move.y', getProperty('iconP2.y') + 14)
		setProperty('move.x', getProperty('iconP2.x'))
		setProperty('move.scale.y', getProperty('iconP2.scale.y'))
		setProperty('move.scale.x', getProperty('iconP2.scale.x'))
		setProperty('move.antialiasing',true)

		setObjectOrder('move', getObjectOrder('iconP2') + 1)
		setProperty('iconP2.alpha', 0) 

		setProperty('move2.flipX', true)
		setProperty('move2.visible', true)
		setProperty('move2.y', getProperty('iconP1.y') + 14)
		setProperty('move2.x', getProperty('iconP1.x'))
		setProperty('move2.scale.y', getProperty('iconP1.scale.y'))
		setProperty('move2.scale.x', getProperty('iconP1.scale.x'))
		setProperty('move2.antialiasing',true)


		setObjectOrder('move2', getObjectOrder('iconP1') + 1)
		setProperty('iconP1.alpha', 0) 
		
	end
end

function onTimerCompleted(tag, loops, loopsLeft)
	if specialIcons then
		if tag == 'LOSE2' then
			
			--objectPlayAnimation('move','lose',true);
			playAnim('move', 'lose',true)
		
		end

		if tag == 'WIN2' then
			
		--	objectPlayAnimation('move','win',true);
			playAnim('move', 'win',true)
			
		end

		if tag == 'LOSE1' then
			
			--objectPlayAnimation('move2','lose',true);
			playAnim('move2', 'lose',true)
		
		end

		if tag == 'WIN1' then
			
			--objectPlayAnimation('move2','win',true);
			playAnim('move2', 'win',true)

		end

	end

end
