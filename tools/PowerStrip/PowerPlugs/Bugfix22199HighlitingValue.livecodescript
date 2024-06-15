script "Bugfix22199"

/*
* fix for bugzilla #
*
* more verbose description
*/

local sOriginalUpdateHandler
local sPatchArray

# could have multiple handlers and objects here
# if necessary for a complete patch
# otherwise just need one of these

constant kHandler = "openField"  # the name of the handler to replace
#constant kObject = "stack com.livecode.pi.customprops.behavior" # object whose script contains the handler
constant kObject = "/Toolset/palettes/inspector/editors/com.livecode.pi.customprops.behavior.livecodescript" # object whose script contains the handler

# ***********************************************************************
# if only one patch

command initializePlugin
    dispatch function "initializeHandler" to stack "PowerStrip" with kHandler, kObject, the name of me, "openfield"
    put the result into sOriginalUpdateHandler
end initializePlugin

command removePlugin
	local tOriginal

	put arrayPop(kHandler, "after", kObject) into tOriginal
    dispatch "monkeyPatch" to stack "PowerStrip" with kObject, kHandler, tOriginal
#    dispatch "monkeyPatch" to stack "PowerStrip" with kObject, kHandler, sOriginalUpdateHandler
end removePlugin

command arrayPush pHandler, pType, pObject, pOriginal
	local tIndex

	put the number of elements of sPatchArray into tIndex
	add 1 to tIndex
	put pType into sPatchArray[tIndex][pObject][pHandler]["type"]
	if pOriginal is not empty then
		put pOriginal into sPatchArray[tIndex][pObject][pHandler]["original"]
	end if
end arrayPush

function arrayPop pHandler, pType, pObject
	local tIndex
	local tReturn

	put 1 into tIndex
	repeat for each element tElement in sPatchArray
		if tElement[pObject][pHandler]["type"] is pType then
			put tElement[pObject][pHandler]["original"] into tReturn
			delete variable sPatchArray[tIndex]
		end if
		add 1 to tIndex
	end repeat
	return tReturn
end arrayPop

# in order to replace a complete handler in kObject...

# Here's the corrected handlers:

## bug 22199 prevent hiliting field "Value" when clicking to enter text
after openField
   ## block "after openfield" message in stack "revInspectorEditorBehavior"
end openField

