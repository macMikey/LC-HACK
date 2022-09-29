/* function allProperties ( longID ) -> array
returns an array with all properties of the object
(storing the read-only properties in a separate array element)
because widgets, for example, don't have a way to do this. EXPORT does not, and widgets return nothing from the properties keyword

pLongID : long id of the object whose properties we want to examine
pShowDetails? : true for a deep dive, otherwise a normal list

Example syntax:
local tProps
# show just the property values
put allProperties(the long id of widget 1) into tProps
# this one shows all the gory details
# put allProperties(the long id of widget 1, true) into tProps
breakpoint

*/
function allProperties pLongID, pShowAllDetails?
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
               put tPropA["value"][pLongID] into tObjectProperties["read_only"][tPropName]
            else
               if tPropA is an array and pShowAllDetails? is true then
                  repeat for each key tKey in tPropA
                     switch tKey
                        case "value"
                        case "effective"
                           put tPropA[tKey][pLongID] into tObjectProperties[tPropName][tKey]
                           break
                        default
                           put tPropA[tKey] into tObjectProperties[tPropName][tKey]
                     end switch
                  end repeat
               else
                  put tPropA["value"][pLongID] into tObjectProperties[tPropName]
               end if
            end if
         end repeat #for each key tPropName in tPropsA[tPropLabel]
      end repeat #for each key tPropLabel in tPropsA
   end repeat #for each key tPropPanelNumber in tPropPanelsA
   return tObjectProperties
end allProperties

