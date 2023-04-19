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

    gx := PdfGraphics(page)
    gx.paint = Color("#f2f2f2")
    gx.fillRect(36f, 36f, doc.pageSize.w-72, doc.pageSize.h-72f)
    gx.paint = Color("#d9d9d9")
    gx.drawRect(36f, 36f, doc.pageSize.w-72, doc.pageSize.h-72f)

    gx.paint = Color("#f00")
    gx.drawLine(46f, 46f, doc.pageSize.w-46f, doc.pageSize.h-46f)
    page.addContent(gx.toPdfObj)

    out := Env.cur.out
    PdfWriter(doc, out).writeDoc.close
  }
}
