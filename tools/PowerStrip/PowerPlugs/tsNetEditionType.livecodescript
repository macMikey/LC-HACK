script "tsNetEditionType.livecodescript"

/*
* Ensure non-blocking tsNet calls
*/

local sOriginalHandler
constant kHandler = "ulExtIsBlocked"  # the name of the handler to replace
constant kObject = "stack tsNetLibUrl"

command initializePlugin
    dispatch function "initializeHandler" to stack "PowerStrip" with kHandler, kObject, the name of me
    put the result into sOriginalAutoconfigure
end initializePlugin

command removePlugin
    send "restorePatch stack tsNetLibUrl, kHandler, sOriginalHandler" to stack "PowerStrip" in 0 milliseconds
end removePlugin

# Here's the replacement function:

function ulExtIsBlocked
   if the editionType is "commercial" then
      return false
   else
      return tsNetIsSyncBlocked()
   end if
end ulExtIsBlocked

