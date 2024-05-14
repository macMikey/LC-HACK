script "Bugfix22977.livecodescript"

/*
* fix the leaky mouseDown in the Ask and Answer dialogs
*/

local sOriginalHandler
constant kHandler = "mouseDown"  # the name of the handler to replace
constant kAskObject = "card 1 of stack Ask Dialog" # object whose script contains the handler
constant kAnswerObject = "card 1 of stack Answer Dialog" # object whose script contains the handler

command initializePlugin
    dispatch function "initializeHandler" to stack "PowerStrip" with kHandler, kAskObject, the name of me
    dispatch function "initializeHandler" to stack "PowerStrip" with kHandler, kAnswerObject, the name of me
    put the result into sOriginalHandler
end initializePlugin

command removePlugin
    dispatch "monkeyPatch" to stack "PowerStrip" with kAskObject, kHandler, sOriginalHandler
    dispatch "monkeyPatch" to stack "PowerStrip" with kAnswerObject, kHandler, sOriginalHandler
end removePlugin

# Here's the corrected handler:

on mouseDown
end mouseDown
