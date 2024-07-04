 
 /*------------------------------------------------------------------------
    File        : CrudResourceService
    Purpose     : 
    Syntax      : 
    Description : 
    Author(s)   : bronco
    Created     : Mon Jun 24 09:43:03 CEST 2024
    Notes       : 
  ----------------------------------------------------------------------*/

block-level on error undo, throw.

using Progress.Json.ObjectModel.JsonObject.
using core.data.DynamicQuery.
using fwebh.lang.error.BadRequestException.
using fwebh.lang.error.ConcurrencyException.
using fwebh.lang.error.NotFoundException.
using fwebh.pas.data.IRequestData.
using fwebh.pas.data.IResponseData.
using fwebh.pas.data.ResponseData.
using fwebh.serialize.SimpleJsonDeserializer.
using fwebh.serialize.SimpleJsonSerializer.
using core.data.TableResourceDefinition.
using core.data.TableResourceMappings.

class core.data.CrudResourceService: 
  
  define public property Resource as char no-undo get. private set.
  define public property TempTableHandle as handle no-undo get. private set.
  
  var TableResourceDefinition resourceDef.
  
  constructor public CrudResourceService(resource as char, htt as handle):
    this-object:Resource = resource.
    this-object:TempTableHandle = htt.
    @todo(what="load once per session").
    resourceDef = new TableResourceMappings():Get(resource). 
    // for REST, output the idfield as "id", not the db field name
    htt:default-buffer-handle:buffer-field(resourceDef:idField):serialize-name = "id".
  end.
  
  method public IResponseData GetData(request as IRequestData):

    var IResponseData response = new ResponseData().
    var char tablename = resourceDef:tableName.
    var char id = request:Resource:Id.
    var DynamicQuery q.
    var handle ttBufferHandle.
    
    ttBufferHandle = TempTableHandle:default-buffer-handle.
    
    q = new DynamicQuery(tablename).
    if id > "" then
      q:SetWhereClause(substitute("&1 = &2", resourceDef:idField, quoter(id))).    
    
    q = q:BuildQuery().
    
    do while not q:QueryHandle:query-off-end:
      ttBufferHandle:buffer-create(). 
      ttBufferHandle:buffer-copy(q:BufferHandle).
      q:QueryHandle:get-next().
    end.
        
    if id > "" then
      response:Data:Json = new SimpleJsonSerializer():SerializeBuffer(ttBufferHandle).
    else
      response:Data:TempTableHandle = TempTableHandle.
      
    return response.
      
  end method.  // GetData
  
  method public IResponseData PostData(request as IRequestData):

    var IResponseData response = new ResponseData().
    var JsonObject json.
    var int64 idFieldValue, id = int(request:Resource:Id).
    var char idField.
    var handle dbBufferHandle, ttBufferHandle.
     
    create buffer dbBufferHandle for table resourceDef:tableName.
    ttBufferHandle = TempTableHandle:default-buffer-handle  .
    
    json = cast(request:Data:Json, JsonObject).
    
    new SimpleJsonDeserializer():JsonObjectToTempTable(json, TempTableHandle).
    ttBufferHandle:find-first().
    
    idField = resourceDef:idField.
    
    validateRequiredFields(ttBufferHandle, resourceDef, true).
    validateUniqueFields(ttBufferHandle, resourceDef, true).
           
    do transaction on error undo, throw:

      dbBufferHandle:buffer-create().
      dbBufferHandle:buffer-copy(ttBufferHandle, substitute("&1,moddt", idField)).
      dbBufferHandle:buffer-field(idField):buffer-value = dynamic-next-value("obj_id", ldbname(1)).
      dbBufferHandle::moddt = now.
      dbBufferHandle:buffer-validate().

      catch err1 as Progress.Lang.Error :
        message substitute("transaction failed, resource: &1, id: &2", Resource, idFieldValue).
        undo, throw err1.
      end catch.

    end.  // transaction

    ttBufferHandle:buffer-copy(dbBufferHandle).
    response:Data:TempTableHandle = TempTableHandle.
    dbBufferHandle:buffer-release().
            
    return response.
    
    finally:
      delete object dbBufferHandle.
    end.
    
  end method.  // PostData

  method public IResponseData PutData(request as IRequestData):

    var IResponseData response = new ResponseData().
    var JsonObject json.
    var int64 idFieldValue, id = int(request:Resource:Id).
    var char idField.
    var handle dbBufferHandle, ttBufferHandle.
     
    create buffer dbBufferHandle for table resourceDef:tableName.
    ttBufferHandle = TempTableHandle:default-buffer-handle  .
    
    json = cast(request:Data:Json, JsonObject).
    
    new SimpleJsonDeserializer():JsonObjectToTempTable(json, TempTableHandle).
    ttBufferHandle:find-first().
    
    idField = resourceDef:idField.
    idFieldValue = ttBufferHandle:buffer-field(idField):buffer-value.
    
    response:Data:TempTableHandle = TempTableHandle.
    if id <> idFieldValue and idFieldValue <> ? then
      undo, throw new BadRequestException(substitute("id cannot be changed, url: &1, data: &2", id, idFieldValue)).
    
    dbBufferHandle:find-first(substitute("where &1 = &2", idField, quoter(id)), no-lock) no-error.
    if not dbBufferHandle:available then 
      undo, throw new NotFoundException(substitute("resource: &1, id: &2", request:Resource:Name, id)).
    
    // if one doesn't send the moddt it received, the resource is either out of date of tampered with
    if dbBufferHandle::moddt <> ttBufferHandle::moddt then
      undo, throw new ConcurrencyException(this-object:Resource, idFieldValue).
    
    validateRequiredFields(ttBufferHandle, resourceDef, false).
    validateUniqueFields(ttBufferHandle, resourceDef, false).
    
    do transaction on error undo, throw:

      dbBufferHandle:find-current(exclusive-lock).
      dbBufferHandle:buffer-copy(ttBufferHandle, "moddt").
      dbBufferHandle::moddt = now.
      dbBufferHandle:buffer-validate().

      catch err1 as Progress.Lang.Error :
        message substitute("transaction failed, resource: &1, id: &2", Resource, idFieldValue).
        undo, throw err1.
      end catch.

    end.  // transaction

    ttBufferHandle:buffer-copy(dbBufferHandle).
    dbBufferHandle:buffer-release().
            
    return response.
    
    finally:
      delete object dbBufferHandle.
    end.
    
  end method.  // PutData
  
  method public IResponseData DeleteData(request as IRequestData):
    
    var IResponseData response = new ResponseData().
    var JsonObject json.
    var int64 idFieldValue, id = int(request:Resource:Id).
    var char idField.
    var handle dbBufferHandle.
    
    create buffer dbBufferHandle for table resourceDef:tableName.
    
    idField = resourceDef:idField.
    
    dbBufferHandle:find-first(substitute("where &1 = &2", idField, quoter(id)), no-lock) no-error.
    if not dbBufferHandle:available then 
      undo, throw new NotFoundException(substitute("resource: &1, id: &2", request:Resource:Name, id)).
    @todo(what="call validate logic").
           
    do transaction on error undo, throw:

      dbBufferHandle:find-current(exclusive-lock).
      dbBufferHandle:buffer-delete().
      
      catch err1 as Progress.Lang.Error:
        message substitute("transaction failed, resource: &1, id: &2, msg: &3", Resource, idFieldValue, err1:GetMessage(1)).
        undo, throw err1.
      end catch.
      
    end.  // transaction
    
    return response.
        
    finally:
      delete object dbBufferHandle.
    end.
    
  end method.  // DeleteData
  
  method private char validateRequiredFields(ttBufferHandle as handle, resourceDef as TableResourceDefinition, isCreate as logical):
    
    var char emptyFields.
    var int i.
    var handle fieldHandle.
      
    do i = 1 to extent(resourceDef:required):      
      fieldHandle = ttBufferHandle:buffer-field(resourceDef:required[i]).
      if fieldHandle:buffer-value = ? or fieldHandle:buffer-value = "" then do:
        emptyFields += "," + fieldHandle:serialize-name.
      end.
    end.
    
    if emptyFields > "" then
      undo, throw new BadRequestException("fields should be filled: " + trim(emptyFields, ",")).
    
    return emptyFields.
    
  end.  // validateRequiredFields
  
  method private char validateUniqueFields(ttBufferHandle as handle, resourceDef as TableResourceDefinition, isCreate as logical):

    var char uniqueFields, whereClause.
    var int i.
    var handle fieldHandle, dbBufferHandle.

    create buffer dbBufferHandle for table resourceDef:tableName.
    do i = 1 to extent(resourceDef:unique):
    
      fieldHandle = ttBufferHandle:buffer-field(resourceDef:required[i]).
      whereClause = substitute("where &1 = &2", fieldHandle:name, quoter(fieldHandle:buffer-value)).
      if not isCreate then
        whereClause += substitute(" and &1 <> &2", resourceDef:idField, quoter(ttBufferHandle:buffer-field(resourceDef:idField):buffer-value)).
      
      dbBufferHandle:find-first(whereClause) no-error.
      if dbBufferHandle:available then
        uniqueFields += substitute("&1 already exists with value &2,", fieldHandle:serialize-name, quoter(fieldHandle:buffer-value)).
    end.
    
    if uniqueFields > "" then
      undo, throw new BadRequestException(replace(trim(uniqueFields, ","), ",", "~n")).
        
    finally:
      delete object dbBufferHandle.
    end. 
    
  end method.  // validateUniqueFields
  
end class.  // CrudResourceService
