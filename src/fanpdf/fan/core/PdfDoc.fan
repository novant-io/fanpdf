//
// Copyright (c) 2023, Novant LLC
// Licensed under the MIT License
//
// History:
//   17 Apr 2023  Andy Frank  Creation
//

using graphics

*************************************************************************
** PdfDoc
*************************************************************************

** PdfDoc models the document to render to PDF.
class PdfDoc
{
  ** Construct a new 'PdfDoc' instance.
  new make(|This|? f := null)
  {
    this.catalog = PdfCatalog()
    this.catalog.doc = this

    if (f != null) f(this)
  }

  ** Default page size in 1/72 inch points.
  const Size pageSize := Size(612, 792)

  ** Default page margins in 1/72 inch points.
  const Insets pageMargins := Insets(36, 36, 36, 36)

  ** The root document catalog.
  PdfCatalog catalog { private set }

  ** Iterate each object in this document.
  internal Void eachObj(|PdfObj| f)
  {
    // TODO FIXIT: not sure how this works yet
    f(catalog)
    f(catalog.pages)
    catalog.pages.res.each |r| { f(r) }
    catalog.pages.list.each |p|
    {
      p.content.each |c| { f(c) }
      f(p)
    }
  }
}
