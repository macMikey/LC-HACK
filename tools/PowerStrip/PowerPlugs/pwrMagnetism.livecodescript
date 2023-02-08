script "pwrMagnetism.livecodescript"

/**
* pwrMagnetism
*
* Provides a mechanism for stacks to dock to each other
*/

local sDockedArray
local sMyName

on moveStack
   dockToAny
   --dockto "revMenuBar", 20
   pass moveStack
end moveStack

command dockToAny
   local tStacks
   
   put the openstacks into tStacks
   repeat for each line tStack in tStacks
      if the visible of stack tStack then
         dockTo tStack, 50
      end if
   end repeat
end dockToAny

private function magneticMe
   return the name of stack the mainstack of me
end magneticMe

command keepDockedTo pTarget
   if isDocked?(magneticMe()) then
      switch sDockedArray[the mousestack]["DockType"]
         case "left"
            set the right of this stack to the left of stack pTarget
            break
         case "right"
            set the left of this stack to the right of stack pTarget
            break
      end switch
      set the top of this stack to the top of stack pTarget
   end if
end keepDockedTo

private command dockTo pTarget, pDistance
   local tStackName
   
   if pDistance is empty then
      put 20 into pDistance
   end if
   put magneticMe() into tStackName
   if isWithinVertical?(pTarget, pDistance) then
      if isDockableLeft?(pTarget, pDistance) then
         set the top of stack tStackName to the top of stack pTarget
         set the right of stack tStackName to the left of stack pTarget
         dock tStackName, true
         put pTarget into sDockedArray[tStackName]["DockTarget"]
         put "left" into sDockedArray[tStackName]["DockType"]
      else if isDockableRight?(pTarget, pDistance) then
         set the top of stack tStackName to the top of stack pTarget
         set the left of stack tStackName to the right of stack pTarget
         dock tStackName, true
         put pTarget into sDockedArray[tStackName]["DockTarget"]
         put "right" into sDockedArray[tStackName]["DockType"]
      else
         dock tStackName, false
      end if
   else
      if isWithinHorizontal?(pTarget, pDistance) then
         if isDockableBottom?(pTarget, pDistance) then
            set the top of stack tStackName to the bottom of stack pTarget
         end if
      else
         dock tStackName, false
      end if
   end if
end dockTo

private command dock pStackName, pDock
   put pDock into sDockedArray[pStackName]["isDocked"]
end dock
   
private function isDocked? pStackName
   return sDockedArray[pStackName]["isDocked"]
end isDocked?

/**
* isWithinVertical?
* function
*  pTarget : stack we want to dock to
*  pDistance : nearness
* returns
*  boolean : is near enough to dock?
*/
private function isWithinVertical? pTarget, pDistance
   return (item 2 of the screenmouseLoc < (the bottom of stack pTarget + pDistance)) \
         and (item 2 of the screenmouseLoc > (the top of stack pTarget - pDistance))
end isWithinVertical?

/**
* isWithinHorizontal?
* function
*  pTarget : stack we want to dock to
*  pDistance : nearness
* returns
*  boolean : is near enough to dock?
*/
private function isWithinHorizontal? pTarget, pDistance
   return (item 1 of the screenmouseLoc < (the right of stack pTarget + pDistance)) \
         and (item 1 of the screenmouseLoc > (the left of stack pTarget - pDistance))
end isWithinHorizontal?

private function isDockableLeft? pTarget, pDistance
   return isWithinDockableDistance?(the right of this stack, the left of stack pTarget, pDistance)
end isDockableLeft?

private function isDockableRight? pTarget, pDistance
   return isWithinDockableDistance?(the left of this stack, the right of stack pTarget, pDistance)
end isDockableRight?

private function isDockableTop? pTarget, pDistance
   return isWithinDockableDistance?(the bottom of this stack, the top of stack pTarget, pDistance)
end isDockableTop?

private function isDockableBottom? pTarget, pDistance
   return isWithinDockableDistance?(the top of this stack, the bottom of stack pTarget, pDistance)
end isDockableBottom?

private function isWithinDockableDistance? pDockableStackLocation, pTargetStackLocation, pDistance
   return (pDockableStackLocation < (pTargetStackLocation + pDistance)) \
         and (pDockableStackLocation > (pTargetStackLocation - pDistance))
end isWithinDockableDistance?

