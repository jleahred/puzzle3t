library setup;

import 'dart:html';
import 'package:puzzle/plain.dart';
import 'dart:async';
import 'package:puzzle/log.dart';
import 'package:puzzle/randomize.dart';


Config _config;

class Config {
  var rows = 5;
  var cols = 5;

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
    if(_puzzle!=null) _puzzle.reset();
    _puzzle = new Plain(this);
    writeLog("Config updated");
  }
}

class _ConfigWidgets {
  NumberInputElement cols = querySelector("#range_columns");
  NumberInputElement rows = querySelector("#range_rows");

  _ConfigWidgets() {
    querySelector("#randomize_button").onClick.listen((_) => _randomizePuzzle());

    cols.onChange.listen((_) => updateFromHTMLSetup());
    rows.onChange.listen((_) => updateFromHTMLSetup());
  }
}

void _randomizePuzzle() {
  randomize(_config._puzzle);
}


void updateHTMLFromSetup() {
  writeLog("init updateHTMLFromSetup");
  if (_config == null) {
    _config = new Config();
  }

  _config._widgets.cols.valueAsNumber = _config.cols;
  _config._widgets.rows.valueAsNumber = _config.rows;

  updateFromHTMLSetup();
  writeLog("end updateHTMLFromSetup");
}

void _loadImages() {

}


void updateFromHTMLSetup() {
  writeLog("init updateFromHTMLSetup");
  if (_config == null) {
    _config = new Config();
  }

  if (_config.currentImage == null) {
    _config.currentImage = new ImageElement(src: "images/horse.jpg");
    _config.currentImage.onLoad.listen((_) => _config._onModif.add(_config));
  }

  _config.cols = _config._widgets.cols.valueAsNumber.toInt();
  _config.rows = _config._widgets.rows.valueAsNumber.toInt();

  _config._update();
  writeLog("end updateFromHTMLSetup");
}
