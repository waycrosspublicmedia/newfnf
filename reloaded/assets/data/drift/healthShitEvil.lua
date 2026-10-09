function goodNoteHit(id, direction, noteType, isSustainNote)
	health = getProperty('health')
    setProperty('health', getProperty('health')+0.07);
end

function opponentNoteHit(id, direction, noteType, isSustainNote)

	if curStep > 1248 then
		
		health = getProperty('health')
		if getProperty('health') > 0.2 then
			setProperty('health', health- 0.095);
		end
	else
		health = getProperty('health')
		if getProperty('health') > 0.2 then
			setProperty('health', health- 0.045);
		end
	end
end

