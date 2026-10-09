local doDialogue = true
local allowCountdown = false
function onStartCountdown()
	if doDialogue and not seenCutscene and isStoryMode and not censored then
		startDialogue('insaneShit', 'dialogueMusic/insaneDia') 
		doDialogue = false
		return Function_Stop
	end
	if doDialogue and not seenCutscene and isStoryMode and censored then
		startDialogue('insaneCensored', 'dialogueMusic/insaneDia') 
		doDialogue = false
		return Function_Stop
	end
	return Function_Continue
end
