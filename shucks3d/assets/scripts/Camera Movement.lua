local enabled = true

-- CAMERA SETTINGS --
local dadstrength = 50
local bfstrength = 50
local camerarotation = false

-- NOT SETTINGS --
local dadx = 0
local dady = 0
local bfx = 0
local bfy = 0

function setCharacterProperties(character, x, y, strength)
	setProperty(character .. 'i.alpha', 0.5)
	setProperty(character .. 'l.alpha', 0.5)
	setProperty(character .. 'd.alpha', 0.5)
	setProperty(character .. 'u.alpha', 0.5)
	setProperty(character .. 'r.alpha', 0.5)

	local animName = getProperty(character .. '.animation.curAnim.name')
	local animOffsetX = 0
	local animOffsetY = 0
	local angle = cameraRotation and 0 or nil

	if animName == 'singLEFT' or animName == 'singLEFT-alt' then
		animOffsetX = -strength
		angle = -1
	elseif animName == 'singDOWN' or animName == 'singDOWN-alt' then
		animOffsetY = strength
		angle = 2
	elseif animName == 'singUP' or animName == 'singUP-alt' then
		animOffsetY = -strength
		angle = -2
	elseif animName == 'singRIGHT' or animName == 'singRIGHT-alt' then
		animOffsetX = strength
		angle = 1
	end

	triggerEvent('Camera Follow Pos', x + animOffsetX, y + animOffsetY)
	setProperty(character .. 'i.x', x)
	setProperty(character .. 'i.y', y)
	setProperty(character .. 'l.x', x - strength)
	setProperty(character .. 'l.y', y)
	setProperty(character .. 'd.x', x)
	setProperty(character .. 'd.y', y + strength)
	setProperty(character .. 'u.x', x)
	setProperty(character .. 'u.y', y - strength)
	setProperty(character .. 'r.x', x + strength)
	setProperty(character .. 'r.y', y)

	if cameraRotation then
		doTweenAngle('turn', 'camGame', angle, 1, 'circOut')
	end
end

function onUpdate()
	if enabled then

		dadx = getMidpointX('dad') + 100 + (getProperty('dad.cameraPosition[0]') + getProperty('opponentCameraOffset[0]'))
		dady = getMidpointY('dad') - 100 + (getProperty('dad.cameraPosition[1]') + getProperty('opponentCameraOffset[1]'))
		bfx = getMidpointX('boyfriend') - 100 - (getProperty('boyfriend.cameraPosition[0]') - getProperty('boyfriendCameraOffset[0]'))
		bfy = getMidpointY('boyfriend') - 100 + (getProperty('boyfriend.cameraPosition[1]') + getProperty('boyfriendCameraOffset[1]'))

		if mustHitSection then
			setCharacterProperties('boyfriend', bfx, bfy, bfstrength)
		else 
			setCharacterProperties('dad', dadx, dady, dadstrength)
		end
	end
end