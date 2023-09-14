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
  ** Constructor.
  new make()
  {
    this.set("Type", "/Pages")
  }

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
    dict := PdfDict()
    fontList.each |f| { dict[f.id] = f.ref }
    return dict
  }

//////////////////////////////////////////////////////////////////////////
// Images
//////////////////////////////////////////////////////////////////////////

  ** Get image resource by uri, or 'null' if not found.
  PdfImage? getImage(Uri uri) { imgMap[uri] }

  ** Add an image resource to tree.
  PdfImage addImage(PdfImage img)
  {
    // check if already exists
    if (imgMap[img.uri] != null)
      throw ArgErr("Image already exists '${img.uri}'")

    // add resource
    img.id = "Img${imgMap.size}"
    imgMap.add(img.uri, img)
    return img
  }

  ** Create a /XObject dictionary instance.
  private PdfDict imgDict()
  {
    dict := PdfDict()
    imgMap.each |r| { dict[r.id] = r.ref }
    return dict
  }

//////////////////////////////////////////////////////////////////////////
// PdfDict
//////////////////////////////////////////////////////////////////////////

  override Void each(|Obj?,Str| f)
  {
    // create child ref lis
    refs := PdfArray()
    pageList.each |p| { refs.add(p.ref) }

    // create resource dict
    res := PdfDict()
    res["Font"] = fontDict
    res["XObject"] = imgDict

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

  internal PdfCatalog? catalog         // reference to parent catalog
  internal PdfPage[] pageList  := [,]  // page list
  internal PdfFont[] fontList  := [,]  // font resource list
  internal Uri:PdfImage imgMap := [:]  // image resource map
}