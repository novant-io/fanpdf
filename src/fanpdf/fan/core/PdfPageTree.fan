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

  ** Get a font by name, or 'null' if not found
  PdfFont? font(Str name) { fontMap[name] }

  ** Add a font resource to tree.
  PdfFont addFont(PdfFont font)
  {
    // check if already exists
    if (fontMap[font.name] != null)
      throw ArgErr("Font already exists '${font.name}'")

    // add resource
    font.id = "F${fontMap.size}"
    fontMap.add(font.name, font)
    return font
  }

  ** Create a /Font dictionary instance.
  private PdfDict fontDict()
  {
    dict := PdfDict()
    fontMap.each |f| { dict[f.id] = f.ref }
    return dict
  }

//////////////////////////////////////////////////////////////////////////
// Images
//////////////////////////////////////////////////////////////////////////

  ** Get image resource by uri, or 'null' if not found.
  PdfImage? image(Uri uri) { imgMap[uri] }

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
// Misg
//////////////////////////////////////////////////////////////////////////

  Void addMisc(PdfObj obj)
  {
    misc.add(obj)
  }

//////////////////////////////////////////////////////////////////////////
// PdfDict
//////////////////////////////////////////////////////////////////////////

  override Void each(|Obj?,Str| f)
  {
    // create child ref ids
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
  internal Str:PdfFont fontMap := [:]  // font resource list
  internal Uri:PdfImage imgMap := [:]  // image resource map
  internal PdfObj[] misc       := [,]  // misc object list
}