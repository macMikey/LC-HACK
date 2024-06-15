script "AnswerDialogCopyText"

/*
* Since there's currently no way to select the text in a modal dialog
*/

local sOriginalHandler
constant kHandler = "openCard"  # the name of the handler to replace
#constant kObject = "/Toolset/palettes/revanswerdialog.livecode" # object whose script contains the handler
constant kObject = "stack Answer Dialog" # object whose script contains the handler

command initializePlugin
    dispatch function "initializeHandler" to stack "PowerStrip" with kHandler, kObject, the name of me
    put the result into sOriginalHandler
end initializePlugin

command removePlugin
    dispatch "monkeyPatch" to stack "PowerStrip" with kObject, kHandler, sOriginalHandler
end removePlugin

# Here's the corrected handler:

on openCard
	select the text of field 1 of me
    set the clipboarddata["text"] to field 1 of me
end openCard
