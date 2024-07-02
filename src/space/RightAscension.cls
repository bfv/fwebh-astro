 
 /*------------------------------------------------------------------------
    File        : RightAscension
    Purpose     : 
    Syntax      : 
    Description : 
    Author(s)   : bronco
    Created     : Wed Jun 26 08:35:56 CEST 2024
    Notes       : 
  ----------------------------------------------------------------------*/

block-level on error undo, throw.


class space.RightAscension:
  
  define public property Hours as int no-undo get. private set. 
  define public property Minutes as int no-undo get. private set.
  define public property Seconds as decimal no-undo get. private set.
  define public property Degrees as decimal no-undo 
    get. 
    set(d as decimal):
      Degrees = d.
      calcHMS(d).
    end.
  
  method public char GetHMSString():
    return substitute("&1h&2m&3s", Hours, Minutes, Seconds).
  end.
  
  method private void calcHMS(d as decimal):
    
    var int h, m.
    var decimal s.
    
    Hours = trunc(d / 15, 0).
    d -= Hours * 15.
    
    Minutes = trunc(d * 4, 0).
    d -= (Minutes * 15 / 60).
    
    Seconds = round(d * 240, 1).
    
  end method.  // calcHMS
   
end class.
