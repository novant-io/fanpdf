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

  ** Optionial dict subtype.
  virtual Str? subtype() { null }

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
  new make(Str text) { this.text = text }

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
  }

  ** Font name.
  const Str name

  override const Str? type := "Font"
  override const Str? subtype := "Type1"

  // unique id font /PageTree /Font dict
  internal Str? id
}

*************************************************************************
** PdfImage
*************************************************************************

class PdfImage : PdfDict
{
  ** Construct a image.
  new make(Image image)
  {
    // sanity checks
    if (image isnot PngImage) throw ArgErr("Only PNG supported")
    if (!image.isLoaded) throw ArgErr("Image not loaded")

    this.img = image
    // TODO: just make set() ordered?
    // this.set("Subtype",    "/Image")
    this.set("Width",      img.size.w.toInt)
    this.set("Height",     img.size.h.toInt)
    this.set("ColorSpace", "/${colorSpace}")
    this.set("BitsPerComponent", img["colorSpaceBits"])
    this.stream = img.imgData

    this.set("Filter", "/FlateDecode")
    switch (img.colorType)
    {
      case 0:
        // grayscale (no alpha)
        throw Err("Not yet implemented")

      case 2:
        // 8/16-bit RGB (no alpha)
        dumb := 0  // since we can't break

      case 3:
        // indexed
        throw Err("Not yet implemented")

      case 4:
        // grayscale w/ alpha

      case 6:
        // 8/16-bit RGB w/ alpha
        splitAlpha
    }
  }

  ** Image stream contents.
  Buf? stream { private set }

  override const Str? type := "XObject"
  override const Str? subtype := "Image"

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

  ** Split alpha channel from RBG into separate smask object.
  private Void splitAlpha()
  {
    pixels     := img.pixels
    pixelBytes := img.pixelBits / 8
    numPixels  := img.size.w.toInt * img.size.h.toInt
    data       := Buf(numPixels * pixelBytes)
    alpha      := Buf(numPixels)

    i   := 0
    len := pixels.size
    while (i < len)
    {
      data.write(pixels[i++])
      data.write(pixels[i++])
      data.write(pixels[i++])
      alpha.write(pixels[i++])
    }

    // set new image data with alpha channel removed
    this.stream = deflate(data.flip)

    // // add smask for alpha channel
    // smask := deflate(alpha.flip)
    // this.set("SMask", createSMask(smask)
  }

  ** Compress buf contents using DEFLATE algorithm.
  private Buf deflate(Buf contents)
  {
    buf   := Buf()
    flate := Zip.deflateOutStream(buf.out)
    contents.in.pipe(flate)
    flate.flush.close
    return buf.flip
  }

  internal Str? id       // unique img id /PageTree /XObject dict
  private PngImage img   // backing instance
}