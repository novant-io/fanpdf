//
// Copyright (c) 2023, Novant LLC
// Licensed under the MIT License
//
// History:
//   18 Apr 2023  Andy Frank  Creation
//

using graphics

*************************************************************************
** PdfPageTree
*************************************************************************

** PdfPageTree manages the list of pages in a `PdfCatalog`.
class PdfPageTree : PdfDict
{
  ** Add a new page to tree.
  PdfPage addPage(PdfPage? page := null)
  {
    p := page ?: PdfPage()
    p.parent = this
    list.add(p)
    return p
  }

  ** List of resources common to all pages.
  PdfObj[] res := [,]

  override const Str? type := "Pages"

  override Void each(|Obj?,Str| f)
  {
    // create child ref lis
    refs := PdfArray()
    list.each |p| { refs.add(p.ref) }

    // create resource dict
    fonts := PdfDict()
    res.each |r,i|
    {
      // TODO FXIIT; how does naming work?
      fonts["F${i}"] = r.ref
    }
    resd := PdfDict()
    resd["Fonts"] = fonts

    // computed entries
    f(list.size, "Count")
    f(refs, "Kids")
    f(resd, "Resources")

    // delegate to parent impl
    super.each(f)
  }

  // refrence to parent catalog
  internal PdfCatalog? catalog

  // List of pages in this pagetree
  internal PdfPage[] list := [,]
}