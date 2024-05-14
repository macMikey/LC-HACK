script "Bugfix22826.livecodescript"

/*
* fix for bugzilla #22826
*
* more verbose description
*/

local sOriginalUpdateHandler

constant kHandler = "autoCompleteIFsAreBalanced"  # the name of the handler to replace
constant kObject = "stack revCommonEditorbehavior" # object whose script contains the handler

# ***********************************************************************
# if only one patch

command initializePlugin
    dispatch function "initializeHandler" to stack "PowerStrip" with kHandler, kObject, the name of me
    put the result into sOriginalUpdateHandler
end initializePlugin

command removePlugin
    dispatch "monkeyPatch" to stack "PowerStrip" with kObject, kHandler, sOriginalUpdateHandler
end removePlugin


# Here's the corrected handler:

function autoCompleteIFsAreBalanced pLineNumber, pScript
   local tHandlerStarts, tHandlerName

   put "on,function,command,setProp,getProp,after,before,private" into tHandlerStarts

   --put textGetScript() into tScript

   repeat with i = pLineNumber down to 1
      if token 1 of line i of pScript is among the items of tHandlerStarts then
         exit repeat
      end if
   end repeat

   delete line 1 to i - 1 of pScript

   if token 1 of line 1 of pScript is "private" then
      put token 3 of line 1 of pScript into tHandlerName
   else
      put token 2 of line 1 of pScript into tHandlerName
   end if

   local tCounter
   repeat for each line aLine in pScript
      add 1 to tCounter
      if token 1 of aLine is "end" and token 2 of aLine is tHandlerName then
         exit repeat
      end if
   end repeat

   put line 1 to tCounter of pScript into pScript

   -- remove slash asterisk comments
   local tBeginAsterix, tEndAsterix, tCharBegin, tCharEnd
   put slash & "*" into tBeginAsterix
   put "*" & slash into tEndAsterix

   repeat
      put offset(tBeginAsterix, pScript) into tCharBegin
      if tCharBegin is 0 then exit repeat
      put offset(tEndAsterix, pScript) into tCharEnd
      if tCharEnd is 0 then
         exit repeat -- stay out of trouble
      end if
      delete char tCharBegin to tCharEnd of pScript
   end repeat

   -- remove comments after backslash
   -- and remove line-continuation
   local tBackSlashStart, tReturnStart
   put 0 into tBackSlashStart
   repeat
      put offset(backslash, pScript, tBackSlashStart) into tBackSlashStart
      if tBackSlashStart is 0 then exit repeat
      put offset(return, pScript, tBackSlashStart) into tReturnStart
      delete char tBackSlashStart to tBackSlashStart + tReturnStart  of pScript
      put 0 into tBackSlashStart
   end repeat

   replace ";" with return in pScript -- remove ";"

   local tDepth, tToken1, tElse, tIf_Then_CodeFlag, tElse_IFFlag
   put "e" & "lse" into tElse -- avoid "tokenization"
   put false into tIf_Then_CodeFlag
   put false into tElse_IFFlag
   put 0 into tDepth

   repeat for each line aLine in pScript
      put token 1 of aLine into tToken1
      if tToken1 is empty then next repeat

      ######### get rid of one-liners
      --   if foo() then code else code
      if tToken1 is "if" and token -1 of aLine is not "then" and tElse is among the tokens of aLine then
         next repeat
      end if

      --   if foo()
      --   then code else code
      if tToken1 is "then" and token -1 of aLine is not "then" and tElse is among the tokens of aLine then
         next repeat
      end if
      ######### end get rid of one-liners

      ######### special case of if-then-code
      --   if bar() then code <-- can go on with else or end here
      --   else
      --      code
      --   end if
      -- or
      --   if bar() then code <-- can end with else_code
      -- -- optionally some lines else-if-then
      --   else code

      if tIf_Then_CodeFlag then
         if tToken1 is tElse then

            if the number of tokens of aLine = 1 then
               put false into tIf_Then_CodeFlag
               add 1 to tDepth
               next repeat
            end if

            if token 2 of aLine is "if" and token -1 of aLine is "then" then
               put false into tIf_Then_CodeFlag
               add 1 to tDepth
               next repeat
            end if

            if token 2 of aLine is "if" and token -1 of aLine is not "then" then
               next repeat
            end if

            if token 2 of aLine is not "if" and the number of tokens of aLine > 1 then
               put false into tIf_Then_CodeFlag
               next repeat
            end if

         else
            put false into tIf_Then_CodeFlag
         end if
      end if

      -- condition of entering special case if-then-code
      if tToken1 is "if" and "then" is among the tokens of aLine and  \
            token -1 of aLine is not "then" and tElse is not among the tokens of aLine then
         put true into tIf_Then_CodeFlag
         next repeat
      end if

      if tToken1 is "then" and  \
            token -1 of aLine is not "then" and tElse is not among the tokens of aLine then
         put true into tIf_Then_CodeFlag
         next repeat
      end if
      ######### end special case: if-then-code

      if tToken1 is "if" and token -1 of aLine is "then" then
         add 1 to tDepth
      end if

      if tToken1 is "then" and token -1 of aLine is "then" then
         add 1 to tDepth
      end if

      ####################
      --   if foo() then
      --      code else code <--
      if tElse is among the tokens of aLine and  \
            (tToken1 is not tElse) and  \
            (token -1 of aLine is not tElse) and \
            (tToken1 is not "then" and tToken1 is not "if") then
         subtract 1 from tDepth
      end if
      ####################

      ####################
      --      if foo() then
      --         code
      --      else code <--
      if tToken1 is tElse and token -1 of aLine is not tElse and "if" is not among the tokens of aLine then
         subtract 1 from tDepth
      end if
      ####################

      ####################
      -- special case else-if-code
      --   if foo() then
      --      code
      --   else if bar() then code <-- can end here
      -- or
      --   if foo() then
      --      code
      --   else if bar() then code
      --   else <-- or go on with else
      --   code

      if tElse_IFFlag then
         if tToken1 is tElse then

            if token 2 of aLine is "if" and token -1 of aLine is not "then" then
               next repeat
            end if

            put false into tElse_IFFlag
            next repeat

         else
            put false into tElse_IFFlag
            subtract 1 from tDepth
         end if
      end if

      -- special case else-if-code
      -- also tests else-if without "then", "then" is in this case on following line
      if tToken1 is tElse and token 2 of aLine is "if" and token -1 of aLine is not "then" then
         put true into tElse_IFFlag
         next repeat
      end if
      -- end special case else-if-code
      ####################

      if tToken1 is "end" and token 2 of aLine is "if" then
         subtract 1 from tDepth
      end if

   end repeat

   if tDepth is 0 then
      return false
   else
      return true
   end if

end autoCompleteIFsAreBalanced

