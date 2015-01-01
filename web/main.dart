// Copyright (c) 2014, <your name>. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import 'dart:html';
import 'package:puzzle/setup.dart';
import 'package:puzzle/log.dart';
import 'package:markdown/markdown.dart';


void main() {
  writeLog("Running program");
  _prepareReadme();
  updateHTMLFromSetup();
}


void _prepareReadme() {
  writeLog("Requested readme file to server");
  var readmeText = new ParagraphElement();

  querySelector("#readme_div").children.add(readmeText);
  HttpRequest.getString("README.md").then((text) {
    readmeText.appendHtml(markdownToHtml(text));
    writeLog("Received readme.md from server and rendered on page");
  });
}
