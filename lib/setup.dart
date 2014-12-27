library setup;

import 'dart:html';
import 'package:puzzle/plain.dart';


Config  _config;

class Config {
  var rows = 4;
  var cols = 4;

  ConfigWidgets widgets = new ConfigWidgets();
}

class ConfigWidgets {
}


void updateFromSetup() {
  if(_config==null) {
    _config = new Config();
    _loadImages();
  }
  var puzzle = createPlain(_config);
}

void _loadImages() {

}