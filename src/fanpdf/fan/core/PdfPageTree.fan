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

//////////////////////////////////////////////////////////////////////////
// Pages
//////////////////////////////////////////////////////////////////////////

  ** Add a new page to tree.
  PdfPage addPage(PdfPage? page := null)
  {
    p := page ?: PdfPage()
    p.parent = this
    pageList.add(p)
    return p
  }

//////////////////////////////////////////////////////////////////////////
// Fonts
//////////////////////////////////////////////////////////////////////////

  ** Add a font resource to tree.
  PdfFont addFont(PdfFont font)
  {
    font.id = "F${fontList.size}"
    fontList.add(font)
    return font
  }

  ** Get a font added by `addFont` or throw 'ArgErr' if not found.
  internal PdfFont getFont(Str name)
  {
    fontList.find |f| { f.name == name } ?: throw ArgErr("Font not added '${name}'")
  }

  ** Create a /Font dictionary instance.
  private PdfDict fontDict()
  {
    fonts := PdfDict()
    fontList.each |f| { fonts[f.id] = f.ref }
    return fonts
  }

//////////////////////////////////////////////////////////////////////////
// PdfDict
//////////////////////////////////////////////////////////////////////////

  override const Str? type := "Pages"

  override Void each(|Obj?,Str| f)
  {
    // create child ref lis
    refs := PdfArray()
    pageList.each |p| { refs.add(p.ref) }

    // create resource dict
    res := PdfDict()
    res["Font"] = fontDict

    // computed entries
    f(pageList.size, "Count")
    f(refs, "Kids")
    f(res, "Resources")

    // delegate to parent impl
    super.each(f)
  }

//////////////////////////////////////////////////////////////////////////
// Fields
//////////////////////////////////////////////////////////////////////////

  internal PdfCatalog? catalog        // reference to parent catalog
  internal PdfPage[] pageList := [,]  // page list
  internal PdfFont[] fontList := [,]  // font list
}