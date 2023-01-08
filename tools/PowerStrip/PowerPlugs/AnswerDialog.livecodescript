script "AnswerDialog.livecodescript"

/*
* set fixedLineHeight false
*/

local sOriginalHandler
constant kHandler = "dialogInitialize"  # the name of the handler to replace
constant kObject = "stack Answer Dialog" # object whose script contains the handler

command initializePlugin
    dispatch function "initializeHandler" to stack "PowerStrip" with kHandler, kObject, the name of me
    put the result into sOriginalHandler
end initializePlugin

command removePlugin
    dispatch "monkeyPatch" to stack "PowerStrip" with kObject, kHandler, sOriginalHandler
end removePlugin

# Here's the corrected handler:

command dialogInitialize
	lock messages

	/* First item created is the main icon that is displayed, with its
	 * corresponding properties */
	if there is not a button "icon" of me then
		create button "icon" in this card of me
		set the style of it to "transparent"
		set the showName of it to false
		set the autoHilite of it to false
		set the sharedHilite of it to false
		set the traversalOn of it to false
		set the width of it to 64
		set the height of it to 64
	end if

	/* Creates Icon 2 for the dialog - Secondary icon used in MacOS (currently
	 * broken) */
	if there is not a button "icon 2" of me then
		create button "icon 2" in this card of me
		set the style of it to "transparent"
		set the showName of it to false
		set the autoHilite of it to false
		set the sharedHilite of it to false
		set the traversalOn of it to false
		set the showFocusBorder of it to false
		set the width of it to 47
		set the height of it to 38
	end if

	/* Creates the prompt field if there is not one already created */
	if the number of fields of me is 0 then
		create field in this card of me
		set sharedText of it to true
		set dontWrap of it to false
		set lockText of it to true
		set opaque of it to false
		set traversalOn of it to false
		set showBorder of it to false
		set vScrollbar of it to true
		set width of it to 293
		set height of it to 342
        set the fixedLineHeight of it to false
	end if

	/* Sets a constant to the number of buttons that are required for the dialog
	 * and uses this to repeat through to create them individually, with the + 2
	 * for both the icon buttons already created. */
	constant kFieldCount = 8
	repeat while the number of buttons of me < (kFieldCount + 2)
		create button in this card of me
		set the loc of it to -100,-100
	end repeat

	unlock messages
end dialogInitialize

