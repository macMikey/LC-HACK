script "localizeAskDialogButtons"

/*
* partially fixes bug 21006
* per request by Klaus Major
*/

local sOriginalHandler
constant kHandler = "openStack"  # the name of the handler to replace
constant kObject = "/Toolset/palettes/revaskdialog.livecode" # object whose script contains the handler

on openStack
   localizeOKButtonTo "Abbrechen"
   localizeCancelButtonTo "Never mind"
end openStack

private command localizeOKButtonTo pText
   local tLength
   
   set the label of button "OK" to pText
   put measureText(pText, button "OK") into tLength
   set the width of button "OK" to tLength + 20
end localizeOKButtonTo

private command localizeCancelButtonTo pText
   local tLength
   
   set the label of button "Cancel" to pText
   put measureText(pText, button "Cancel") into tLength
   set the width of button "Cancel" to tLength + 20
end localizeCancelButtonTo

