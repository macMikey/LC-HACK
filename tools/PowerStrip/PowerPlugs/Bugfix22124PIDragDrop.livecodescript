script "Bugfix22124"

/*
* fix for bugzilla #
*
* more verbose description
*/

local sOriginalUpdateHandler

# could have multiple handlers and objects here
# if necessary for a complete patch
# otherwise just need one of these

constant kHandler = "dragEnter"  # the name of the handler to replace
constant kHandler2 = "dragDrop"  # the name of the handler to replace
constant kObject = "/Toolset/palettes/inspector/editors/com.livecode.pi.file.behavior" # object whose script contains the handler

# ***********************************************************************
# if only one patch

command initializePlugin
    dispatch function "initializeHandler" to stack "PowerStrip" with kHandler, kObject, the name of me
    put the result into sOriginalUpdateHandler
end initializePlugin

command removePlugin
    dispatch "monkeyPatch" to stack "PowerStrip" with kObject, kHandler, sOriginalUpdateHandler
end removePlugin

# ***********************************************************************
# else if multiple patches : 3 here

local sOriginalRemove
local sOriginalPlatforms


command initializePlugin
    dispatch function "initializeHandler" to stack "PowerStrip" with kHandler, kObject, the name of me
    put the result into sOriginalUpdateHandler

    dispatch function "initializeHandler" to stack "PowerStrip" with kHandler2, kObject2 the name of me
    put the result into sOriginalRemove
end initializePlugin

command removePlugin
    dispatch "monkeyPatch" to stack "PowerStrip" with kObject, kHandler, sOriginalUpdateHandler
    dispatch "monkeyPatch" to stack "PowerStrip" with kObject2 kHandler2, sOriginalRemove
end removePlugin
# ***********************************************************************


# in order to replace a complete handler in kObject...

# Here's the corrected handlers:

on dragEnter
   if the dragData["files"] is empty then
      pass dragEnter
   end if
   set the dragAction to "link"
end dragEnter

on dragDrop
   if the dragData["files"] is empty then
      pass dragDrop
   end if
   set the text of field 1 of me to line 1 of the dragData["files"]
   valueChanged
end dragDrop

