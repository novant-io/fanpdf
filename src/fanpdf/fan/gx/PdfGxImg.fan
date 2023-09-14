//
// Copyright (c) 2023, Novant LLC
// Licensed under the MIT License
//
// History:
//   14 Sep 2023  Andy Frank  Creation
//

using graphics
using util

*************************************************************************
** PdfGxImg
*************************************************************************

internal const class PdfGxImg
{
  ** Encode image into one or more PdfImage objects. The first
  ** object always contains the primary raster data. If a second
  ** object exists, it contains the alpha channel mask for image.
  static PdfImage[] encodeImage(Image img)
  {
    // sanity check we have backing data
    if (!img.isLoaded) throw ArgErr("Image not loaded")

    // only PNG supported for now
    if (img isnot PngImage) throw ArgErr("Only PNG supported")
    PngImage png := img

    objs  := PdfImage[,]
    bits  := png["colorSpaceBits"]
    space := colorSpace(png)
    iw    := png.size.w.toInt
    ih    := png.size.h.toInt
    data  := Buf[,]

    // process img data
    switch (png.colorType)
    {
      case 0:
        // grayscale (no alpha)
        throw Err("Not yet implemented")

      case 2:
        // 8/16-bit RGB (no alpha)
        data = [png.imgData]

      case 3:
        // indexed
        throw Err("Not yet implemented")

      case 4:
        // grayscale w/ alpha
        throw Err("Not yet implemented")

      case 6:
        // 8/16-bit RGB w/ alpha
        data = splitAlpha(png)
    }

    // base palete or rgb data
    objs.add(PdfImage(png.uri, data[0]) {
      it.set("Width",  iw)
      it.set("Height", ih)
      it.set("ColorSpace", "/${space}")
      it.set("BitsPerComponent", bits)
      it.set("Filter", "/FlateDecode")
    })

    // alpha mask
    if (data.size > 1)
    {
      auri  := `${png.uri}#alpha`
      alpha := PdfImage(auri, data[1]) {
        it.set("Width",  iw)
        it.set("Height", ih)
        it.set("BitsPerComponent", 8)
        it.set("Filter",     "/FlateDecode")
        it.set("ColorSpace", "/DeviceGray")
        it.set("Decode",     PdfArray().add(0).add(1))
      }
      rgb := objs.first
      rgb.set("SMask", PdfObjRef(alpha))
      objs.add(alpha)
    }

    return objs
  }

  ** Get color space for image.
  private static Str colorSpace(Image img)
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

  ** Split alpha channel from RBG into separate streams.
  private static Buf[] splitAlpha(PngImage png)
  {
    pixels     := png.pixels
    pixelBytes := png.pixelBits / 8
    numPixels  := png.size.w.toInt * png.size.h.toInt
    rgb        := Buf(numPixels * pixelBytes)
    alpha      := Buf(numPixels)

    i   := 0
    len := pixels.size
    while (i < len)
    {
      rgb.write(pixels[i++])
      rgb.write(pixels[i++])
      rgb.write(pixels[i++])
      alpha.write(pixels[i++])
    }

    return [
      PdfGxImg.deflate(rgb.flip),
      PdfGxImg.deflate(alpha.flip)
    ]
  }

  ** Compress buf contents using DEFLATE algorithm.
  private static Buf deflate(Buf contents)
  {
    buf   := Buf()
    flate := Zip.deflateOutStream(buf.out)
    contents.in.pipe(flate)
    flate.flush.close
    return buf.flip
  }
}