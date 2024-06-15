script "Bugfix22205"

/*
* fix for bugzilla #22205
*
* Ensure the check for IDE stacks is accurate
*/

local sOriginalRemove
local sOriginalUpdateHandler
local sOriginalPlatform

# could have multiple handlers and objects here
# if necessary for a complete patch
# otherwise just need one of these

constant kHandler = "revInternal__LoadIfLibrary"  # the name of the handler to replace
constant kObject = "stack revInitializationLibrary" # object whose script contains the handler

command initializePlugin
    dispatch function "initializeHandler" to stack "PowerStrip" with kHandler, kObject, the name of me
    put the result into sOriginalUpdateHandler
end initializePlugin

command removePlugin
    dispatch "monkeyPatch" to stack "PowerStrip" with kObject, kHandler, sOriginalUpdateHandler
end removePlugin

# in order to replace a complete handler in kObject...

# Here's the corrected handlers:

command revInternal__LoadIfLibrary pLibrary
   try
      local tAvailable, tMsg
      put the revAvailableHandlers of stack pLibrary into tAvailable
      if tAvailable contains "extensionInitialize" then
         put "extensionInitialize" into tMsg
         // TODO: Remove legacy message name	            
      else if tAvailable contains "revLoadLibrary" then 
         put "revLoadLibrary" into tMsg
      else
         throw "not a library"
      end if
		set the _ideoverride of stack pLibrary to true
      send tMsg to stack pLibrary
      local tStackName
      put the name of stack pLibrary into tStackName
      put tStackName into sLoadedLibraries[pLibrary]
      return true
   end try
   delete stack pLibrary
   return false
end revInternal__LoadIfLibrary

