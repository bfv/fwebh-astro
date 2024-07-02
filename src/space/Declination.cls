 
 /*------------------------------------------------------------------------
    File        : Declination
    Purpose     : 
    Syntax      : 
    Description : 
    Author(s)   : bronco
    Created     : Wed Jun 26 08:36:22 CEST 2024
    Notes       : 
  ----------------------------------------------------------------------*/

block-level on error undo, throw.

class space.Declination: 
  
  define public property Degrees as decimal no-undo get. set.
  
  method public char GetDMSString():
    
  end.
  
end class.