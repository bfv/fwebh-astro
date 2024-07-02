 
 /*------------------------------------------------------------------------
    File        : TableResourceDefinition
    Purpose     : 
    Syntax      : 
    Description : 
    Author(s)   : bronco
    Created     : Fri Jun 21 15:53:35 CEST 2024
    Notes       : 
  ----------------------------------------------------------------------*/

block-level on error undo, throw.

class core.data.TableResourceDefinition: 
  
  define public property resource as char no-undo get. set.
  define public property tableName as char no-undo get. set.
  define public property idField as char no-undo
    get():
      return (if IdField > "" then idField else substitute("&1_id", tableName)).
    end.
    set.
  
  constructor public TableResourceDefinition(resource as char, tablename as char):
    this-object:resource = resource.
    this-object:tableName = tablename.      
  end.
  
  constructor public TableResourceDefinition():
    
  end.
  
end class.
