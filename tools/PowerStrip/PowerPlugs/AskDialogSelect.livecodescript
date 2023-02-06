script "ASKDialogSelect.livecodescript"

/*
* select the text
*/

local sOriginalHandler
constant kHandler = "openCard"  # the name of the handler to replace
constant kObject = "stack Ask Dialog" # object whose script contains the handler

command initializePlugin
    dispatch function "initializeHandler" to stack "PowerStrip" with kHandler, kObject, the name of me
    put the result into sOriginalHandler
end initializePlugin

command removePlugin
    dispatch "monkeyPatch" to stack "PowerStrip" with kObject, kHandler, sOriginalHandler
end removePlugin

# Here's the corrected handler:

on openCard
   select the text of field 2 of me #mikey h4x0rz t3h IDE
end openCard
