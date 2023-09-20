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
** PdfObjRef
*************************************************************************

** PdfObjRef is used to late bind refs before refs have been set.
class PdfObjRef : PdfObj
{
  new make(PdfObj target) { this.target = target }

  ** Get ref of target object.
  internal PdfRef targetRef() { target.ref }

  private PdfObj target
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
  ** Get value for key or 'null' if not found.
  @Operator virtual Obj? get(Str key) { vals[key] }

  ** Set value for key.
  @Operator virtual Obj? set(Str key, Obj? val) { vals[key] = val }

  ** Iterate name-value pairs in this dict.
  virtual Void each(|Obj?,Str| f) { vals.each(f) }

  private Str:Obj? vals := [:] { it.ordered=true }
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
** PdfStrStream
*************************************************************************

class PdfStrStream : PdfObj
{
  new make(Str text) { this.text = text }

  const Str text
}

*************************************************************************
** PdfBufStream
*************************************************************************

class PdfBufStream : PdfObj
{
  new make(Buf buf) { this.buf = buf }

  const Buf buf
}

*************************************************************************
** PdfFont
*************************************************************************

class PdfFont : PdfDict
{
  ** Construct a new font.
  new make(Str name)
  {
    this.name = name
    this.set("Type", "/Font")
    this.set("BaseFont", "/${name}")
    this.set("Subtype", "/Type1")
  }

  ** Font name.
  const Str name

  // unique id font /PageTree /Font dict
  internal Str? id
}

*************************************************************************
** PdfImage
*************************************************************************

class PdfImage : PdfDict
{
  ** Construct a image.
  new make(Uri uri, Buf stream)
  {
    this.uri = uri
    this.stream = stream
    this.set("Type",    "/XObject")
    this.set("Subtype", "/Image")
  }

  ** Unique uri for this image.
  const Uri uri

  ** Image stream contents.
  const Buf stream

  override Void each(|Obj?,Str| f)
  {
    super.each(f)
    f(stream.size, "Length")
  }

  internal Str? id  // unique img id /PageTree /XObject dict
}
