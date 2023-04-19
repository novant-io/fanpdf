//
// Copyright (c) 2023, Novant LLC
// Licensed under the MIT License
//
// History:
//   18 Apr 2023  Andy Frank  Creation
//

*************************************************************************
** PdfRef
*************************************************************************

** PdfRef models a indirect object reference
internal class PdfRef
{
  ** Construct a new 'PdfDoc' instance.
  new make(Int num, Int gen := 0)
  {
    this.num = num
    this.gen = gen
  }

  ** Object number for this reference.
  const Int num

  ** Generation number for this reference.
  const Int gen

  ** Byte offset of reference in document.
  Int? offset
}