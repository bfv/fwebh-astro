 
 /*------------------------------------------------------------------------
    File        : TableResourceMappings
    Purpose     : 
    Syntax      : 
    Description : 
    Author(s)   : bronco
    Created     : Fri Jun 21 16:05:28 CEST 2024
    Notes       : 
  ----------------------------------------------------------------------*/

block-level on error undo, throw.

using OpenEdge.Core.String.
using Progress.Json.ObjectModel.JsonObject.
using Progress.Json.ObjectModel.ObjectModelParser.
using Progress.Collections.HashMap.
using core.data.TableResourceDefinition.
using fwebh.core.JSON.
using fwebh.serialize.SimpleJsonDeserializer.

class core.data.TableResourceMappings: 
  
  define private property mappings as HashMap<String, TableResourceDefinition> get. set.
  
  constructor public TableResourceMappings():
    mappings = new HashMap<String, TableResourceDefinition>().
    loadDefinitions().  
  end.
  
  method public TableResourceDefinition Get(resourceName as char):
    return mappings:GetValue(new String(resourceName)).
  end.
      
  method private void loadDefinitions():
    
    var ObjectModelParser parser = new ObjectModelParser().
    var TableResourceDefinition tableDef.
    var JsonObject jsonDoc, node.
    var SimpleJsonDeserializer deserializer = new SimpleJsonDeserializer().
    var char[] propNames.
    var int i.
    
    jsonDoc = cast(parser:ParseFile(search("core/data/tableresourcemappings.json")), JsonObject).
    propNames = jsonDoc:GetNames().
    
    do i = 1 to extent(propNames):
      node = jsonDoc:GetJsonObject(propNames[i]).
      tableDef = cast(deserializer:Deserialize(node, "core.data.TableResourceDefinition"), TableResourceDefinition).
      tableDef:resource = propNames[i].
      mappings:Add(new String(propNames[i]), tableDef).
    end.
    
  end method.  // loadDefinitions
  
end class.
