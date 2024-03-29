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
  new make(PdfDoc doc, PdfPage page)
  {
    this.doc  = doc
    this.page = page
    this.size = page.resolvePageSize

    // init fields with setter to render state
    this.paint = Color.black
    this.font  = Font.fromStr("12pt Helvetica")
  }

  ** Size of canvas for this graphics instance.
  const Size size

  ** Convert current instance state to a `PdfObj`.
  PdfObj toPdfObj()
  {
    PdfStrStream(buf.toStr)
  }

//////////////////////////////////////////////////////////////////////////
// Graphics Impl
//////////////////////////////////////////////////////////////////////////

  ** Convenience for setting paint to a solid color.
  override Color color := Color.black
  {
    set
    {
      &color = it
      paint = it
    }
  }

  ** Current stroke defines how the shapes are outlined.
  override Stroke stroke := Stroke.defVal
  {
    set
    {
      &stroke = it
      w("${it.width} w\n")
    }
  }

  ** Current paint defines how text and shapes are stroked and filled.
  override Paint paint
  {
    set
    {
      c := it.asColorPaint
      r := c.r.toFloat / 255f
      g := c.g.toFloat / 255f
      b := c.b.toFloat / 255f
      w("${r} ${g} ${b} rg ")
      w("${r} ${g} ${b} RG\n")
      &paint = it
    }
  }

  ** Current font used for `drawText`.
  override Font font
  {
    set
    {
      // get or add font
      fk := PdfGxFont.toKey(it)
      pf := doc.catalog.pages.font(fk)
      if (pf == null) doc.catalog.pages.addFont(pf = PdfGxFont.encodeFont(it))
      w("BT /${pf.id} ${it.size} Tf ET\n")
      &font = it
    }
  }

  ** Push a new graphics state onto stack.
  override This push(Rect? r := null)
  {
    this.w("q\n")
    if (r != null)
    {
      translate(r.x, r.y)
      clipRect(0f, 0f, r.w, r.h)
    }
    return this
  }

  ** Pop last graphics state of stack.
  override This pop()
  {
    txstack.pop
    return this.w("Q\n")
  }

  ** Convenience to clip the given the rectangle.
  override This clipRect(Float x, Float y, Float w, Float h)
  {
    this.w("${x} ${py(y)} m ")
    this.w("${x+w} ${py(y)} l ")
    this.w("${x+w} ${py(y+h)} l ")
    this.w("${x} ${py(y+h)} l ")
    this.w(" W n\n")
    return this
  }

  ** Translate the coordinate system to the new origin.
  override This translate(Float x, Float y)
  {
    this.w("1 0 0 1 ${x} -${y} cm\n")
    return this
  }

  ** Apply transform to current state.
  override This transform(Transform tx)
  {
    txstack.push(tx)
    this.w("${tx.a} ${tx.b} ${tx.c} ${tx.d} ${tx.e} -${tx.f} cm\n")
    return this
  }

  ** Draw a line.
  override This drawLine(Float x1, Float y1, Float x2, Float y2)
  {
    this.w("${x1} ${py(y1)} m ${x2} ${py(y2)} l S\n")
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

  ** Draw an ellipse within the given bounds.
  override This drawEllipse(Float x, Float y, Float w, Float h)
  {
    // TODO: this is bit janky; I think we need four curves
    w2 := w / 2
    w3 := w * 2 / 3f
    h2 := h / 2f
    cx := x + w2
    cy := y + h2
    this.w("${cx} ${py(cy-h2)} m ")
    this.w("${cx+w3} ${py(cy-h2)} ${cx+w3} ${py(cy+h2)} ${cx} ${py(cy+h2)} c ")
    this.w("${cx-w3} ${py(cy+h2)} ${cx-w3} ${py(cy-h2)} ${cx} ${py(cy-h2)} c ")
    this.w("s\n")
    return this
  }

  ** Fill an ellipse within the given bounds.
  override This fillEllipse(Float x, Float y, Float w, Float h)
  {
    // TODO: this is bit janky; I think we need four curves
    w2 := w / 2
    w3 := w * 2 / 3f
    h2 := h / 2f
    cx := x + w2
    cy := y + h2
    this.w("${cx} ${py(cy-h2)} m ")
    this.w("${cx+w3} ${py(cy-h2)} ${cx+w3} ${py(cy+h2)} ${cx} ${py(cy+h2)} c ")
    this.w("${cx-w3} ${py(cy+h2)} ${cx-w3} ${py(cy-h2)} ${cx} ${py(cy-h2)} c ")
    this.w("f\n")
    return this
  }

  ** Draw a text string.
  override This drawText(Str text, Float x, Float y)
  {
    this.w("BT ${x} ${py(y)} TD (${text}) Tj ET\n")
    return this
  }

  ** Draw an image.
  override This drawImage(Image img, Float x, Float y, Float w := img.w(), Float h := img.h())
  {
    // add PdfImage if not already added
    pdfimg := doc.catalog.pages.image(img.uri)
    if (pdfimg == null)
    {
      objs := PdfGxImg.encodeImage(img)
      objs.each |obj|
      {
        if (obj is PdfImage) doc.catalog.pages.addImage(obj)
        else doc.catalog.pages.addMisc(obj)
      }
      pdfimg = objs.findType(PdfImage#).first
    }

    // render image to page
    this.w("q\n")
    this.w("${w} 0 0 ${h} ${x} ${py(y+h)} cm\n")
    this.w("/${pdfimg.id} Do\n")
    this.w("Q\n")
    return this
  }

  ** Get 'FontMetrics' for current font.
  override FontMetrics metrics()
  {
    font.metrics(deviceCx)
  }

  // TODO FIXIT

  override Float alpha   := 1f
  override Void dispose() { throw Err() }

  override This drawImageRegion(Image img, Rect src, Rect dst) { throw Err() }
  override This drawRoundRect(Float x, Float y, Float w, Float h, Float wArc, Float hArc) { throw Err() }
  override This fillRoundRect(Float x, Float y, Float w, Float h, Float wArc, Float hArc) { throw Err() }
  override This clipRoundRect(Float x, Float y, Float w, Float h, Float wArc, Float hArc) { throw Err() }
  override GraphicsPath path() { throw Err() }

  ** Get y value relative to pdf page (which is inverted from gx space).
  private Float py(Float v)
  {
    tx := txstack.last ?: defTx
    if (tx.d == 1f) return size.h - v

    // TODO FIXIT: this only works if we have a single transform
    // and they are bounded by push/pop ops
    return size.h / tx.d - v
  }

  ** Write string to stream buf.
  private This w(Str s) { buf.add(s); return this }

  private DeviceContext deviceCx := DeviceContext(72f)

  // TODO: see py()
  private static const Transform defTx := Transform(1f, 0f, 0f, 1f, 0f, 0f)
  private Transform[] txstack := [defTx]

  private PdfDoc doc               // parent doc instance
  private PdfPage page             // parent page instance
  private StrBuf buf := StrBuf()   // backing Stream contents
}