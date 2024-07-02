 
 /*------------------------------------------------------------------------
    File        : Angle
    Purpose     : 
    Syntax      : 
    Description : 
    Author(s)   : bronco
    Created     : Wed Jun 26 08:41:42 CEST 2024
    Notes       : 
  ----------------------------------------------------------------------*/

using Progress.Lang.*.

block-level on error undo, throw.

class space.Angle: 
  
  define public property Degrees as int no-undo get. set.
  define public property Minutes as int no-undo get. set.
  define public property Seconds as decimal no-undo get. set.
  
  
end class.