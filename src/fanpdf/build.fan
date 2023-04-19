#! /usr/bin/env fan

using build

class Build : build::BuildPod
{
  new make()
  {
    podName = "fanpdf"
    summary = "Fantom library for creating PDF documents"
    version = Version("0.2")
    meta = [
      "org.name":     "Novant",
      "org.uri":      "https://novant.io/",
      "license.name": "MIT",
      "vcs.name":     "Git",
      "vcs.uri":      "https://github.com/novant-io/fanpdf",
      "repo.public":  "true"
    ]
    depends = [
      "sys 1.0",
      "util 1.0",
      "graphics 1.0",
    ]
    resDirs = [`doc/`]
    srcDirs = [
      `fan/core/`,
      `fan/gx/`,
      `fan/writer/`,
      `test/`
    ]
    docApi  = true
    docSrc  = true
  }
}
