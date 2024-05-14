script "Bugfix22211LockCursor.livecodescript"

/*
* fix for bug #22211
Toolset/libraries/revbackscriptlibrary.livecodescript
*/

local sOriginalHandler
constant kHandler = "ideMouseMove"  # the name of the handler to replace
constant kObject = "stack revbackscriptlibrary" # object whose script contains the handler

command removePlugin
    dispatch "monkeyPatch" to stack "PowerStrip" with kObject, kHandler, sOriginalHandler
end removePlugin

# Here's the corrected handler:
command initializePlugin
    dispatch function "initializeHandler" to stack "PowerStrip" with kHandler, kObject, the name of me
    put the result into sOriginalHandler
end initializePlugin

on ideMouseMove pX, pY, pTarget
   if the tool is not "pointer tool" then exit ideMouseMove

   local tOldCursor
   if the lockcursor then
      put the cursor into tOldCursor
   end if

   if pTarget is among the lines of the selectedObjects and not (the lockLoc of pTarget)  then
      local tRect
      put the rect of pTarget into tRect
      local tLeft = false
      local tTop = false
      local tRight = false
      local tBottom = false
      local tCenterY = false
      local tCenterX = false
      local tHandleOffset
      
      if pX < item 1 of tRect + kHandleSize then
         put true into tLeft
      else if pX > item 3 of tRect - kHandleSize then
         put true into tRight
      else
         put (the width of pTarget - kHandleSize) / 2 into tHandleOffset
         if pX >= item 1 of tRect + tHandleOffset \
               and pX <= item 3 of tRect - tHandleOffset then
            put true into tCenterX
         end if
      end if
      
      if pY < item 2 of tRect + kHandleSize then
         put true into tTop
      else if pY > item 4 of tRect - kHandleSize then
         put true into tBottom
      else
         put (the height of pTarget - kHandleSize) / 2 into tHandleOffset
         if pY >= item 2 of tRect + tHandleOffset \
               and pY <= item 4 of tRect - tHandleOffset then
            put true into tCenterY
         end if
      end if
      
      lock cursor
      if (tLeft and tTop) or (tRight and tBottom) then
         -- resize topLeft to bottomRight cursor
         set the cursor to 83
      else if (tLeft and tBottom) or (tRight and tTop) then
         -- resize bottomLeft to topRight cursor
         set the cursor to 84
      else if (tLeft and tCenterY) or (tRight and tCenterY) then
         -- horizontal resize cursor
         set the cursor to 31
      else if (tTop and tCenterX) or (tBottom and tCenterX) then
         -- vertical resize cursor
         set the cursor to 30
      else
         unlock cursor
      end if
   else
      if tOldCursor is not empty and tOldCursor is not among the items of "83,84,31,30" then
         set the cursor to tOldCursor
      else
         unlock cursor
      end if
   end if
end ideMouseMove
