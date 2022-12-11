script "menubarHeight.livecodescript"

/*
* fix for bugzilla #16880
*/

local sOriginalHandler
constant kHandler = "setMenuProperties"  # the name of the handler to replace
constant kObject = "stack revMenuBar" # object whose script contains the handler

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

on setMenuProperties
   set the height of me to 47
   set the resizable of me to false
   
   local tTitle
   set the itemDelimiter to "-"
   put "LiveCode" into tTitle
   if item 1 of the version ends with ".0" then
      put space & char 1 to -3 of item 1 of the version after tTitle
   else
      put space & item 1 of the version after tTitle
   end if
   if item 2 of the version is not empty then
      put space & "(" & item 2 of the version && item 3 of the version & ")" after tTitle
   end if
   set the itemDelimiter to comma
   set the title of me to tTitle
   
   local tScreenRect
   put revIDEStackScreenRect(the short name of this stack, true) into tScreenRect

# 2020.02.29 mdw [[ bugfix_16880 ]]
   set the minHeight of me to 19

   if the platform is not "MacOS" then
      if item 3 of the screenRect is 800 then
         set the topLeft of me to item 1 to 2 of tScreenRect
      else 
         --screen rect > 800 by 600
         if revIDEGetPreference("cREVMenuBarTopLeft") is empty
         then set the loc of me to item 1 of revIDEStackScreenLoc(the short name of this stack), 54
         else set the topLeft of me to revIDEGetPreference("cREVMenuBarTopLeft")
      end if
   end if
   
   if the platform is "MacOS" then
      set the decorations of me to empty
      set the topLeft of me to item 1 to 2 of tScreenRect
   else
      set the decorations of me to "default"
   end if
end setMenuProperties

