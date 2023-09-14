# FanPDF

[Fantom](https://fantom.org) library for creating PDF documents.

Under Construction.

```fantom
// create a new pdf doc
doc  := PdfDoc()
page := doc.catalog.pages.addPage
doc.catalog.pages.addFont(PdfFont("Helvetica"))

// create a graphics context for this page
gx := PdfGraphics(page)

// page background
gx.color = Color("#f2f2f2")
gx.fillRect(36f, 36f, doc.pageSize.w-72f, doc.pageSize.h-72f)

// page border
gx.color = Color("#d9d9d9")
gx.drawRect(36f, 36f, doc.pageSize.w-72f, doc.pageSize.h-72f)

// line
gx.color = Color("#f00")
gx.drawLine(46f, 46f, doc.pageSize.w-46f, doc.pageSize.h-46f)

// text
gx.color = Color("#00f")
gx.drawText("Hello, World", 100f, 100f)

// image
png := Env.cur.workDir + `src/fanpdf/doc/icon.png`
img := GraphicsEnv.cur.image(png.uri)
gx.drawImage(img, 200f, 200f, 32f, 32f)

// add graphics to page
page.addContent(gx.toPdfObj)

// render file content to stdout
out := Env.cur.out
PdfWriter(doc, out).writeDoc.close
```