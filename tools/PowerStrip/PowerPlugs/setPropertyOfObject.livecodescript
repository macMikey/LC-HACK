script "setPropertyOfObject.livecodescript"

/*
* fix for bugzilla #23252
*/

local sOriginalHandler
constant kHandler = "__setPropertyOfObject"  # the name of the handler to replace
constant kObject = "stack revIDELibrary" # object whose script contains the handler

command initializePlugin
    local tText # the text of the replacement handler
    dispatch function "originalPlugPatch" to stack "PowerStrip" with kObject, kHandler
    put the result into sOriginalHandler

    dispatch function "originalPlugPatch" to stack "PowerStrip" with me, kHandler
    put the result into tText
    dispatch "monkeyPatch" to stack "PowerStrip" with  kObject, kHandler, tText
end initializePlugin

command removePlugin
    dispatch "monkeyPatch" to stack "PowerStrip" with kObject, kHandler, sOriginalHandler
end removePlugin

# Here's the corrected handler:

private on __setPropertyOfObject pObject, pProperty, pValue
   if pProperty is "customProperties" then
      put true into sLockUpdates
   end if
   
   local tProperties
   put __classicObjectProperties(pObject) into tProperties
   
   if tProperties["properties"][pProperty]["setter"] is not empty then
      dispatch tProperties["properties"][pProperty]["setter"] with pObject, pProperty, pValue
   else
      try
        set the pProperty of pObject to pValue
      catch e
      end try
   end if
end __setPropertyOfObject

