 
 /*------------------------------------------------------------------------
    File        : DynamicQuery
    Purpose     : 
    Syntax      : 
    Description : 
    Author(s)   : bronco
    Created     : Mon Jun 24 10:47:41 CEST 2024
    Notes       : 
  ----------------------------------------------------------------------*/

block-level on error undo, throw.

using core.data.DynamicQuery.


class core.data.DynamicQuery: 
  
  define public property QueryHandle as handle no-undo get. private set.
  define public property BufferHandle as handle no-undo get. private set.
  define public property QueryString as char no-undo get. private set.
  
  define private variable tableName as char no-undo.
  define private variable whereClause as char no-undo.
  
  
  constructor DynamicQuery(dbTableName as char):
    create query QueryHandle.
    create buffer BufferHandle for table dbTableName.
    this-object:tableName = dbTableName.
  end.

  constructor DynamicQuery(dbTableName as char, whereclause as char):
    create query QueryHandle.
    create buffer BufferHandle for table dbTableName.
    this-object:tableName = dbTableName.
    this-object:whereClause = whereclause. 
  end.
  
  destructor DynamicQuery():
    delete object this-object:QueryHandle.
    delete object this-object:BufferHandle.
  end.
  
  method public DynamicQuery SetWhereClause(whereclause as char):
    this-object:whereClause = whereclause.
    return this-object.
  end method.
  
  
  method public DynamicQuery BuildQuery():
    
    QueryHandle:set-buffers(BufferHandle).
    
    QueryString = substitute("for each &1", tableName).
    if (whereClause > "") then
      QueryString += " where " + whereClause.
      
    QueryHandle:query-prepare(QueryString).
    QueryHandle:query-open().
    QueryHandle:get-first().
    
    return this-object.
    
  end method.
  
end class.
