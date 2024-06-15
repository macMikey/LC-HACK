script "navigationArrowsStandaloneFalse"

/*
* https://forums.livecode.com/viewtopic.php?f=7&t=37821&start=15
*
* The navigationArrows global property shouldn't always default to true
*/

local sOriginalHandler
constant kHandler = "revSBGetSettings"  # the name of the handler to replace
constant kObject = "stack revSBLibrary" # object whose script contains the handler

command initializePlugin
    dispatch function "initializeHandler" to stack "PowerStrip" with kHandler, kObject, the name of me
    put the result into sOriginalHandler
end initializePlugin

command removePlugin
    dispatch "monkeyPatch" to stack "PowerStrip" with kObject, kHandler, sOriginalHandler
end removePlugin

# Here's the corrected handler:

function revSBGetSettings pStack, pDeploy
   local tSettingsA
   put the customProperties["cRevStandaloneSettings"] of stack \
         (the mainstack of stack pStack) into tSettingsA
   
   # Set empty values to defaults
   revSBDefaultStandaloneSettings pStack, tSettingsA

# get the current state of the navigationArrows
put the navigationArrows into tSettingsA["navigationArrows"]
   
   if pDeploy then
      local tKey, tInclusion
      repeat for each key tKey in sDeployInclusions
         repeat for each key tInclusion in sDeployInclusions[tKey]
            revSBAddInclusion tInclusion, tKey, tSettingsA
         end repeat
      end repeat
   end if
   
   # set library requirements
   local tLibraries
   put __AvailableScriptLibraries() into tLibraries
   repeat for each element tLibrary in tLibraries
      if tLibrary["title"] is among the lines of tSettingsA["scriptLibraries"] then
         union tLibrary["settings"] with tSettingsA recursively
         put tLibrary["settings"] into tSettingsA
      end if
   end repeat
   
   return tSettingsA
end revSBGetSettings

