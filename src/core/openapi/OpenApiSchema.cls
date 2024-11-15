 
 /*------------------------------------------------------------------------
    File        : OpenApiSchema
    Purpose     : 
    Syntax      : 
    Description : 
    Author(s)   : bronco
    Created     : Fri Jul 12 08:09:11 CEST 2024
    Notes       : 
  ----------------------------------------------------------------------*/


block-level on error undo, throw.

using Progress.Json.ObjectModel.JsonObject.
using Progress.Json.ObjectModel.JsonArray.
using OpenEdge.Core.Collections.StringStringMap.
using core.openapi.OpenApiParameterType.
using core.openapi.OpenApiParameter.
using Progress.Collections.HashMap.
using OpenEdge.Core.String.
using fwebh.core.JSON.

class core.openapi.OpenApiSchema: 
  
  define public property Resource as char no-undo get. set.
  define public property SchemaJson as JsonObject no-undo get. private set.
  
  var private JsonObject properties. 
  var private HashMap<String, JsonArray> parameters.
  
  constructor public OpenApiSchema():
    SchemaJson = constructJson().  
    parameters = new HashMap<String, JsonArray>().
  end constructor.
  
  method public JsonObject AddProperty(propertyName as char, datatype as char):
    return AddProperty(propertyName, datatype, ?).
  end method.
  
  method public JsonObject AddProperty(propertyName as char, datatype as char, dataformat as char):
    
    var JsonObject prop = new JsonObject().
    
    prop:Add("type", datatype).
    
    if dataformat > "" then
      prop:Add("format", dataformat).
    
    properties:Add(propertyName, prop).    
    
    return prop.
    
  end method.
  
  method public void SetRequiredFields(fieldList as char extent):
    SchemaJson:Add("required", new JsonArray(fieldList)).
  end method.
  
  method private JsonObject constructJson():
    
    var JsonObject json = new JsonObject().
    
    properties = new JsonObject().
    
    json:Add("type", "object").
    json:Add("properties", properties). 
    
    return json.
    
  end method.
  
  method public void AddParameter(verb as char, parm as OpenApiParameter):
    
    var JsonArray verbArray.
    var String key = new String(verb).
    
    verbArray = parameters:GetValue(key).
    if not valid-object(verbArray) then
      verbArray = new JsonArray().
    
    verbArray:Add(parm:ToJson()).
    
    parameters:Set(key, verbArray).
      
  end method.  // AddParameter
  
  method public JsonArray GetVerbParameters(verb as char):
    var JsonArray array = parameters:GetValue(new String(verb)).
    if not valid-object(array) then 
      array = new JsonArray().
    return array.
  end method.
  
  //method public JsonObject GetPa
end class.
