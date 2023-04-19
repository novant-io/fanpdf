//
// Copyright (c) 2023, Novant LLC
// Licensed under the MIT License
//
// History:
//   19 Apr 2023  Andy Frank  Creation
//

using graphics

*************************************************************************
** PdfGraphics
*************************************************************************

class PdfGraphics // : Graphics
{
  ** Create a new graphics context for given `PdfPage`.
  new make(PdfPage page)
  {
    this.size = page.resolvePageSize
  }

  ** Convert current instance state to a `PdfObj`.
  PdfObj toPdfObj()
  {
    PdfStream(buf.toStr)
  }

  ** Draw a line.
  This drawLine(Float x1, Float y1, Float x2, Float y2)
  {
    w("${x1} ${py(y1)} m ${x2} ${py(y2)} l S\n")
    return this
  }

  ** Draw a rectangle.
  This drawRect(Float x, Float y, Float w, Float h)
  {
    this.w("${x} ${py(y)} m ")
    this.w("${x+w} ${py(y)} l ")
    this.w("${x+w} ${py(y+h)} l ")
    this.w("${x} ${py(y+h)} l ")
    this.w("s\n")
    return this
  }

  ** Get y value relative to pdf page (which is inverted from gx space).
  private Float py(Float v) { size.h - v }

  ** Write string to stream buf.
  private This w(Str s) { buf.add(s); return this }

  private StrBuf buf := StrBuf()   // backing Stream contents
  private Size size                // size of this gx coord space
}