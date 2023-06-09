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
    this.name = name
    this.set("BaseFont", "/${name}")
    this.set("Subtype",  "/Type1")
  }

  ** Font name.
  const Str name

  override const Str? type := "Font"

  // unique id font /PageTree /Font dict
  internal Str? id
}

*************************************************************************
** PdfImage
*************************************************************************

class PdfImage : PdfDict
{
  ** Construct a image.
  new make(Image img)
  {
    // sanity check
    if (!img.isLoaded) throw ArgErr("Image not loaded")

    this.img = img
    this.set("Subtype",    "/Image")
    this.set("Width",      img.size.w.toInt)
    this.set("Height",     img.size.h.toInt)
    this.set("ColorSpace", colorSpace)
    this.set("BitsPerComponent", img["colorSpaceBits"])

    // PNG
    this.set("Filter", "/DCTDecode")
  }

  ** Image stream contents.
  Buf stream() { img.imgData }

  override const Str? type := "XObject"

  override Void each(|Obj?,Str| f)
  {
    super.each(f)
    f(stream.size, "Length")
  }

  ** Get color space for image.
  private Str colorSpace()
  {
    cs := img["colorSpace"]
    switch(cs)
    {
      case "Gray":  return "DeviceGray"
      case "RGB":   return "DeviceRGB"
      case "YCbCr": return "DeviceRGB"
      case "CMYK":  return "DeviceCMYK"
      default: throw ArgErr("Unsupported color space: ${cs}")
    }
  }

  internal Str? id       // unique img id /PageTree /XObject dict
  private PngImage img   // backing instance
}