library setup;

import 'dart:html';
import 'package:puzzle/plain.dart';
import 'dart:async';
import 'package:puzzle/log.dart';
import 'package:puzzle/randomize.dart';


Config _config;

class Config {
  var rows = 4;
  var cols = 4;

  _ConfigWidgets _widgets = new _ConfigWidgets();
  var _puzzle;
  ImageElement currentImage;

  var _onModif = new StreamController<Config>.broadcast();
  Stream<Config> get onModif => _onModif.stream;

  Config() {
    writeLog("Creating config");
  }

  void _update() {
    writeLog("Updating config");
    _puzzle = new Plain(this);
    //currentImage = new ImageElement(src: "images/snowman2.png");
    currentImage = new ImageElement(src: "images/lake.jpg");
    currentImage.onLoad.listen((_) => _onModif.add(this));
    writeLog("Config updated");
  }
}

class _ConfigWidgets {
  _ConfigWidgets() {
    querySelector("#randomize_button").onClick.listen((_) => _randomizePuzzle());
  }
}

void _randomizePuzzle() {
  randomize(_config._puzzle);
}


void updateFromSetup() {
  if (_config == null) {
    _config = new Config();
  }
  _config._update();
}

void _loadImages() {

}
