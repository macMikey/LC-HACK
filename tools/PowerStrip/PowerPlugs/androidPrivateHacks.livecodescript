script "androidPrivateHacks.livecodescript"

/*
* allow creating Android standalones
*
* Also remember to comment out line 1094 in stack revSaveAsAndroidStandalone
_internal deploy android tDeploy
*/

local sOriginalRemove
local sOriginalUpdateTabs
local sOriginalPlatforms

constant kHandler = "updateTabButtons"  # the name of the handler to replace
constant kHandler2 = "revSBRemoveUnlicensedTargetsFromSettings"  # the name of the handler to replace
constant kHandler3 = "revSBNoPlatforms"  # the name of the handler to replace
constant kObject = "stack revStandaloneSettingsBehavior" # object whose script contains the handler
constant kObject2 = "stack revSBLibrary" # object whose script contains the handler

command initializePlugin
    dispatch function "initializeHandler" to stack "PowerStrip" with kHandler, kObject, the name of me
    put the result into sOriginalUpdateTabs

    dispatch function "initializeHandler" to stack "PowerStrip" with kHandler2, kObject2, the name of me
    put the result into sOriginalRemove

    dispatch function "initializeHandler" to stack "PowerStrip" with kHandler3, kObject2, the name of me
    put the result into sOriginalPlatforms
end initializePlugin

command removePlugin
    dispatch "monkeyPatch" to stack "PowerStrip" with kObject, kHandler, sOriginalUpdateTabs
    dispatch "monkeyPatch" to stack "PowerStrip" with kObject2, kHandler2, sOriginalRemove
    dispatch "monkeyPatch" to stack "PowerStrip" with kObject2, kHandler3, sOriginalPlatforms
end removePlugin

# Here's the corrected handlers:

private command updateTabButtons pSettings
   local tEnableMacTick
   put false into tEnableMacTick
   repeat for each item tItem in "MacOSX,MacOSX PowerPC-32,MacOSX x86-32,MacOSX x86-64,MacOSX arm64"
      put tEnableMacTick or pSettings[tItem] into tEnableMacTick
   end repeat
   set the visible of button "OSXchecked" of group "checks" of me to tEnableMacTick
   
   set the visible of button "Windowschecked" of group "checks" of me to pSettings["Windows"] = true or \
         pSettings["Windows x86-64"] = true
   // SN-2015-01-13: [[ Bug 14373 ]] Check also if Linux 64 or Linux ARM are checked
   set the visible of button "UnixChecked" of group "checks" of me to pSettings["Linux"] = true \
         or pSettings["Linux x64"] = true \
         or pSettings["Linux ARMv6-HF"] = true
   set the visible of button "IosChecked" of group "checks" of me to pSettings["ios"] = true
   set the visible of button "AndroidChecked" of group "checks" of me to pSettings["android"] = true
   set the visible of button "BugsChecked" of group "checks" of me to pSettings["errorDialog"] = true
   set the visible of button "EmscriptenChecked" of group "checks" of me to pSettings["Emscripten"] = true
   
   repeat for each item tItem in "SolIntel,SolSparc,Iris,Odt,rs6000,Linux,Bsd,Hp9k700,SPARC"
      if pSettings[tItem] then
         set the visible of button "Unixchecked" of group "checks" of me to true
      end if 
   end repeat
   
   show button "Windows" of group "cards" of me
   show button "OS X" of group "cards" of me
   show button "Bug Reports" of group "cards" of me
   show button "Copy Files" of group "cards" of me
   show button "Unix" of group "cards" of me
   show button "iOS" of group "cards" of me
   show button "Emscripten" of group "cards" of me
   
   local tLeft
   put 0 into tLeft
   
   local tV
   put item 2 of the loc of button "OS X" of group "cards" of me -10 into tV
   repeat for each item tItem in kButtonList
      if the visible of button tItem of group "cards" of me then
         set the left of button tItem of group "cards" of me to tLeft
         put the right of button tItem of group "cards" of me into tLeft
      end if
      
      local tCheck
      put replaceText(tItem," ","")&"checked" into tCheck
      if there is a button tCheck of group "checks" of me then
         local tTopLeft
         put (item 1 of the loc of button tItem of group "cards" of me),tV into tTopLeft
         set the topLeft of button tCheck of group "checks" of me to tTopLeft
      end if
   end repeat
   
   set the wholeMatches to true
   set the enabled of button "OS X" of group "cards" of me to ("Mac OS X" is among the items of line 5 of the revLicenseInfo)
   set the enabled of button "Windows" of group "cards" of me to ("Windows" is among the items of line 5 of the revLicenseInfo)
   set the enabled of button "Unix" of group "cards" of me to ("Linux" is among the items of line 5 of the revLicenseInfo)
   set the enabled of button "iOS" of group "cards" of me to ("iOS" is among the items of line 5 of the revLicenseInfo)
   --set the enabled of button "Android" of group "cards" of me to ("Android" is among the items of line 5 of the revLicenseInfo)
   --set the enabled of button "Emscripten" of group "cards" of me to ("HTML5" is among the items of line 5 of the revLicenseInfo)
   set the enabled of button "Android" of group "cards" of me to true
   set the enabled of button "Emscripten" of group "cards" of me to true
end updateTabButtons

function revSBRemoveUnlicensedTargetsFromSettings @xSettingsA
   -- don't build for any platform we are not licensed for
   local tRemoved
#   repeat for each item tTarget in kDesktopTargets, kAdditionalTargets
#      if xSettingsA[tTarget] then
#         if not revSBLicensedToDeployToTarget(tTarget) then
#            put false into xSettingsA[tTarget]
#            put true into tRemoved[tTarget]
#         end if
#      end if
#   end repeat
   return the keys of tRemoved
end revSBRemoveUnlicensedTargetsFromSettings

function revSBNoPlatforms pSettings
#   repeat for each item tTarget in kDesktopTargets, kAdditionalTargets
#      if pSettings[tTarget] then
#         return false
#      end if
#   end repeat
   
   return false
end revSBNoPlatforms


