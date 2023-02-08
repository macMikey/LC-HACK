script "revIDEClearPaletteRects.livecodescript"

/*
* fix for bugzilla #21976
*
* there are many unnecessary rect custom properties in preferences stack
*/

local sOriginalHandler
constant kHandler = "revIDEClearPaletteRects"  # the name of the handler to replace
constant kObject = "stack revIDELibrary" # object whose script contains the handler

command initializePlugin
    dispatch function "initializeHandler" to stack "PowerStrip" with kHandler, kObject, the name of me
    put the result into sOriginalHandler
end initializePlugin

command removePlugin
    dispatch "monkeyPatch" to stack "PowerStrip" with kObject, kHandler, sOriginalHandler
end removePlugin

# Here's the corrected handler:

on revIDEClearPaletteRects
   local tPropArray, tCleanProps
   local tKeys
   put the customProperties of stack "revPreferences" into tPropArray
   put the keys of tPropArray into tKeys
   repeat for each line tKey in tKeys
      if tKey begins with "palette_rect_/tmp" then
      else if tKey begins with "palette_rect_Stack_" then
      else
         put tPropArray[tKey] into tCleanProps[tKey]
      end if
   end repeat
   # put the keys of tPropArray into msg
   set the customProperties of stack "revPreferences" to tCleanProps
end revIDEClearPaletteRects

