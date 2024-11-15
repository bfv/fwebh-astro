 
 /*------------------------------------------------------------------------
    File        : OpenApiParameter
    Purpose     : 
    Syntax      : 
    Description : 
    Author(s)   : bronco
    Created     : Tue Jul 16 17:29:57 CEST 2024
    Notes       : 
  ----------------------------------------------------------------------*/

block-level on error undo, throw.

using core.openapi.OpenApiParameterType.
using core.openapi.OpenApiParameter.
using Progress.Json.ObjectModel.JsonObject.
using Progress.Json.ObjectModel.JsonArray.

class core.openapi.OpenApiParameter: 
 
  define public property Name as char no-undo get. set.
  define public property Type as OpenApiParameterType no-undo get. set.
  define public property Datatype as char no-undo get. set.
  define public property Required as logical no-undo get. set.
  define public property Description as char no-undo get. set.
  define public property Direction as char no-undo initial "in" get. set.
  
  var private JsonArray possibleValues.
  
  constructor public OpenApiParameter(name as char, type as OpenApiParameterType, datatype as char):
    this-object:Name = name.
    this-object:Type = type.
    this-object:Datatype = datatype. 
    possibleValues = new JsonArray().
  end constructor.
  
  method public OpenApiParameter SetDescription(description as char):
    this-object:Description = description.
    return this-object.
  end method.
  
  method public OpenApiParameter SetAsOutput():
    this-object:Direction = "out".
    return this-object.
  end method.

  method public OpenApiParameter SetRequired():
    this-object:Required = true.
    return this-object.
  end method.
  
  method public OpenApiParameter SetPossibleValues(vals as char extent):
    possibleValues:Add(vals).
    return this-object.
  end method.
  
  method public JsonObject ToJson():
    var JsonObject json = new JsonObject(), schemaJson = new JsonObject().
     
    json:Add("name", this-object:Name).
    json:Add(this-object:Direction, lc(type:ToString())).
    
    schemaJson:Add("type", this-object:Datatype).
    if possibleValues:Length > 0 then
      schemaJson:Add("enum", possibleValues).
      
    json:Add("schema", schemaJson).
    
    json:Add("required", this-object:Required).
    json:Add("description", this-object:Description).
    
    return json.
    
  end method.  // ToJson
  
end class.
