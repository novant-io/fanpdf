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

** PDF implementation of `graphics::Graphics`.
class PdfGraphics : Graphics
{

//////////////////////////////////////////////////////////////////////////
// Construction
//////////////////////////////////////////////////////////////////////////

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

//////////////////////////////////////////////////////////////////////////
// Graphics Impl
//////////////////////////////////////////////////////////////////////////

  ** Convenience for setting paint to a solid color.
  override Color color := Color.black

  ** Current paint defines how text and shapes are stroked and filled.
  override Paint paint := Color.black
  {
    set
    {
      // TODO FIXIT
      if (it isnot Color) throw ArgErr("Only color supported")
      Color c := it
      r := c.r.toFloat / 255f
      g := c.g.toFloat / 255f
      b := c.b.toFloat / 255f
      w("${r} ${g} ${b} rg ")
      w("${r} ${g} ${b} RG\n")
      &paint = it
    }
  }

  ** Draw a line.
  override This drawLine(Float x1, Float y1, Float x2, Float y2)
  {
    w("${x1} ${py(y1)} m ${x2} ${py(y2)} l S\n")
    return this
  }

  ** Draw a rectangle.
  override This drawRect(Float x, Float y, Float w, Float h)
  {
    this.w("${x} ${py(y)} m ")
    this.w("${x+w} ${py(y)} l ")
    this.w("${x+w} ${py(y+h)} l ")
    this.w("${x} ${py(y+h)} l ")
    this.w("s\n")
    return this
  }

  ** Fill a rectangle.
  override This fillRect(Float x, Float y, Float w, Float h)
  {
    this.w("${x} ${py(y)} m ")
    this.w("${x+w} ${py(y)} l ")
    this.w("${x+w} ${py(y+h)} l ")
    this.w("${x} ${py(y+h)} l ")
    this.w("f\n")
    return this
  }

  // TODO FIXIT

  override Stroke stroke := Stroke.defVal
  override Float alpha   := 1f
  override Font font     := Font.fromStr("12pt Helvetica")
  override This clipRect(Float x, Float y, Float w, Float h) { throw Err() }
  override Void dispose() { throw Err() }
  override This drawImage(Image img, Float x, Float y, Float w := img.w(), Float h := img.h()) { throw Err() }
  override This drawImageRegion(Image img, Rect src, Rect dst) { throw Err() }
  override This drawRoundRect(Float x, Float y, Float w, Float h, Float wArc, Float hArc) { throw Err() }
  override This drawText(Str s, Float x, Float y) { throw Err() }
  override This fillRoundRect(Float x, Float y, Float w, Float h, Float wArc, Float hArc) { throw Err() }
  override FontMetrics metrics() { throw Err() }
  override GraphicsPath path() { throw Err() }
  override This pop() { throw Err() }
  override This push(Rect? r := null) { throw Err() }
  override This transform(Transform transform) { throw Err() }
  override This translate(Float x, Float y) { throw Err() }

  ** Get y value relative to pdf page (which is inverted from gx space).
  private Float py(Float v) { size.h - v }

  ** Write string to stream buf.
  private This w(Str s) { buf.add(s); return this }

  private StrBuf buf := StrBuf()   // backing Stream contents
  private Size size                // size of this gx coord space
}