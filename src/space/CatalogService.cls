 
 /*------------------------------------------------------------------------
    File        : CatalogService
    Purpose     : 
    Syntax      : 
    Description : 
    Author(s)   : bronco
    Created     : Sun Jun 30 20:03:18 CEST 2024
    Notes       : 
  ----------------------------------------------------------------------*/

block-level on error undo, throw.

using core.data.CrudResourceService.
using fwebh.pas.service.IDeleteDataService.
using fwebh.pas.service.IGetDataService.
using fwebh.pas.service.IPostDataService.
using fwebh.pas.service.IPutDataService.

class space.CatalogService inherits CrudResourceService implements IPostDataService, IGetDataService, IPutDataService, IDeleteDataService: 

  define temp-table tt no-undo
    field catalog_id as int64
    field fullname as char serialize-name "name"
    field short as char
    field prefix as char
    field moddt as datetime-tz
    .

  constructor public CatalogService():
    super("catalogs", temp-table tt:handle).
  end constructor.

end class.
