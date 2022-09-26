script "revResetAll.livecodescript"

/*
* The resetAll command doesn't really close all sockets.
* fix for bugzilla #23399
*/

local sOriginalHandler
constant kHandler = "libUrlResetAll"  # the name of the handler to replace
constant kObject = "stack revLibUrl" # object whose script contains the handler

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

on libUrlResetAll
  local i
  
  -- CW-2016-06-11: [[ External driver support ]] Call driver specific reset command if external driver is in use.
  if lvExtDriver is not empty then
    ulDeleteLocals
    ulExtResetDriver
  else
    # if there is a stack "libUrl" then put empty into fld "log1" of stack "libURL"
    repeat for each line i in the openSockets
      close socket i
    end repeat
    
    ulDeleteLocals
    put true into lvJumpOut
    send "ulDeleteLocals" to me in 5 milliseconds
  end if
end libUrlResetAll

