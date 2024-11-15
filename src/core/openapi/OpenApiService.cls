 
 /*------------------------------------------------------------------------
    File        : OpenApiService
    Purpose     : 
    Syntax      : 
    Description : 
    Author(s)   : bronco
    Created     : Fri Jul 05 16:38:03 CEST 2024
    Notes       : 
  ----------------------------------------------------------------------*/

block-level on error undo, throw.

using fwebh.pas.data.IRequestData.
using fwebh.pas.data.IResponseData.
using fwebh.pas.service.IGetDataService.
using fwebh.pas.service.ServiceDescription.
using fwebh.pas.service.ServiceFactory.
using fwebh.pas.data.ResponseData.
using OpenEdge.Core.String.
using Progress.Json.ObjectModel.ObjectModelParser.
using Progress.Json.ObjectModel.JsonObject.
using Progress.Collections.HashMap.
using Progress.Collections.HashMapIterator.
using Progress.Json.ObjectModel.JsonArray.
using core.openapi.OpenApiSchema.

class core.openapi.OpenApiService implements IGetDataService: 
  
  var JsonObject defintionsNode.
  
  method public IResponseData GetData(request as IRequestData):
    
    var ResponseData response = new ResponseData().
    var JsonObject openapiJson.
    var HashMap<String, ServiceDescription> services = new ServiceFactory():Services.
    
    request:Accept = "application/json".
    
    if (true) then do:
      openapiJson = cast(new ObjectModelParser():ParseFile(search("core/services/openapi-template.json")), JsonObject).
      defintionsNode = new JsonObject().
      openapiJson = traverseServices(openapiJson, services).
      openapiJson:Add("definitions", defintionsNode).
    end.
    else do:
      openapiJson = cast(new ObjectModelParser():ParseFile(search("core/services/openapi-template2.json")), JsonObject).
    end.
   
    response:Data:Json = openapiJson.
    
    return response.

  end method.
  
  
  method private JsonObject traverseServices(openapiJson as JsonObject, services as HashMap<String, ServiceDescription>):
    
    var ServiceDescription svcDesc.
    var HashMapIterator<String, ServiceDescription> iter.
    var JsonObject pathsNode = new JsonObject().
    //var JsonObject pathNode = new JsonObject().
    var JsonObject serviceNode, schemaJson.
    var Progress.Lang.Class serviceClass.
    var Progress.Lang.Object serviceObj.
    var OpenApiSchema apiSchema.
    
    iter = cast(services:GetIterator(), HashMapIterator<String, ServiceDescription>).
    repeat while iter:MoveNext():      
      
      serviceClass = Progress.Lang.Class:GetClass(iter:Current:Value:classname).
      if serviceClass:TypeName = this-object:GetClass():TypeName then
        next.  // don't document self
      
      serviceObj = dynamic-new(iter:Current:Value:classname)().
      
      serviceNode = new JsonObject().
      
      if serviceObj:GetClass():IsA("core.openapi.IOpenApiSchemaProducer") then do:
        apiSchema = cast(serviceObj, core.openapi.IOpenApiSchemaProducer):GetSchema().
        schemaJson = apiSchema:SchemaJson.
        if valid-object(schemaJson) then
          defintionsNode:Add(apiSchema:Resource, schemaJson).
      end.
      else 
        apiSchema = ?.

      if serviceClass:IsA("fwebh.pas.service.IGetDataService") then
        serviceNode:Add("get", getMethodNode(iter:Current:Key:ToString(), "get", apiSchema)).
        
      if serviceClass:IsA("fwebh.pas.service.IPostDataService") then
        serviceNode:Add("post", getMethodNode(iter:Current:Key:ToString(), "post", apiSchema)).

      if serviceClass:IsA("fwebh.pas.service.IPutDataService") then
        serviceNode:Add("put", getMethodNode(iter:Current:Key:ToString(), "put", apiSchema)).

      if serviceClass:IsA("fwebh.pas.service.IDeleteDataService") then
        serviceNode:Add("delete", getMethodNode(iter:Current:Key:ToString(), "delete", apiSchema)).
        
      pathsNode:Add(substitute("/&1", iter:Current:Key:ToString()), serviceNode). 
      
    end.
    
    openapiJson:add("paths", pathsNode).
    
    return openapiJson.
    
  end method.  // traverseServices
  
  method private JsonObject getMethodNode(service as char, verb as char, apiSchema as OpenApiSchema):
    var JsonObject rootnode = new JsonObject().
    var JsonObject responseNode = new JsonObject().
    var JsonArray consumeArray = new JsonArray().
    var JsonArray parameterArray.
    var JsonObject bodyParameter.
    
    rootnode:Add("tags", new JsonArray()).  //  empty for now
    
    addResponse(responseNode, 200, "OK").
    addResponse(responseNode, 400, "Bad Request").   
    rootnode:Add("responses", responseNode).
    
    parameterArray = apiSchema:GetVerbParameters(verb).
    
    if verb = "post" or verb = "put" then do:
      consumeArray:Add("application/json").
      rootnode:Add("consumes", consumeArray).
      
      parameterArray:Add(getBodyParameter(service, verb, apiSchema)).
    end.

    rootnode:Add("parameters", parameterArray).     
    
    return rootnode.
    
  end method.
  
  method private JsonObject getBodyParameter(service as char, verb as char, apiSchema as OpenApiSchema):
    
    var JsonObject body = new JsonObject(), schemaJson = new JsonObject().
    
    body:Add("in", "body").
    body:Add("name", "body").
    body:Add("description", "body description").
    body:Add("required", true).
    
    if valid-object(apiSchema) then do:
      schemaJson:Add("$ref", substitute("#/definitions/&1", apiSchema:Resource)).
    end.
        
    body:Add("schema", schemaJson).
    
    return body.
    
  end method.
  
  
  method private void addResponse(responseNode as JsonObject, statuscode as int, description as char):
    var JsonObject descNode = new JsonObject().
    descNode:Add("description", description).
    responseNode:Add(string(statuscode), descNode).
  end method.
  
  
  method private void getContentNode():
    
  end method.
    
end class.
