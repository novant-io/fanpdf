//
// Copyright (c) 2023, Novant LLC
// Licensed under the MIT License
//
// History:
//   17 Apr 2023  Andy Frank  Creation
//

*************************************************************************
** PdfWriter
*************************************************************************

class PdfWriter
{

//////////////////////////////////////////////////////////////////////////
// Construction
//////////////////////////////////////////////////////////////////////////

  ** Constructor.
  new make(PdfDoc doc, OutStream out)
  {
    this.doc = doc
    this.out = out
  }

  ** Write PDF doc to outstream.
  This writeDoc()
  {
    // iterate once to assign refs
    doc.eachObj |obj| { assignRef(obj) }

    // render pdf
    writeHeader
    doc.eachObj |obj| { writeIndirectObj(obj) }
    writeXref
    writeTrailer
    out.flush
    return this
  }

  ** Convenience to close parent stream.
  This close()
  {
    out.close
    return this
  }

//////////////////////////////////////////////////////////////////////////
// Structure
//////////////////////////////////////////////////////////////////////////

  ** Write PDF header.
  private Void writeHeader()
  {
    w("%PDF-${ver}\n")
    w("%\u00F0\u00F1\u00F2\u00F3\n")
  }

  ** Write an indirect obj def.
  private Void writeIndirectObj(PdfObj obj)
  {
    obj.ref.offset = offset
    w("${obj.ref.num} ${obj.ref.gen} obj\n")
    writeVal(obj)
    w("\nendobj\n")
  }

  ** Write Xref table.
  private Void writeXref()
  {
    this.startxref = this.offset
    w("xref\n")
    w("0 ${refs.size+1}\n")
    w("0000000000 65535 f\r\n")  // required initial free block
    refs.each |ref|
    {
      off := ref.offset.toStr.padl(10, '0')
      gen := ref.gen.toStr.padl(5, '0')
      w("${off} ${gen} n\r\n")
    }
  }

  ** Write PDF trailer.
  private Void writeTrailer()
  {
    trailer := PdfDict()
    trailer["Size"] = refs.size + 1 // see writeXref
    trailer["Root"] = doc.catalog.ref

    w("trailer\n")
    writeDict(trailer)
    write('\n')
    w("startxref\n")
    w("${startxref}\n")
    w("%%EOF")
  }

//////////////////////////////////////////////////////////////////////////
// Values
//////////////////////////////////////////////////////////////////////////

  ** Write a value.
  private This writeVal(Obj? val)
  {
    if (val == null)      return w("null")
    if (val is PdfRef)    return writeRef(val)
    if (val is PdfArray)  return writeArray(val)
    if (val is PdfImage)  return writeImage(val) // must be before PdfDict
    if (val is PdfDict)   return writeDict(val)
    if (val is PdfRect)   return writeRect(val)
    if (val is PdfStream) return writeStream(val)
    if (val is Str)       return w(val)
    if (val is Int)       return w(val.toStr)
    throw ArgErr("Unsupported value type '${val.typeof}'")
  }

  ** Write an indirect reference.
  private This writeRef(PdfRef ref)
  {
    w("${ref.num} ${ref.gen} R")
  }

  ** Write a dictionary object.
  private This writeDict(PdfDict dict)
  {
    w("<<\n")
    dict.each |v,k|
    {
      write('/')
      w(k)
      write(' ')
      writeVal(v)
      write('\n')
    }
    return w(">>")
  }

  ** Write an array object.
  private This writeArray(PdfArray array)
  {
    write('[')
    array.each |v,i|
    {
      if (i > 0) write(' ')
      writeVal(v)
    }
    write(']')
    return this
  }

  ** Write a rectangle object.
  private This writeRect(PdfRect rect)
  {
    w("[$rect.lx $rect.ly $rect.ux $rect.uy]")
    return this
  }

  ** Write a stream object.s
  private This writeStream(PdfStream stream)
  {
    w("<< /Length ${stream.text.size} >>\n")
    w("stream\n")
    w(stream.text)
    w("\nendstream")
    return this
  }

  ** Write an image object.
  private This writeImage(PdfImage img)
  {
    writeDict(img)
    w("\nstream\n")
    for (i := 0; i<img.stream.size; i++) write(img.stream[i])
    w("\nendstream")
    return this
  }

//////////////////////////////////////////////////////////////////////////
// Support
//////////////////////////////////////////////////////////////////////////

  ** Assign indirect ref to given object if not already assigned.
  private PdfObj assignRef(PdfObj obj)
  {
    if (obj.ref == null)
    {
      obj.ref = PdfRef(nextObjNum++)
      refs.add(obj.ref)
    }
    return obj
  }

  private This w(Str str)
  {
    for (i:=0; i<str.size; i++) write(str[i])
    return this
  }

  private This write(Int ch)
  {
    out.write(ch)
    offset++
    return this
  }

  private const Str ver := "1.7"    // PDF format version
  private PdfDoc doc                // doc to render
  private OutStream out             // parent outstream
  private Int offset                // current byte position
  private Int startxref             // offset of start of xref table
  private Int nextObjNum := 1       // next objnum to assign
  private PdfRef[] refs  := [,]     // list of indirect refs created
}
