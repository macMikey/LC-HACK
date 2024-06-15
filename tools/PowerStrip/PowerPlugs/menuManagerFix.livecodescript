script "MenuManagerFix"

/*
* per OpenXTalk menu fix
*
* more verbose description
*/

constant kObject = "field Menu Items of group Menu Items: of card Menu Manager of stack revmenumanager" # object whose script contains the handler
constant kHandler = "mouseUp"  # the name of the handler to replace
local sOriginal1
constant kHandler2 = "mouseDown"  # the name of the handler to replace
local sOriginal2

constant kObject2 = "card Menu Manager of stack revmenumanager" # object whose script contains the handler
constant kHandler3 = "preOpenStack"  # the name of the handler to replace
local sOriginal3
constant kHandler6 = "openStack"  # the name of the handler to replace
local sOriginal6

constant kObject3 = "field Menu Buttons of group Button Menus: of card Menu Manager of stack revmenumanager" # object whose script contains the handler
constant kHandler4 = "Buttons.mouseDown"  # the name of the handler to replace
local sOriginal4
constant kHandler5 = "Buttons.mouseUp"  # the name of the handler to replace
local sOriginal5

command initializePlugin
   local tCaller
   
   put the name of me into tCaller
   
   # field Menu Items
   dispatch function "initializeHandler" to stack "PowerStrip" with kHandler, kObject, tCaller
   put the result into sOriginal1
   
   dispatch function "initializeHandler" to stack "PowerStrip" with kHandler2, kObject, tCaller
   put the result into sOriginal2
   
   # card Menu Manager
   dispatch function "initializeHandler" to stack "PowerStrip" with kHandler3, kObject2, tCaller
   put the result into sOriginal3
   
   #dispatch function "initializeHandler" to stack "PowerStrip" with kHandler6, kObject2, tCaller
   #put the result into sOriginal6
   
   # field Menu Buttons
   dispatch function "initializeHandler" to stack "PowerStrip" with kHandler2, kObject3, tCaller, kHandler4
   put the result into sOriginal4
   
   dispatch function "initializeHandler" to stack "PowerStrip" with kHandler, kObject3, tCaller, kHandler5
   put the result into sOriginal5
end initializePlugin

command removePlugin
   dispatch "monkeyPatch" to stack "PowerStrip" with kObject3, kHandler, sOriginal5
   dispatch "monkeyPatch" to stack "PowerStrip" with kObject3, kHandler2, sOriginal4
   #dispatch "monkeyPatch" to stack "PowerStrip" with kObject3, kHandler6, sOriginal6
   dispatch "monkeyPatch" to stack "PowerStrip" with kObject2, kHandler3, sOriginal3
   dispatch "monkeyPatch" to stack "PowerStrip" with kObject, kHandler2, sOriginal2
   dispatch "monkeyPatch" to stack "PowerStrip" with kObject, kHandler, sOriginal1
end removePlugin

# in order to replace a complete handler in kObject...

# Here's the corrected handlers:

#########################################################
# into field "Menu Items"
#########################################################

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
   mouseUp  --TL 11/22, fix to reposition orange line smoothly
   unlock screen
end mouseDown

#########################################################
# into card script
#########################################################

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
   
   set the tooltip of button "Auto Script" to "Insert a framework menuPick handler for menuItems in the selected menu"
   set the loc of button "Auto Script" to 125,375
   set the loc of button "Auto Loc" to 125,395
   set the left of graphic id 4888 to 17
   set the left of button "New Button" of group "Menu Insert" to 13
   set the left of button "Menu Insertion Arrow" to 171
   
   pass preOpenStack
end preOpenStack

on openStack
   set the tooltip of button "Auto Script" to "Insert a framework menuPick handler for menuItems in the selected menu"
   set the loc of button "Auto Script" to 125,375
   #set the loc of button "Auto Loc" to 125,395
   set the left of graphic id 4888 to 17
   set the left of button "New Button" of group "Menu Insert" to 13
   set the left of button "Menu Insertion Arrow" to 162
end openStack

#########################################################
# into field "Menu Buttons"
#########################################################

on Buttons.mouseDown
   local tMouseLine
   if the text of me is not empty and the mouseLine is not empty then
      put word 2 of the mouseLine into tMouseLine
      set the cBroughtUpAnswerDialog of fld "Menu Name" to false
      revCheckNameChanged
      lock screen
      set the hilitedLine of me to tMouseLine
      mouseUp  --TL 11/22, fix to reposition orange line smoothly
      unlock screen
   end if
