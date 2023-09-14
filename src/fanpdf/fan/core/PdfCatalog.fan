//
// Copyright (c) 2023, Novant LLC
// Licensed under the MIT License
//
// History:
//   18 Apr 2023  Andy Frank  Creation
//

using graphics

*************************************************************************
** PdfCatalog
*************************************************************************

** PdfCatalog models the root elements in a `PdfDoc`.
class PdfCatalog : PdfDict
{
  new make()
  {
    this.set("Type", "/Catalog")
    this.pages = PdfPageTree()
    this.pages.catalog = this
  }

  ** PageTree for this catalog.
  PdfPageTree pages { private set }

  override Void each(|Obj?,Str| f)
  {
    f(pages.ref, "Pages")
    super.each(f)
  }

  // refrence to parent doc
  internal PdfDoc? doc
}