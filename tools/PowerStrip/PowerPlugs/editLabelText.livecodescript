script "editLabelText.livecodescript"

/*
* double-click a label field in edit mode to edit the text
*/

local sOriginalHandler
constant kHandler = "closeField"  # the name of the handler to replace
constant kHandler2 = "mouseDoubleUp"  # the name of the handler to add
constant kObject = "stack revbackscriptlibrary" # object whose script contains the handler

command initializePlugin
    local tText # the text of the replacement handler

    dispatch function "initializeHandler" to stack "PowerStrip" with kHandler, kObject, the name of me
    put the result into sOriginalHandler

    dispatch function "originalPlugPatch" to stack "PowerStrip" with me, kHandler2
    put the result into tText
    dispatch "monkeyPatch" to stack "PowerStrip" with  kObject, kHandler2, tText
end initializePlugin

command removePlugin
    dispatch "monkeyPatch" to stack "PowerStrip" with kObject, kHandler, sOriginalHandler
    dispatch "monkeyPatch" to stack "PowerStrip" with kObject, kHandler2, empty
end removePlugin

# Here's the corrected handler:

on closeField
   local tTargetID
   
   put the long id of the target into tTargetID
   # is this a label field?
   if the opaque of tTargetID is false then
      set the lockText of tTargetID to true
      set the autohilite of tTargetID to false
      set the traversalOn of tTargetID to false
   end if
   if the cREVGetsUpdate of stack revTargetStack() is not empty then
      set the backPattern of tTargetID to empty
   end if
   if not gREVSuppressMessages or (gREVSuppressMessages and revOKTarget()) then
      pass closeField
   end if
end closeField

on mouseDoubleUp pButtonNo, pTarget
   global gREVSuppressMessages
   local tName

   put the long id of the mousecontrol into tName
   # is this a label field?
   if word 1 of tName is "field" and the environment is "development" then
      if the lockText of tName is true then
         set the lockText of tName to false
         set the autohilite of tName to true
         set the traversalOn of tName to true
         select before char 1 of tName
         choose browse tool
      end if
   else
      if revCheckEdit(pTarget) then
         revIDEOpenInspectorForObjects revIDESelectedObjects()
      else if not gREVSuppressMessages or (gREVSuppressMessages and revOKTarget()) then
         pass mouseDoubleUp
      end if
   end if
end mouseDoubleUp

