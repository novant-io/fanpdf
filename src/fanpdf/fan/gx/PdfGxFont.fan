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
  ** Encode Font into one PdfFont object.
  static PdfFont encodeFont(Font font)
  {
    name := toFontName(font)
    return PdfFont(name)
  }

  private static Str toFontName(Font font)
  {
    // TODO: for now only Helvetica
    return "Helvetica"
  }
}