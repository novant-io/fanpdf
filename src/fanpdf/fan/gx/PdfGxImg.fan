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
  ** Encode image into one or more PdfObj objects. The first
  ** object of type PdfImage always contains the primary raster
  ** data. If a second PdfImage object exists, it contains the
  ** alpha channel mask for image.
  static PdfObj[] encodeImage(Image img)
  {
    // sanity check we have backing data
    if (!img.isLoaded) throw ArgErr("Image not loaded")

    // only PNG supported for now
    if (img isnot PngImage) throw ArgErr("Only PNG supported")
    PngImage png := img

    objs  := PdfObj[,]
    bits  := png["colorSpaceBits"]
    space := colorSpace(png)
    iw    := png.size.w.toInt
    ih    := png.size.h.toInt
    Buf? dataPixels
    Buf? dataPalette
    Buf? dataAlpha

    // process img data
    switch (png.colorType)
    {
      case 0:
        // grayscale (no alpha)
        throw Err("Not yet implemented")

      case 2:
        // 8/16-bit RGB (no alpha)
        dataPixels = png.imgData

      case 3:
        // indexed
        arr := space as PdfArray
        dataPixels  = png.imgData
        dataPalette = arr[3]

      case 4:
        // grayscale w/ alpha
        throw Err("Not yet implemented")

      case 6:
        // 8/16-bit RGB w/ alpha
        temp := splitAlpha(png)
        dataPixels = temp[0]
        dataAlpha  = temp.getSafe(1)
    }

    // palette
    if (dataPalette != null)
    {
      palette := PdfBufStream(dataPalette)
      objs.add(palette)
      arr := space as PdfArray
      arr[3] = PdfObjRef(palette)
    }

    // pixel data
    objs.add(PdfImage(png.uri, dataPixels) {
      it.set("Width",  iw)
      it.set("Height", ih)
      it.set("ColorSpace", space)
      it.set("BitsPerComponent", bits)
      it.set("Filter", "/FlateDecode")
    })

    // alpha mask
    if (dataAlpha != null)
    {
      auri  := `${png.uri}#alpha`
      alpha := PdfImage(auri, dataAlpha) {
        it.set("Width",  iw)
        it.set("Height", ih)
        it.set("BitsPerComponent", 8)
        it.set("Filter",     "/FlateDecode")
        it.set("ColorSpace", "/DeviceGray")
        it.set("Decode",     PdfArray().add(0).add(1))
      }
      pixels := objs[-1] as PdfImage
      pixels.set("SMask", PdfObjRef(alpha))
      objs.add(alpha)
    }

    return objs
  }

  ** Get color space for image.
  private static Obj colorSpace(PngImage png)
  {
    if (png.colorType == 3)
    {
      // indexed
      arr := PdfArray()
      arr.add("/Indexed")
      arr.add("/DeviceRGB")
      arr.add((png.palette.size / 3) - 1)
      arr.add(png.palette)
      return arr
    }

    cs := png["colorSpace"]
    switch(cs)
    {
      case "Gray":  return "/DeviceGray"
      case "RGB":   return "/DeviceRGB"
      case "YCbCr": return "/DeviceRGB"
      case "CMYK":  return "/DeviceCMYK"
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