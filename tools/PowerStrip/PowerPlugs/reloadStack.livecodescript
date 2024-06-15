script "ReloadStack"

global gREVSuppressMessages

/*
* reloadStack replacement
* this patch provides an escape mechanism for bug #1061
*
* when the IDE attempts to load two stacks into memory with the same short name
* this allows you to rename the stack in memory and continue loading
* the second stack with the conflicting name
*
* there is no initializePlugin handler here
* so this script becomes a frontscript by default
*/
on reloadStack pStackName, pFileName
   if the filename of stack pStackName is pFileName then
      toplevel pStackName
   else
      set the defaultStack to pStackName
      
      local tFilePath, tFileLongPath
      put the effective fileName of stack pStackName into tFilePath
      put tFilePath into tFileLongPath
      if tFileLongPath is empty then
         put pStackName into tFileLongPath
         put comma && pStackName & "?" after tFilePath
      else
         put pStackName & "?" into tFilepath
      end if
      answer warning "A stack with the name"&&pStackName&&"is already open." & \
            cr & "Before loading" && pFileName & ", what do you want to do with stack:" & \
            cr & tFilePath with "Rename" or "Save" or "Purge" or "Cancel"
      local tAction
      put it into tAction
      if gREVSuppressMessages then
         lock messages
         send "revInsertMessageBlock" to me in 100 milliseconds
         revInternal__UnloadLibrary "revNoMessagesLibrary"
      end if
      
      local tLockMessages
      put the lockMessages into tLockMessages
      
      switch tAction
         case "Cancel"
            exit to top
         case "Rename"
            ask "Enter a name for the stack in memory"
            if it is not empty and it is not pStackName then
               set the name of stack tFileLongPath to it
               go stack pFileName
            else
               exit to top
            end if
            break
         case "Save"
            if the filename of stack pStackName is empty then
               revSaveAs pStackName
            else
               revSave pStackName
            end if
         case "Purge"
            revAOUpdateForDeleteStack pStackName
            lock messages
            delete stack pStackName
            set the lockMessages to tLockMessages
            go stack pFileName
            break
      end switch
   end if
   
   if there is a stack "revApplicationOverview" then
      send "revNewStack the short name of stack pFileName" to stack "revApplicationOverview"
   end if
end reloadStack


