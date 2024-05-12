script "svgGradientImport.livecodescript"

/*
* https://forums.livecode.com/viewtopic.php?f=7&t=37821&start=15
*
* Importing svg gradients fails on underline
*/

#maxVersion 9.6.8

local sOriginalHandler
constant kHandler = "_svgParsePaintValue"  # the name of the handler to replace
constant kObject = "stack com.livecode.library.drawing" # object whose script contains the handler

command initializePlugin
    dispatch function "initializeHandler" to stack "PowerStrip" with kHandler, kObject, the name of me
    put the result into sOriginalHandler
end initializePlugin

command removePlugin
    dispatch "monkeyPatch" to stack "PowerStrip" with kObject, kHandler, sOriginalHandler
end removePlugin

# Here's the corrected handler:

private function _svgParsePaintValue @xValue
	if xValue is "none" then
		put "none" into xValue["type"]
		return true
	end if

	if xValue is "currentColor" then
		put "current" into xValue["type"]
		return true
	end if

	if _svgParseColorValue(xValue) then
		return true
	end if

	local tId, tBackup
	if matchText(xValue, "^url\s*\(\s*#([a-zA-Z][a-zA-Z0-9_]*)*\)(.*)$", tId, tBackup) then
		put word 1 to -1 of tBackup into tBackup
		if tBackup is not empty and \
			tBackup is not "none" and \
			tBackup is not "currentColor" and \
			not _svgParseColorValue(tBackup) then
			return false
		end if
		if tBackup is empty then
			put "none" into tBackup
		end if
		put "reference" into xValue["type"]
		put tId into xValue["id"]
		put tBackup into xValue["fallback"]
		return true
	end if

	if xValue is among the items of \
		("ActiveBorder,ActiveCaption,AppWorkspace,Background,ButtonFace,ButtonHighlight," & \
			"ButtonShadow,ButtonText,CaptionText,GrayText,Highlight,HighlightText,InactiveBorder," & \
			"InactiveCaption,InactiveCaptionTextx,InfoBackground,InfoText,Menu,MenuTextx,Scrollbar," & \
			"ThreeDDarkShadow,ThreeDFace,ThreeDHighlight,ThreeDLightShadow,ThreeDShadow,Window," & \
			"WindowFrame,WindowText") then
		put xValue into xValue["id"]
		put "system" into xValue["type"]
		return true
	end if

	return false
end _svgParsePaintValue

