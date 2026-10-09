local doDialogue = true
local allowCountdown = false
function onStartCountdown()
	if doDialogue and not seenCutscene and isStoryMode and not censored then
		startDialogue('driftShit', 'dialogueMusic/driftDia') 
		doDialogue = false
		return Function_Stop
	end
	if doDialogue and not seenCutscene and isStoryMode and censored then
		startDialogue('driftCensored', 'dialogueMusic/driftDia') 
		doDialogue = false
		return Function_Stop
	end
	return Function_Continue
end

