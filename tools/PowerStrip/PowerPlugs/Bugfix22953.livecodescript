script "Bugfix22953.livecodescript"

/*
* fix for bugzilla #
*
* more verbose description
*/

local sOriginalRemove
local sOriginalUpdateHandler
local sOriginalPlatform

# could have multiple handlers and objects here
# if necessary for a complete patch
# otherwise just need one of these

constant kHandler = "resizeStack"  # the name of the handler to replace
constant kObject = "stack revExtensionBuilderBehavior" # object whose script contains the handler

command initializePlugin
    dispatch function "initializeHandler" to stack "PowerStrip" with kHandler, kObject, the name of me
    put the result into sOriginalUpdateHandler
end initializePlugin

command removePlugin
    dispatch "monkeyPatch" to stack "PowerStrip" with kObject, kHandler, sOriginalUpdateHandler
end removePlugin

# in order to replace a complete handler in kObject...

# Here's the corrected handlers:

on resizeStack
   local tRect, tMargin, tPadding
   put the contentrect of me into tRect
   put the paletteMargin of me * 2 into tMargin
   put the palettePadding of me * 2 into tPadding
   
   lock messages
   lock screen
   
   
   local tLeft, tTop, tRight, tBottom
   put item 4 of tRect - tMargin into tBottom
   put item 3 of tRect - tMargin into tRight
   
   # Extensions
   local tLabelWidth
   put the width of me * 0.25 into tLabelWidth
   put item 1 of tRect + tMargin into tLeft
   put item 2 of tRect + tMargin into tTop
   set the width of field "label_extensions" of me to tLabelWidth
   set the topleft of field "label_extensions" of me to tLeft,tTop
   put the right of field "label_extensions" of me + tPadding into tLeft
   set the rect of button "extensions" of me to tLeft, tTop, item 3 of tRect-tMargin, tTop + 22
   set the rect of button "extensions2" of me to tLeft, tTop, item 3 of tRect-tMargin, tTop + 22
   put the bottom of button "extensions" of me+tPadding into tTop
   
   # Icons
   put item 1 of tRect + tMargin into tLeft
   set the width of field "label_icons" of me to tLabelWidth
   set the topleft of field "label_icons" of me to tLeft,tTop
   put the right of field "label_icons" of me + tPadding into tLeft
   set the topleft of image "icon_retina" of me to tLeft,tTop
   put the right of image "icon_retina" of me + tPadding into tLeft
   set the topleft of image "icon" of me to tLeft,tTop

   put the right of image "icon" of me + tPadding into tLeft
   set the topLeft of field "label_svgicon_absent" to tLeft, tTop
   set the topLeft of widget "svgicon_retina" of me to tLeft, tTop
   put the right of widget "svgicon_retina" of me into tLeft
   set the topLeft of widget "svgicon" of me to tLeft, tTop

   # Resources
   put item 1 of tRect + tMargin into tLeft
   put item 3 of tRect - tMargin into tRight
@@ -446,15 +451,15 @@ on resizeStack
   set the width of field "label_api" of me to tLabelWidth
   set the topleft of field "label_api" of me to tLeft,tTop
   put the right of field "label_api" of me + tPadding into tLeft
   set the rect of field "message_api" of me to tLeft, tTop, tRight, tTop+the formattedheight of field "message_api" of me  -  the margins of field "message_api" of me
   set the rect of field "message_api" of me to tLeft, tTop, tRight, tTop+the formattedheight of field "message_api" of me  -  (the margins of field "message_api" of me / 2)

   # Guide
   put item 1 of tRect + tMargin into tLeft
   put the bottom of field "message_api" of me + tPadding into tTop
   set the width of field "label_guide" of me to tLabelWidth
   set the topleft of field "label_guide" of me to tLeft,tTop
   put the right of field "label_guide" of me + tPadding into tLeft
   set the rect of field "message_guide" of me to tLeft, tTop, tRight, tTop+the formattedheight of field "message_guide" of me -  the margins of field "message_guide" of me
   set the rect of field "message_guide" of me to tLeft, tTop, tRight, tTop+the formattedheight of field "message_guide" of me -  (the margins of field "message_guide" of me / 2)

   # Console
   put item 1 of tRect + tMargin into tLeft
   put the bottom of field "message_guide" of me + 2 * tPadding into tTop
   put item 3 of tRect - tMargin into tRight
   set the topleft of field "label_console" of me to tLeft, tTop
   
   put the bottom of field "label_console" of me + tPadding into tTop
   set the rect of field "console" of me to tLeft, tTop, tRight, tBottom
   consoleScrollbarUpdate
   
   unlock screen
   unlock messages
   
   pass resizeStack
end resizeStack

