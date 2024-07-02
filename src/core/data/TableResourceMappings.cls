 
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

using core.data.TableResourceMappings.
using core.data.TableResourceDefinition.
using fwebh.serialize.IListInfo.
using OpenEdge.Core.Collections.List.
using fwebh.serialize.SimpleJsonSerializer.
using fwebh.serialize.SimpleJsonDeserializer.

class core.data.TableResourceMappings implements IListInfo: 
  
  define public property mappings as List no-undo get. set.  
  
  constructor public TableResourceMappings():
    load().  
  end.
  
  method public character GetListType(listName as character):
    var char listType.
    case listName:
      when "mappings" then listType = "core.data.TableResourceDefinition".
    end.
    return listType.
  end method.
  
  method public TableResourceMappings GetMappings():
    return this-object.
  end method. 
  
  method private void load():
    new SimpleJsonDeserializer():DeserializeFile("core/data/tableresourcemappings.json", this-object).
    message this-object:mappings:Size view-as alert-box.
  end method.  // load
  
  method public TableResourceDefinition Get(resource as char):
    
    var TableResourceDefinition res.
    
    res = new TableResourceDefinition().
    
    case resource:
      when "constellation" then 
        assign 
          res:Resource = "constellation"
          res:TableName = "constellation"
          .
    end.
        
    return res.
    
  end.
  
end class.