end Buttons.mouseDown

local lMenuNameHtml # so this will compile

on Buttons.mouseUp
   local tHilitedLine, tScroll
   global gREVActiveMenuButton
   
   if the cAnswerDialog of field "Menu Name" is not true \
         and the cAnswerDialog of field "Item Name" is not true then
      lock screen
      put the hilitedLine of me into tHilitedLine
      put the scroll of me into tScroll
      put revMenuLongID(line tHilitedLine of the cREVMenuButtonIds of this stack) into gREVActiveMenuButton
      --insertion widgets
      if tHilitedLine is not empty
      then set the top of grp "Menu Insert" to the item 2 of the selectedLoc of me + 6
      else set the top of grp "Menu Insert" to the top of fld "Menu Buttons" -6
      set the cREVLine of grp "Menu Insert" to tHilitedLine
      set the cREVLastWidgetLine of grp "Menu Insert" to empty
      
      if the text of me is empty then
         --no menus
         disable btn "Preview"
         put empty into btn "Preview"
         set the textFont of btn "Preview" to empty
         set the cREVLabel of btn "Preview" to empty
         disable btn "Delete Menu"
         put empty into fld "Menu Name"
         disable fld "Menu Name" 
         set the cREVDisabled of btn "Move Menu Up" to true
         set the cREVDisabled of btn "Move Menu Down" to true
         unhilite btn "Disable Menu"
         disable btn "Disable Menu"
         unhilite btn "Menu Mnemonic"
         disable btn "Menu Mnemonic"
         set the label of btn "Menu Mnemonic Letter" to space
         disable btn "Menu Mnemonic Letter"
         disable btn "Edit Script"
         disable btn "Auto Script"
         put empty into fld "Menu Items"
         revResetTriangles    
      else
         --menus exist
         enable btn "Preview"
         set the unicodeLabel of button "preview" to the unicodeText of gREVActiveMenuButton
         put the text of gREVActiveMenuButton into btn "Preview"
         --disable then enable grp to reliably enable everthing in it
         disable grp "Button Menus:"
         enable grp "Button Menus:"
         --disabling and enabling Button Menus here looses selection
         set the hilitedLine of me to tHilitedLine
         set the scroll of me to tScroll
         
         if tHilitedLine is 1 then set the cREVDisabled of btn "Move Menu Up" to true
         else set the cREVDisabled of btn "Move Menu Up" to false
         if tHilitedLine is the num of lines in me 
         then set the cREVDisabled of btn "Move Menu Down" to true
         else set the cREVDisabled of btn "Move Menu Down" to false
         
         --updating for selected menu button
         --if comma is in the effective textFont of gREVActiveMenuButton then 
         set the unicodeText of fld "Menu Name" to the unicodelabel of gREVActiveMenuButton
         disable btn "Menu Mnemonic"
         --set the textFont of btn "Preview" to the effective textFont of gREVActiveMenuButton
         --else 
         --set the htmlText of fld "Menu Name" to "<p>"& the label of gREVActiveMenuButton&"</p>"
         --enable btn "Menu Mnemonic"
         --set the textFont of btn "Preview" to empty
         --end if
         
         put the htmlText of fld "Menu Name" into lMenuNameHtml
         set the cREVLabel of btn "Preview" to the unicodeText of line tHilitedLine of me
         
         if the mnemonic of gREVActiveMenuButton is 0 or comma is in the effective textFont of gREVActiveMenuButton then 
            unhilite btn "Menu Mnemonic"
            set the label of btn "Menu Mnemonic Letter" to space
            disable btn "Menu Mnemonic Letter"
         else
            hilite btn "Menu Mnemonic"
            set the label of btn "Menu Mnemonic Letter" to char (the mnemonic of gREVActiveMenuButton) of the label of gREVActiveMenuButton
            enable btn "Menu Mnemonic Letter"
         end if
         set the hilite of btn "Disable Menu" to the disabled of gREVActiveMenuButton
         revGenerateItemsField
      end if
      
      revInitialiseForNoItemSelection
      revUpdateScrollbar
      set the thumbPosition of sb "Menu Items" to 0
      select line 1 of fld "Menu Items"  --TL 11/22, fix for no selection
      send "mouseUp" to fld "Menu Items"  --TL 11/22, fix to reposition orange line smoothly
      unlock screen
   end if
end Buttons.mouseUp

