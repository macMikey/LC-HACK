script "Bugfix22803"

/*
* fix for bugzilla #22803
*
* Fix runtime error when editing a DG form
*/

local sOriginalUpdateHandler

constant kHandler = "DeleteFieldEditor"  # the name of the handler to replace
constant kObject = "stack revDataGridLibraryBehaviorsDataGridButtonBehavior" # object whose script contains the handler

command initializePlugin
    dispatch function "initializeHandler" to stack "PowerStrip" with kHandler, kObject, the name of me
    put the result into sOriginalUpdateHandler
end initializePlugin

command removePlugin
    dispatch "monkeyPatch" to stack "PowerStrip" with kObject, kHandler, sOriginalUpdateHandler
end removePlugin

# Here's the corrected handler:

command DeleteFieldEditor pSaveContents
   local msgsAreLocked
   put the lockMessages into msgsAreLocked
   
   if there is not a sFieldEditor then
      ## If error occurred when messages were broadcast below then you could end up with
      ## empty sFieldEditor. We get rid of it here.
      ## We clear out sFieldEditor so that if an error does occur we don't come back later
      ## and save changes.
      if there is a field kFieldEditorName of group "dgListMask" of me then
         lock messages
         delete field kFieldEditorName of group "dgListMask" of me
         set the lockMessages to msgsAreLocked
      end if
      
      return empty
   end if
   
   put pSaveContents is not false into pSaveContents
   
   unlock messages
   
   local theEditor, theResult, theField, theError
   put sFieldEditor into theEditor
   put empty into sFieldEditor
   put empty into theResult
   
   put the dgTargetField of theEditor into theField
   
   ## Keeps focus from getting messed up when dgDataOfIndex redraws
   if theEditor is the long ID of the focusedObject then
      lock messages
      focus on graphic "dgBackground" of me ## Engine doesn't like deleting focused control in groups
      unlock messages
   end if
   
   if pSaveContents and there is a theField then
      local theIndex, theKey, contentHasChanged
      put the dgTargetIndex of theEditor into theIndex
      put the dgTargetKey of theEditor into theKey ## might be an array index
      
      set the caseSensitive to true
      put the HTMLText of theEditor is not the dgOriginalHTMLText of theEditor into contentHasChanged
      set the caseSensitive to false
      
      ## Did user want us to automatically save?
      if theIndex is an integer and (theKey is not empty and theKey is not an array) then
         if contentHasChanged then

            local tText
            ## Give the developer a chance to stop value from being set
            try
               switch the dgTextType of theEditor
                  case "html"
                     put the HTMLText of theEditor into tText
                     break
                  case "rtf"
                     put the RTFText of theEditor into tText
                     break
                  case "unicode"
                     put the unicodeText of theEditor into tText
                     break
                  case "utf8"
                     put the unicodeText of theEditor into tText
                     put uniDecode(tText, "utf8") into tText
                     break
                  default
                     put the text of theEditor into tText
               end switch
               dispatch "CloseFieldEditor" to theField with theEditor
               if it is "handled" then
                  put the result into theResult
               end if
               
               if theResult is not "cancel" then
                  local theDataA
                  put sDataArray[theIndex] into theDataA
                  put tText into theDataA[theKey]
                  set the dgDataOfIndex [theIndex] of me to theDataA
               end if
            catch e
               put e into theError
            end try
         else
            try
               dispatch "ExitFieldEditor" to theField with theEditor
               if it is "handled" then
                  put the result into theResult
               end if
            catch e
               put e into theError
            end try
         end if
      else
         ## Announce our closing to the world
         try
            if contentHasChanged then
               dispatch "CloseFieldEditor" to theField with theEditor
            else
               dispatch "ExitFieldEditor" to theField with theEditor
            end if
            if it is "handled" then
               put the result into theResult
            end if
         catch e
            put e into theError
         end try
      end if
   end if ## pSaveContents check
   
   lock screen
   if there is a theEditor then delete theEditor
   set the lockMessages to msgsAreLocked
   
   ## If user displayed an answer dialog in any callbacks we end
   ## up with unbalanced focusOut/In messages. This causes hilites
   ## to stay grey. Force update
   put true into sFocusLeftMe
   _UpdateHiliteColor
   unlock screen
   
   if theError is not empty then throw theError
   
   return theResult
end DeleteFieldEditor

