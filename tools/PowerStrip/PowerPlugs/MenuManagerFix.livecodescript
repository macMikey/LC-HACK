script "MenuManagerFix.livecodescript"

/*
* per OpenXTalk menu fix
*
* more verbose description
*/

local sOriginalUpdateHandler

# could have multiple handlers and objects here
# if necessary for a complete patch
# otherwise just need one of these

constant kHandler = "mouseUp"  # the name of the handler to replace
constant kObject = "field Menu Items of group Menu Items: of card Menu Manager of stack revmenumanager" # object whose script contains the handler

local sOriginalRemove
local sOriginalPlatforms

constant kHandler2 = "mouseDown"  # the name of the handler to replace
constant kHandler3 = "preOpenStack"  # the name of the handler to replace
constant kObject2 = "card Menu Manager of stack revmenumanager" # object whose script contains the handler

command initializePlugin
    dispatch function "initializeHandler" to stack "PowerStrip" with kHandler, kObject, the name of me
    put the result into sOriginalUpdateHandler

    dispatch function "initializeHandler" to stack "PowerStrip" with kHandler2, kObject, the name of me
    put the result into sOriginalRemove

    dispatch function "initializeHandler" to stack "PowerStrip" with kHandler3, kObject2, the name of me
    put the result into sOriginalPlatforms
end initializePlugin

command removePlugin
    dispatch "monkeyPatch" to stack "PowerStrip" with kObject, kHandler, sOriginalUpdateHandler
    dispatch "monkeyPatch" to stack "PowerStrip" with kObject, kHandler2, sOriginalRemove
    dispatch "monkeyPatch" to stack "PowerStrip" with kObject2, kHandler3, sOriginalPlatforms
end removePlugin

# in order to replace a complete handler in kObject...

# Here's the corrected handlers:

on mouseUp
   if the cAnswerDialog of fld "Menu Name" or the cAnswerDialog of fld "Item Name" then exit mouseUp
   
   
   lock screen  
   revSetEnabled
   if the text of me is not empty then
      revSetWidgetPosition
      revSetHilite
   end if
   
   if the num of items in the hilitedLines of me is 1
   then revFilterItemName
   
   -- LG 2008-08-29
   -- Need to put the item name into the item name field
   
   local tMenuLine, tSlashOffset, tMenuName
   --put line(the hilitedLine of me) of the unicodeText of me into tMenuLine
   put the unicodeText of line(the hilitedLine of me) of me into tMenuLine
   put uniDecode(tMenuLine,"UTF8") into tMenuLine
   --put offset(slash, tMenuLine) into tSlashOffset
   repeat for each char tChar in tMenuLine
      if tChar is tab then
         next repeat
      else if tChar is slash then
         exit repeat
      end if
      put tChar after tMenuName
   end repeat
   
   if "&" is in tMenuName then replace "&" with "" in tMenuName  --TL 11/2022, fix special chars added to fld "Item Name".
   if "(" is in tMenuName then replace "(" with "" in tMenuName
   if "!c" is in tMenuName then replace "!c" with "" in tMenuName
   if "!n" is in tMenuName then replace "!n" with "" in tMenuName
   --put tMenuName into field "Item Name"
   set the unicodeText of field "Item Name" to uniEncode(tMenuName,"UTF8")
   
   unlock screen
end mouseUp

on mouseDown
   local tMouseLine
   if the text of me is empty or the mouseLine is empty then exit mouseDown
   put word 2 of the mouseLine into tMouseLine
   set the cBroughtUpAnswerDialog of fld "Menu Name" to false
   revCheckNameChanged
   lock screen
   set the hilitedLine of me to tMouseLine
   --if the cBroughtUpAnswerDialog of fld "Menu Name" then mouseUp
   mouseUp  --TL 11/22, fix to reposition orange line smoothly
   unlock screen
end mouseDown

on preOpenStack
   --window positioning
   local tTopLeft
   put the cREVMenuManagerTopLeft of stack "revPreferences" into tTopLeft
   if tTopLeft is not empty then
      if item 1 of tTopLeft + the width of this stack < item 3 of the windowBoundingRect \
      and item 2 of tTopLeft + the height of this stack < item 4 of the windowBoundingRect then
         set the topLeft of this stack to tTopLeft
      else 
         set loc of this stack to the screenLoc
      end if
   else set the loc of this stack to the screenLoc
   
   revMenuManagerInitialisation
   
   local tTopStack, tMenubar
   put the short name of the topStack into tTopStack
   put the menubar of stack tTopStack into tMenubar
   if tMenubar is not empty and there is a grp tMenubar of this cd of stack tTopStack then
      set the cREVMenuID of this stack to the id of grp tMenubar of this cd of stack tTopStack
      set the cREVDefaultStack of this stack to tTopStack
      set the cREVMenubar of this stack to tMenubar
      revEditMenubar
   else     
      revReset
      revInitialise
   end if
   
   if platform() = "MacOS" then
      show button "Control"
      set the label of button "Command" to "Cmd"
      set the label of button "Option_Alt" to "Opt"
   else  --win/linux
      hide button "Control"
      set the label of button "Command" to "Ctrl"
      set the label of button "Option_Alt" to "Alt"
   end if

   set the left of button "Shortcut" of me to the right of me + 10
   
   #MJ: adding the window constrain function.
   revInternal__ConstrainStack the short name of the owner of me
   pass preOpenStack
end preOpenStack

