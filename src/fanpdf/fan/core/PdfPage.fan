//
// Copyright (c) 2023, Novant LLC
// Licensed under the MIT License
//
// History:
//   18 Apr 2023  Andy Frank  Creation
//

using graphics

*************************************************************************
** PdfPage
*************************************************************************

** PdfPage models a single page in a `PdfPageTree`.
class PdfPage : PdfDict
{
  ** It-block constructor.
  new make(|This|? f := null)
  {
    this.set("Type", "/Page")
    if (f != null) f(this)
  }

  ** Page size for this page, or if 'null' use document default.
  const Size? pageSize

  ** Page margines for this page, or if 'null' use document default.
  const Size? pageMargins

  ** Add content to this page.
  This addContent(PdfObj obj)
  {
    content.add(obj)
    return this
  }

  override Void each(|Obj?,Str| f)
  {
    // get page size
    mb := resolvePageSize
    // cb := pageMargins ?: parent.catalog.doc.pageMargins

    // generate content indirect refs
    crefs := PdfArray()
    content.each |c| { crefs.add(c.ref) }

    // computed entries
    f(parent.ref, "Parent")
    // res is inherited from pagetree
    // f(PdfDict(), "Resources")
    f(crefs, "Contents")
    f(PdfRect(0, 0, mb.w.toInt, mb.h.toInt), "MediaBox")
    // f(PdfRect(...), "CropBox")

    // delegate to parent impl
    super.each(f)
  }

  ** Get page size or inherited page size.
  internal Size resolvePageSize() { pageSize ?: parent.catalog.doc.pageSize }

  internal PdfPageTree? parent      // reference to parent page tree
  internal PdfObj[] content := [,]  // contents obj list
}