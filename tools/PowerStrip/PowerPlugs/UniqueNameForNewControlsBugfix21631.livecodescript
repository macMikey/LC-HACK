script "UniqueNameForNewControlsBugfix21631.livecodescript"

/*
* fix for bugzilla #21631
*
* Allow each new control to have a unique name
*/

local sOriginalHandler
constant kHandler = "revIDECreateObject"  # the name of the handler to replace
constant kObject = "stack revIDELibrary" # object whose script contains the handler

command initializePlugin
    dispatch function "initializeHandler" to stack "PowerStrip" with kHandler, kObject, the name of me
    put the result into sOriginalHandler
end initializePlugin

command removePlugin
    dispatch "monkeyPatch" to stack "PowerStrip" with kObject, kHandler, sOriginalHandler
end removePlugin

# Here's the corrected handler:
on revIDECreateObject pObjectTypeID, pTarget, pLoc
   if not __objectTypeIsControl(pObjectTypeID) then
      return __revIDEError("Object must be a control")
   end if
   
   if not exists(pTarget) then return __revIDEError("Cannot create object. Target does not exist: " && pTarget)
   if not pObjectTypeID begins with "com.livecode" then return __revIDEError("No such object type ID: " && pTarget)
   
   if sClassicObjectProperties is empty then __objectPropertiesRead
   # Set the default stack to the target we're creating the object on
   set the defaultstack to revIDEStackOfObject(pTarget)
   
   if pLoc is empty then
      put the loc of this card of the defaultStack into pLoc
   end if
   
   # Create the object
   lock screen
   lock messages
   
   local tPropInfoA, tObjPropsA
   # Get the engine control type
   if pObjectTypeID begins with "com.livecode.interface.classic" then
      local tCreatedControlID
      # Create data grid
      if pObjectTypeID begins with "com.livecode.interface.classic.DataGrid" then
         -- data grid library expects a rect rather than a loc
         local tCreateRect
         put round(the cTabButtonWidth of stack "revPreferences" / 2), round(the cTabButtonHeight of stack "revPreferences" / 2) into tCreateRect
         put item 1 of tCreateRect + the cTabButtonWidth of stack "revPreferences" into item 3 of tCreateRect
         put item 2 of tCreateRect + the cTabButtonHeight of stack "revPreferences" into item 4 of tCreateRect
         
         local lDataGrid
         put true into lDataGrid -- select data grid at end not single control
         
         unlock messages
         # tObjectId is passed by reference and will have the data grid group id placed into it
         addDataGridToStack the short name of this stack, tCreateRect, empty, empty, tCreatedControlID
         local tCount
         put 0 into tCount
         repeat with i = 1 to the number of groups
            if the dgProps["control type"] of group i is "Data Grid" then
               add 1 to tCount
            end if
         end repeat
         set the name of tCreatedControlID to (the short name of tCreatedControlID && tCount)
         lock messages
      else
         local tObjectType
         put sClassicObjectProperties[pObjectTypeID]["type"] into tObjectType
         
         if tObjectType is empty then return __revIDEError("Invalid classic control type ID: " && pTarget)
         
         # A classic control
         do "create" && tObjectType
         put the long ID of the last control into tCreatedControlID
      end if
      
      put sClassicObjectProperties[pObjectTypeID]["properties"] into tObjPropsA
   else
      # Not a classic control
      try
         if pObjectTypeID is "com.livecode.widget.native.map" and the platform is "MacOS" and (revIDEPlatformVersion() begins with "10.9" or revIDEPlatformVersion() begins with "10.10") then
            local tMessage
            put "The Mac MapKit API is supported from OS X 10.9 onwards, but Apple restricts use of the API on 10.9 and 10.10 to apps which are distributed from the Mac AppStore with an appropriate entitlement. " & \
                  "Due to this, general use of the Map widget only supports OS X 10.11 onwards. " & CR & CR & \  
                  "However, you can still create a standalone with the Map widget on OSX 10.9 or 10.10 (of course you will see an empty grid rather than the actual map), " & \
                  " BUT this standalone will run as expected on OSX 10.11 and above." into tMessage
            
            answer warning revIDELocalise(tMessage) with "Cancel" and "Continue"
            if it is "Cancel" then exit revIDECreateObject
         end if
         
         create widget as pObjectTypeID
         put the long id of the last control into tCreatedControlID
         
         put revIDEExtensionProperties(pObjectTypeID, false) into tObjPropsA
         union tObjPropsA with sClassicObjectProperties["com.livecode.interface.classic.widget"]["properties"]
         
         local tSize
         put revIDEExtensionProperty(pObjectTypeID, "preferredsize") into tSize
         if tSize is not empty then
            put item 1 of tSize into tObjPropsA["width"]["default"]
            put item 2 of tSize into tObjPropsA["height"]["default"]
         end if
      catch tError
         return false
      end try
   end if
   
   __setPropertiesToDefaults tCreatedControlID, tObjPropsA
   
   ## Set the size of the object to the size set in the Preferences
   __setSizeToPreference tCreatedControlID, pObjectTypeID
   
# start of added section
   local tObjectNumber, tObjectName
   set the itemDelimiter to "."
   put 1 into tObjectNumber
   put item -1 of tObjectType & tObjectNumber into tObjectName
   repeat while there is a control tObjectName
      add 1 to tObjectNumber
      put item -1 of tObjectType & tObjectNumber into tObjectName
   end repeat
   set the name of the last control to tObjectName
#end of added section
   
   set the loc of tCreatedControlID to pLoc
   
   unlock messages
   unlock screen
   
   ## Prevent passing of ideNewControl message for objects created on IDE stacks
   if revIDEObjectIsOnIDEStack(tCreatedControlID) is false then
      // AL-2015-04-08: [[ Bug 14822 ]] Ensure 'edited' status of stack is set
      revIDESetEdited the short name of this stack
      ideMessageSend "ideNewControl", tCreatedControlID
   end if
   
   return tCreatedControlID
end revIDECreateObject

