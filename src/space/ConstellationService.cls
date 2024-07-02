 
 /*------------------------------------------------------------------------
    File        : ConstellationService
    Purpose     : 
    Syntax      : 
    Description : 
    Author(s)   : bronco
    Created     : Fri Jun 21 10:15:53 CEST 2024
    Notes       : 
  ----------------------------------------------------------------------*/

block-level on error undo, throw.

using core.data.CrudResourceService.

using fwebh.core.JSON.
using fwebh.pas.data.IResponseData.
using fwebh.pas.data.IRequestData.
using fwebh.pas.service.IGetDataService.
using fwebh.pas.service.IPutDataService.
using fwebh.pas.data.ResponseData.
using fwebh.serialize.SimpleJsonSerializer from propath.
using fwebh.serialize.SimpleJsonDeserializer.
using fwebh.lang.error.NotFoundException.
using fwebh.lang.error.BadRequestException.
using Progress.Json.ObjectModel.JsonObject.


class space.ConstellationService inherits CrudResourceService implements IGetDataService, IPutDataService: 
  
  define temp-table tt no-undo like constellation.
  
  constructor public ConstellationService():
    super("constellations", temp-table tt:handle).  
  end.
  
  // GetData in parent
  
  
end class.

/*  
  method public IResponseData PutData2(request as IRequestData):
    
    var IResponseData response = new ResponseData().
    var JsonObject json.
    var int64 id = int(request:Resource:Id).
    
    define buffer b-constellation for constellation.

    json = cast(request:Data:Json, JsonObject).
    
    new SimpleJsonDeserializer():JsonObjectToTempTable(json, temp-table tt:handle).
    find tt.
    
    if id <> tt.constellation_id and tt.constellation_id <> ? then
      undo, throw new BadRequestException(substitute("id cannot be changed, url: &1, data: &2", id, tt.constellation_id)).
      
    do transaction on error undo, throw:
      
      find b-constellation where b-constellation.constellation_id = id exclusive-lock no-error.
      if not available(b-constellation) then
        undo, throw new NotFoundException(substitute("constellation with id '&1' not found", id)).  
      
      @todo(what="concurrency check").
      
      buffer-copy tt 
        except moddt
        to b-constellation
        assign b-constellation.moddt = now
        .
    end.  // transaction
        
    buffer-copy b-constellation to tt.
        
    response:Data:TempTableHandle = temp-table tt:handle.
        
    return response.
    
  end method.  // PutData
*/