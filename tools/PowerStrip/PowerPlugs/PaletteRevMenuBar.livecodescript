script "PaletteRevMenuBar"

/*
* Make the menubar a palette on linux
* so that it stays on top of other stacks.
* You can alt-drag stacks from under the menubar if they get stuck.
*/

command initializePlugin
    if the platform is "linux" then
        set the style of stack "revMenuBar" to palette
    end if
end initializePlugin

command removePlugin
    local tTool

    lock screen
    put the tool into tTool
    set the style of stack "revMenuBar" to toplevel
    choose browse tool
    set the cantModify of stack "revMenuBar" to true
    choose tTool
    unlock screen
end removePlugin

