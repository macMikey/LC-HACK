PowerStrip

PowerStrip is a plugin to allow patching a LiveCode installation on IDE startup.
The individual patches are in a PowerPlugs folder in the same folder as the plugin.
Enabling and disabling patches is done through the PowerStrip plugin:
  the list of PowerPlugs is initialized when the plugin starts up
  clicking on a line in the list will toggle whether it is enabled at plugin launch.
  The enabled PowerPlugs are stored as json objects in PowerPlugs.txt.

From the docs (and the stack script header)

/*
* PowerStrip
* mark wieder and ah,software 2023
*
* PowerStrip is an umbrella for patches to system IDE scripts.

To install:
Create a PowerPlugs folder in your user Plugins folder
Place livecodescript files in the PowerPlugs folder
Launch PowerStrip

Clicking a script will toggle installing or removing that patch file

Livecodescript files without an installPlugin handler will place that file's code in a frontscript.
Livecodescript files with an installPlugin handler will use that handler to patch or install the script in that file

Example constructor and destructor from revProjectBrowserBehavior.livecodescript:
This replaces the behavior script of the Project Browser
while keeping the behavior of the behavior script.

local sOriginalBehavior
local kObject = "stack revIDEProjectBrowser"

command initializePlugin
    put the behavior of kObject into sOriginalBehavior
    set the behavior of this me to the long id of stack "revPaletteBehavior"
    set the behavior of kObject to me  
end initializePlugin

command removePlugin
    send "restoreBehavior kObject, sOriginalBehavior" to stack "PowerStrip" in 0 milliseconds
end removePlugin

Example constructor and destructor from tsNetEditionType.livecodescript:
This replaces just the ulExtIsBlocked() handler in the tsNetLibUrl script.

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
*/

