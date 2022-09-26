/* function allProperties ( longID ) -> array
accepts an object's long id
returns an array with all properties of the object
(storing the read-only properties in a separate array element)
because widgets, for example, don't have a way to do this. EXPORT does not, and widgets return nothing from the properties keyword
*/
function allProperties pLongID
   local tObjectProperties
   local tPropPanelsA, tPropsA
   local tPanelName
   local tPropA
   
   put revIDEPropertiesInfo (pLongID) into tPropPanelsA
   repeat for each key tPropPanelNumber in tPropPanelsA
      put tPropPanelsA[tPropPanelNumber]["label"] into tPanelName
      put revIDEPropertiesOfSection (pLongID, tPanelName) into tPropsA
      repeat for each key tPropLabel in tPropsA
         repeat for each key tPropName in tPropsA[tPropLabel]
            put tPropsA[tPropLabel][tPropName] into tPropA
            if (tPropA["read_only"]) then
               # make the read-only values available as well
               put tPropA["value"][pLongID] into tObjectProperties["read_only"][tPropName]
            else
               # store the mutable values
               put tPropA["value"][pLongID] into tObjectProperties[tPropName]
            end if
         end repeat #for each key tPropName in tPropsA[tPropLabel]
      end repeat #for each key tPropLabel in tPropsA
   end repeat #for each key tPropPanelNumber in tPropPanelsA
   return tObjectProperties
end allProperties

