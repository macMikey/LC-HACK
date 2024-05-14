script "Bugfix22297.livecodescript"

/*
* fix for bugzilla #22297
*
* Inspector should unsubscribe from all messages on closeStack
*/

local sOriginalUpdateHandler

constant kHandler = "closeStack"  # the name of the handler to replace
constant kObject = "stack revinspectorTemplate" # object whose script contains the handler

command initializePlugin
    dispatch function "initializeHandler" to stack "PowerStrip" with kHandler, kObject, the name of me
    put the result into sOriginalUpdateHandler
end initializePlugin

command removePlugin
    dispatch "monkeyPatch" to stack "PowerStrip" with kObject, kHandler, sOriginalUpdateHandler
end removePlugin

# Here's the corrected handlers:

on closeStack
   ## Unsubscribe from all messages
   revIDEUnsubscribeAll
   
   set the cSelectedObjects of me to empty
   
   # Unlock
   put false into sInspectorLock
end closeStack

