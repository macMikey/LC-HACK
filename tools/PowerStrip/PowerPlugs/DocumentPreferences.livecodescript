script "DocumentPreferences"

/*
* Pull Request #
*
* from Monte: start documenting preferences
*/

local sOriginalUpdateHandler

constant kHandler = "revIDESetPreference"  # the name of the handler to replace
constant kObject = "stack revidelibrary" # object whose script contains the handler

command initializePlugin
    dispatch function "initializeHandler" to stack "PowerStrip" with kHandler, kObject, the name of me
    put the result into sOriginalUpdateHandler
end initializePlugin

command removePlugin
    dispatch "monkeyPatch" to stack "PowerStrip" with kObject, kHandler, sOriginalUpdateHandler
end removePlugin


# Here's the corrected handler:

/*
pPreferenceName (enum):

- cImageFileRelative (boolean): If false set image paths to absolute 
paths rather than relative to
the stack
- cREVExtension (boolean): If false force extensions to be added during 
save
- cDestroyStack (boolean): The default value for destroyStack on new 
stacks
- cAskDestroy (enum): What to do when a stack with destroyStack true 
is closed

   - "don't remove": Don't remove from memory
   - "remove": remove from memory
   - "ask": ask the user

- cNumRecent (integer): The number of recent files to show in the menu 
and start center
- cRecentSort (enum): The sort order of recent files

    - "alphabetically": Sort by file name
    - "modification date": Sort by date

- cRecentStackPaths (string): A list of recent stack file paths
- cPreserveStackCreator (boolean): *LEGACY* If true preserve the MacOS 
file creator     
- cPreserveStackVersion (boolean): If true save the file with the 
original stack file version
- cCustomizationPath (string): The path to the user customization 
directory
*/

/*
Sets a preference.

pPreferenceName (String): The name of the preference to set
pValue (Any): The value to set the preference to
tags: preferences
Example: set revIDEGetPreference("text size") to 12
Returns (Any): The value of the preference
*/
on revIDESetPreference pPreferenceName, pValue
   if the pPreferenceName of stack "revpreferences" is not pValue then
      set the pPreferenceName of stack "revpreferences" to pValue
      revInternal__SavePreferences
      ideMessageSend "idePreferenceChanged:" & pPreferenceName,pValue
   end if
end revIDESetPreference

