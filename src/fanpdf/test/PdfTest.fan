//
// Copyright (c) 2023, Novant LLC
// Licensed under the MIT License
//
// History:
//   17 Apr 2023  Andy Frank  Creation
//

using graphics

*************************************************************************
** PdfTest
*************************************************************************

class PdfTest
{
  static Void main()
  {
    doc  := PdfDoc()
    page := doc.catalog.pages.addPage
    doc.catalog.pages.addFont(PdfFont("Helvetica"))

    gx := PdfGraphics(doc, page)
    gx.color = Color("#f2f2f2")
    gx.fillRect(36f, 36f, doc.pageSize.w-72, doc.pageSize.h-72f)
    gx.color = Color("#d9d9d9")
    gx.drawRect(36f, 36f, doc.pageSize.w-72, doc.pageSize.h-72f)

    gx.color = Color("#f00")
    gx.drawLine(46f, 46f, doc.pageSize.w-46f, doc.pageSize.h-46f)

    gx.color = Color("#3b82f6")
    gx.drawLine(46f, 46f, 400f, 400f)

    gx.color = Color("#0f0")
    gx.drawRect(300f, 100f, 200f, 100f)
    gx.color = Color("#f00")
    gx.drawOval(300f, 100f, 200f, 100f)
    gx.fillOval(310f, 110f, 180f, 80f)

    // gx.font = Font("12pt Comic Sans")
    gx.font = Font("10pt Helvetica")
    gx.color = Color("#94a3b8")
    gx.drawText("Hello, World", 100f, 100f)

    gx.font = Font("bold 12pt Helvetica")
    gx.color = Color("#6366f1")
    gx.drawText("How are you doing?", 100f, 120f)

    png := Env.cur.workDir + `src/fanpdf/doc/icon.png`
    img := GraphicsEnv.cur.image(png.uri)
    gx.drawImage(img, 200f, 200f, 32f, 32f)
    gx.drawImage(img, 232f, 232f, 32f, 32f)

    png = Env.cur.workDir + `test/fanbars.png`
    img = GraphicsEnv.cur.image(png.uri)
    gx.drawImage(img, 264f, 264f, 32f, 32f)

    png = Env.cur.workDir + `test/bar.png`
    img = GraphicsEnv.cur.image(png.uri)
    gx.drawImage(img, 400f, 400f, 100f, 100f)

    page.addContent(gx.toPdfObj)

    out := Env.cur.out
    PdfWriter(doc, out).writeDoc.close
  }
}
