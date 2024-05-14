script "Bugfix22555.livecodescript"

/*
* fix for bugzilla #22555
*
* more verbose description
*/

local sOriginalRemove
local sOriginalUpdateHandler

# could have multiple handlers and objects here
# if necessary for a complete patch
# otherwise just need one of these

constant kHandler = "scriptCompile"  # the name of the handler to replace
constant kObject = "stack revseeditorbehavior" # object whose script contains the handler

command initializePlugin
    dispatch function "initializeHandler" to stack "PowerStrip" with kHandler, kObject, the name of me
    put the result into sOriginalUpdateHandler
end initializePlugin

command removePlugin
    dispatch "monkeyPatch" to stack "PowerStrip" with kObject, kHandler, sOriginalUpdateHandler
end removePlugin

# in order to replace a complete handler in kObject...

# Here's the corrected handler:
local sHandlerList # dummy so it will compile

command scriptCompile pObject
   lock screen
   lock messages
   
   local tOldPreserveVariables, tOldExplicitVariables
   put the preserveVariables into tOldPreserveVariables
   put the explicitVariables into tOldExplicitVariables
   set the preserveVariables to sePrefGet("preserveVariables")
   set the explicitVariables to sePrefGet("explicitVariables")
   
   local tScript
   scriptGet pObject
   put the result into tScript
   
   local tResult
   local tDoUpdateDescription
   set the script of button "revCompileObject" of me to tScript
   put the result into tResult
   -- if setting the script failed with explicit vars try without
   if tResult is not empty and the explicitVariables then
      set the explicitVariables to false
      set the script of button "revCompileObject" of me to tScript
      put the result is empty into tDoUpdateDescription
   else
      put tResult is empty into tDoUpdateDescription
   end if
   
   if tDoUpdateDescription then
      --! TODO remove use of revAvailableHandlers here (quite invasive)
      put the revAvailableHandlers of button "revCompileObject" of me into sHandlerList
      get getObjectID()
      if exists(it) and revEnvironmentEditionProperty("autocomplete") then
         ideAutocompleteUpdateScriptDescription it, the revScriptDescription of button "revCompileObject" of me
      end if
   end if
   
   local tLiveErrors
   put sePrefGet("editor,liveerrors") into tLiveErrors
   put tLiveErrors and not the lockText of field "script" of me into tLiveErrors
   
   local tState
   getDirty pObject
   if the result then
      put "edited" into tState
   else
      put "applied" into tState
   end if
   
      send "clearErrors" to group "Errors" of the owner of me
      if tResult is empty then
         setCompilationErrors empty, pObject
      else
         send "addError compilation, line 1 of tResult, pObject" to group "Errors" of the owner of me
         setCompilationErrors line 1 of tResult, pObject
         put "error" into tState
      end if

   seSetObjectState pObject, tState
   
   set the preserveVariables to tOldPreserveVariables
   set the explicitVariables to tOldExplicitVariables
   
   # The script should be unset because it could cause issues with idle handlers
   set the script of button "revCompileObject" of me to empty
   
   unlock messages
   unlock screen
   
   return tResult
end scriptCompile

