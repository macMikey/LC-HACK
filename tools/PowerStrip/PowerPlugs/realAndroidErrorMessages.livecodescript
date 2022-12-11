script "realAndroidErrorMessages.livecodescript"

/*
* Return real error messages when configuring Android sdk and jdk
*/

local sOriginalHandlerArray
constant kHandlers = "deployGetVersionsMap,deployIsValidJDK,deployIsValidSDK,deployAutoconfigure"
constant kConstant1 = "constant kDeployAndroidTargetSDK"
constant kObject = "stack revdeploylibraryandroid" # object whose script contains the handlers

command initializePlugin
   local tText # the text of the replacement handler
   repeat for each item tPatch in kHandlers
      dispatch function "originalPlugPatch" to stack "PowerStrip" with kObject, tPatch
      put the result into sOriginalHandlerArray[tPatch]
      
      dispatch function "originalPlugPatch" to stack "PowerStrip" with me, tPatch
      put the result into tText
      dispatch "monkeyPatch" to stack "PowerStrip" with  kObject, tPatch, tText
   end repeat
   
   #   put the script of kObject into tText
   #   local tPosition, tTargetVersion
   #   put lineoffset ("constant kDeployAndroidTargetSDK", tText) into tPosition
   #   filter tText with "constant kDeployAndroidTargetSDK*" into tTargetVersion
   #   local tTarget
   #   put word -1 of line 1 of tTargetVersion into tTarget
   #   if tTarget < 30 then
   #      breakpoint
   #      put "constant kDeployAndroidTargetSDK =" && q(31) into line tPosition of tText
   #      dispatch "setScriptOf" to stack "PowerStrip" with kObject, tText
   #   end if
   dispatch "replaceConstant" to stack "PowerStrip" with kObject, kConstant1, 30, 31
end initializePlugin

#command replaceConstant pObject, pConstantDeclaration, pOldValue, pNewValue
#   local tText
#   local tPosition, tTargetVersion

#   put the script of pObject into tText
#   put lineoffset (pConstantDeclaration, tText) into tPosition
#   filter tText with pConstantDeclaration&"*" into tTargetVersion
#   --if word -1 of tTargetVersion is not pOldValue then
#   if shouldReplace?(word -1 of tTargetVersion, pOldValue) then
#      put pConstantDeclaration && "=" && q(pNewValue) into line tPosition of tText
#      dispatch "setScriptOf" to stack "PowerStrip" with pObject, tText
#   end if
#end replaceConstant

#function shouldReplace? pOldValue, pNewValue
#   local tShouldReplace?

#   put false into tShouldReplace?
#   if pOldValue is a number then
#      if pNewValue > pOldValue then
#         put true into tShouldReplace?
#      end if
#   else
#      if pOldValue is not pNewValue then
#         put true into tShouldReplace?
#      end if
#   end if
#   return tShouldReplace?
#end shouldReplace?


command removePlugin
    repeat for each key tPatch in sOriginalHandlerArray
        dispatch "monkeyPatch" to stack "PowerStrip" with kObject, tPatch, sOriginalHandlerArray[tPatch]
    end repeat
end removePlugin

# have to do this manually:
# make sure the target SDK is *at least* 30
constant kDeployAndroidTargetSDK = "30" # mdw 2022.04.20

function deployGetVersionsMap
   local tMap
   put "5.0 - Lollipop" into tMap[21]
   put "5.1" into tMap[22]
   put "6.0 - Marshmallow" into tMap[23]
   put "7.0 - Nougat" into tMap[24]
   put "7.1" into tMap[25]
   put "8.0 - Oreo" into tMap[26]
   put "8.1" into tMap[27]
   put "9.0 - Pie" into tMap[28]
   put "10 - Q" into tMap[29]
   put "11 - R" into tMap[30]
   put "12 - API 31" into tMap[31]
   return tMap
end deployGetVersionsMap

function deployIsValidJDK pPath
   if there is no folder pPath then
      return "could not find registered jdk at" && pPath
   end if
   
   if there is no file pathToJavaC(pPath) then
      return "missing javac tool, make sure your JDK install has not become corrupted"
   end if
   
   // newer versions of SDK Tools require Java 8
   if pathToSDKClasses() contains "sdklib-" and not pPath contains "jdk1.8" then
      return "The version of Java installed in your system is not compatible with the current version of Android SDK Tools. Please install Java 8 to continue."
   end if
   
   return empty
end deployIsValidJDK

function deployIsValidSDK pPath 
   if there is no folder (pPath & slash & "platforms") or \
         there is no folder (pPath & slash & "platform-tools") or \
         there is no folder (pPath & slash & "tools") then
      return "could not find platforms, platform-tools or tools folders at that path."
   end if
   
   if there is no folder pathToRootPlatform(pPath) then
      return "could not find install of required target SDK, make sure it has been installed with the Android SDK Manager"
   end if
   
   if there is no file pathToRootClasses(pPath) then
      return "missing root classes, make sure your SDK install has not become corrupted"
   end if
   
   if there is no file pathToAapt(pPath) then
      return "missing aapt tool, make sure your SDK install has not become corrupted"
   end if
   
   if there is no file pathToAdb(pPath) then
      return "missing adb tool, make sure your SDK install has not become corrupted"
   end if
   
   if there is no file pathToSDKClasses(pPath) then
      return "missing sdklib.jar, make sure your SDK install has not become corrupted"
   end if
   
   if there is no file pathToZipAlign(pPath) then
      return "missing zipalign tool, make sure your SDK install has not become corrupted"
   end if
   
   if there is no file pathToD8(pPath) then
      return "missing d8 tool, make sure your SDK install has not become corrupted"
   end if
   
   return empty
end deployIsValidSDK

local sAndroidRoot, sJavaRoot # ignore these. they're just there to allow compilation
command deployAutoconfigure
   local tSDK
   put the cMobileSupport["android.sdk"] of stack "revPreferences" into tSDK
   if tSDK is not empty and deployIsValidSDK(tSDK) is not empty then
      put empty into tSDK
   end if
   set the cMobileSupport["android.sdk"] of stack "revPreferences" to tSDK
   put tSDK into sAndroidRoot
   
   if sAndroidRoot is not empty then
      local tJDK
      put the cMobileSupport["android.jdk"] of stack "revPreferences" into tJDK
      if tJDK is empty or deployIsValidJDK(tJDK) is not empty then
         deployAutoconfigureJDK
         put the result into tJDK
      end if
      if tJDK is not empty then
         set the cMobileSupport["android.jdk"] of stack "revPreferences" to tJDK
         put tJDK into sJavaRoot
      end if
   end if
end deployAutoconfigure

