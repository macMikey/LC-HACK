/* function allProperties ( longID ) -> array
accepts an object's long id
returns an array with all non-read-only properties of the object
because widgets, for example, don't have a way to do this. EXPORT does not, and widgets return nothing from the properties keyword
*/
function allProperties longID
   put revIDEPropertiesInfo (longID) into tPropPanelsA
   repeat for each key tPropPanelNumber in tPropPanelsA
      put tPropPanelsA[tPropPanelNumber]["label"] into tPanelName
      put revIDEPropertiesOfSection (longID, tPanelName) into tPropsA
      repeat for each key tPropLabel in tPropsA
         repeat for each key tPropName in tPropsA[tPropLabel]
            put tPropsA[tPropLabel][tPropName] into tPropA
            if not (tPropA["read_only"]) then
               put tPropA["value"][longID] into objectProperties[tPropName]
            end if
         end repeat #for each key tPropName in tPropsA[tPropLabel]
      end repeat #for each key tPropLabel in tPropsA
   end repeat #for each key tPropPanelNumber in tPropPanelsA
   return objectProperties
end allProperties
