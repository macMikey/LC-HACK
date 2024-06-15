script "androidConfigurationHacks"

/*
* provide actual error messages when attempting to create Android standalones
*/

local sOriginalAutoconfigure
local sOriginalSDKValid
local sOriginalSaveAs

constant kHandler = "deployAutoconfigure"  # the name of the handler to replace
constant kIsValidSDK = "deployIsValidSDK"  # may already be updated in later versions
constant kSaveAs = "revSaveAsMobileStandalone"  # may already be updated in later versions
constant kObject = "stack revDeployLibraryAndroid" # object whose script contains the handler
constant kObject2 = "stack revSaveAsAndroidStandalone" # object whose script contains the handler

command initializePlugin
    dispatch function "initializeHandler" to stack "PowerStrip" with kHandler, kObject, the name of me
    put the result into sOriginalAutoconfigure

    dispatch function "initializeHandler" to stack "PowerStrip" with kIsValidSDK, kObject, the name of me
    put the result into sOriginalSDKValid

    dispatch function "initializeHandler" to stack "PowerStrip" with kSaveAs, kObject2, the name of me
    put the result into sOriginalSaveAs
end initializePlugin

command removePlugin
    dispatch "monkeyPatch" to stack "PowerStrip" with kObject, kHandler, sOriginalAutoconfigure
    dispatch "monkeyPatch" to stack "PowerStrip" with kObject, kIsValidSDK, sOriginalSDKValid
    dispatch "monkeyPatch" to stack "PowerStrip" with kObject2, kSaveAs, sOriginalSaveAs
end removePlugin

# Here are the corrected handlers:
local sAndroidRoot # so the following will compile properly
local sJavaRoot

command deployAutoconfigure
   local tSDK
   put the cMobileSupport["android.sdk"] of stack "revPreferences" into tSDK
   if tSDK is not empty and deployIsValidSDK(tSDK) is not empty then # mdw 2022.04.11
      put empty into tSDK
   end if
   set the cMobileSupport["android.sdk"] of stack "revPreferences" to tSDK
   put tSDK into sAndroidRoot
   
   if sAndroidRoot is not empty then
      local tJDK
      put the cMobileSupport["android.jdk"] of stack "revPreferences" into tJDK
      put tJDK into sJavaRoot
      if tJDK is empty or deployIsValidJDK(tJDK) is not empty then
         deployAutoconfigureJDK
         put the result into tJDK
      end if
      if tJDK is not empty then
         set the cMobileSupport["android.jdk"] of stack "revPreferences" to tJDK
         put tJDK into sJavaRoot
      end if
   else
      --put empty into sJavaRoot
   end if
end deployAutoconfigure

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
   
   if there is no file pathToAapt2(pPath) then
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

command revSaveAsMobileStandalone \
      pStack, \
      pAabFile, \
      pTarget, \
      pSettings, \
      @xStandalonePaths, \
      pDevice

   local tPath
   local tErrorMessage
   put the cMobileSupport["android.sdk"] of stack "revPreferences" into tPath
   
   if tPath is empty then
      throw revIDELocalise("In order to build Android standalones" & \ 
            " you need to choose the location of your Android development SDK" & \
            " in Preferences -> Mobile Support")
   end if
   put revIDEDeployAndroidIsValidSDK(tPath) into tErrorMessage
   if tErrorMessage is not empty then # now returns an error string
      throw revIDELocalise("The chosen folder in Preferences -> Mobile Support" & \
            " is not a valid Android SDK because" && tErrorMessage & ". " &\
            "Please ensure you have installed it correctly," & \
            " and enabled support for") && revIDEDeployAndroidRequiredSDK()
   end if
   
   local tTargetType
   if pTarget contains "build" then
      put "android release" into tTargetType
   else
      put "android test" into tTargetType
   end if

   local tPackage
   put pAabFile into tPackage
   if not pSettings["android,use bundle"] then
      set the itemDelimiter to "."
      put "apk" into the last item of tPackage
      set the itemDelimiter to ","
   end if

   try
      put the cMobileSupport["android.jdk"] of stack "revPreferences" into sJavaRoot
      dispatch "savingMobileStandalone" to stack pStack with tTargetType, tPackage
   end try
   
   try
      revSaveAsMobileStandaloneMain \
         pStack, \
         pAabFile, \
         pTarget, \
         pSettings, \
         pDevice
   catch tError
   end try
   
   try
      if tError is not empty then
         put empty into tPackage
      end if
      dispatch "mobileStandaloneSaved" to stack pStack with tTargetType, tPackage
   end try
   
   if tError is not empty then
      throw tError
   end if
end revSaveAsMobileStandalone

