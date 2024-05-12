script "setPropertyOfObjectBugfix23252.livecodescript"

/*
* fix for bugzilla #23252
*
* Allow a player object to be dragged from the tools palette
*/

local sOriginalHandler
constant kHandler = "__setPropertyOfObject"  # the name of the handler to replace
constant kObject = "stack revIDELibrary" # object whose script contains the handler

command initializePlugin
    dispatch function "initializeHandler" to stack "PowerStrip" with kHandler, kObject, the name of me
    put the result into sOriginalHandler
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

