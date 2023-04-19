//
// Copyright (c) 2023, Novant LLC
// Licensed under the MIT License
//
// History:
//   18 Apr 2023  Andy Frank  Creation
//

using graphics

*************************************************************************
** PdfObj
*************************************************************************

abstract class PdfObj
{
  ** Indirect reference to this object, or 'null' if none assigned.
  internal PdfRef? ref { internal set }
}

*************************************************************************
** PdfArray
*************************************************************************

class PdfArray : PdfObj
{
  ** Add a value to the end of this array.
  @Operator This add(Obj? val) { vals.add(val); return this }

  ** Get value for given index.
  @Operator Obj? get(Int index) { vals[index] }

  ** Set value for given index.
  @Operator Obj? set(Int index, Obj? val) { vals[index] = val }

  ** Iterate name-value pairs in this dict.
  Void each(|Obj?,Int| f) { vals.each(f) }

  private Obj?[] vals := [,]
}

*************************************************************************
** PdfDict
*************************************************************************

class PdfDict : PdfObj
{
  ** Optionial dict type.
  virtual Str? type() { null }

  ** Get value for key or 'null' if not found.
  @Operator virtual Obj? get(Str key) { vals[key] }

  ** Set value for key.
  @Operator virtual Obj? set(Str key, Obj? val) { vals[key] = val }

  ** Iterate name-value pairs in this dict.
  virtual Void each(|Obj?,Str| f) { vals.each(f) }

  private Str:Obj? vals := [:]
}

*************************************************************************
** PdfRect
*************************************************************************

class PdfRect : PdfObj
{
  ** Constructor.
  new make(Int lx, Int ly, Int ux, Int uy)
  {
    this.lx = lx
    this.ly = ly
    this.ux = ux
    this.uy = uy
  }

  ** Lower left x coordinate.
  const Int lx

  ** Lower left y coordinate.
  const Int ly

  ** Upper right x coordinate.
  const Int ux

  ** Upper right y coordinate.
  const Int uy
}

*************************************************************************
** PdfStream
*************************************************************************

class PdfStream : PdfObj
{
  new make(Str text) { this.text = text}

  Str text
}

*************************************************************************
** PdfFont
*************************************************************************

class PdfFont : PdfDict
{
  ** Construct a new font.
  new make(Str name := "Helvetica")
  {
    // TODO FIXIT
    // /FO
    this.set("BaseFont", "/${name}")
    this.set("Subtype",  "/Type1")
  }

  override const Str? type := "Font"
}
