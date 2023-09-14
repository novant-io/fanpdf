//
// Copyright (c) 2023, Novant LLC
// Licensed under the MIT License
//
// History:
//   14 Sep 2023  Andy Frank  Creation
//

using graphics
using util

*************************************************************************
** PdfGxFont
*************************************************************************

internal const class PdfGxFont
{
  ** Get keyed font name used for 'PdfFont.name'.
  static Str toKey(Font f)
  {
    // TODO: for now only Helvetica
    key := "Helvetica"
    if (f.weight.num > 500) key += "-Bold"
    return key
  }

  ** Encode Font into one PdfFont object.
  static PdfFont encodeFont(Font font)
  {
    name := toKey(font)
    return PdfFont(name)
  }


}