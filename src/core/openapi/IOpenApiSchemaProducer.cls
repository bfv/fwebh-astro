
/*------------------------------------------------------------------------
    File        : IOpenApiSchemaProducer
    Purpose     : 
    Syntax      : 
    Description : 
    Author(s)   : bronco
    Created     : Thu Jul 11 13:57:57 CEST 2024
    Notes       : 
  ----------------------------------------------------------------------*/

using core.openapi.OpenApiSchema.
using Progress.Json.ObjectModel.JsonObject.

interface core.openapi.IOpenApiSchemaProducer:  
  
  method public OpenApiSchema GetSchema().
    
end interface.