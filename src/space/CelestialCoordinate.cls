 
 /*------------------------------------------------------------------------
    File        : CelestialCoordinate
    Purpose     : 
    Syntax      : 
    Description : 
    Author(s)   : bronco
    Created     : Wed Jun 26 08:34:25 CEST 2024
    Notes       : 
  ----------------------------------------------------------------------*/

block-level on error undo, throw.

using space.RightAscension.
using space.Declination.

class space.CelestialCoordinate: 
  
  define public property RA as RightAscension no-undo get. set.
  define public property Dec as Declination no-undo get. set.
    
end class.

