script "Bugfix22798"

/*
* fix for bugzilla #
*
* more verbose description
*/

local sOriginalUpdateHandler
constant kHandler = "_CreateMobileScroller"  # the name of the handler to replace
constant kObject = "/Toolset/palettes/revdatagridlibrary/behaviorsdatagridbuttonbehavior.livecodescript" # object whose script contains the handler


command initializePlugin
    dispatch function "initializeHandler" to stack "PowerStrip" with kHandler, kObject, the name of me
    put the result into sOriginalUpdateHandler
end initializePlugin

command removePlugin
    dispatch "monkeyPatch" to stack "PowerStrip" with kObject, kHandler, sOriginalUpdateHandler
end removePlugin


# in order to replace a complete handler in kObject...

# Here's the corrected handler:

private command _CreateMobileScroller
   set the visible of scrollbar "dgScrollbar" of me to false
   set the visible of scrollbar "dgHScrollbar" of me to false
   if the dgProps["show vscrollbar"] of me is not false or \
         (_ControlType() is "table" and \
         the dgProps["show hscrollbar"] of me is not false) then
      if sScrollerId is empty or sScrollerId is not among the lines of mobileControls() then
         put the long id of me into sScrollerId
         mobileControlCreate "scroller", sScrollerId
      end if
      mobileControlSet sScrollerId, "canBounce", "true"
      mobileControlSet sScrollerId, "pagingEnabled", "false"
      mobileControlSet sScrollerId, "canScrollToTop", "true"
      mobileControlSet sScrollerId, "delayTouches", "true"
      mobileControlSet sScrollerId, "canCancelTouches", "true"
      __PollVisibility
   end if
end _CreateMobileScroller

