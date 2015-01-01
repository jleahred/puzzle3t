library setup;

import 'dart:html';
import 'package:puzzle/plain.dart';
import 'dart:async';
import 'package:puzzle/log.dart';
import 'package:puzzle/randomize.dart';
import 'package:puzzle/images.dart';
import 'package:puzzle/draw_support.dart';


Config _config;


enum ImageType { PICTURE, NUMBERS, COLORS, TWO_COLORS }

class Config {
  var rows = 4;
  var cols = 4;
  ImageType  imageType = ImageType.PICTURE;

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
  RadioButtonInputElement radioPicture = querySelector("#radio_picture");
  RadioButtonInputElement radioNumbers = querySelector("#radio_numbers");
  RadioButtonInputElement radioColors = querySelector("#radio_colors");
  RadioButtonInputElement radio2Colors = querySelector("#radio_2colors");
  SelectElement imageList = querySelector("#image_list");

  _ConfigWidgets() {
    querySelector("#randomize_button").onClick.listen((_) => _randomizePuzzle());

    cols.onChange.listen((_) => updateFromHTMLSetup());
    rows.onChange.listen((_) => updateFromHTMLSetup());
    radioPicture.onChange.listen((_) => updateFromHTMLSetup());
    radioNumbers.onChange.listen((_) => updateFromHTMLSetup());
    radioColors.onChange.listen((_) => updateFromHTMLSetup());
    radio2Colors.onChange.listen((_) => updateFromHTMLSetup());

    for(var imageName in localImages){
      OptionElement option = new OptionElement();
      option.text = imageName;
      imageList.children.add(option);
    }
    imageList.onChange.listen((_) => updateFromHTMLSetup());
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

  switch(_config.imageType) {
    case ImageType.PICTURE:
      _config._widgets.radioPicture.checked = true;
      break;
    case ImageType.NUMBERS:
      _config._widgets.radioNumbers.checked = true;
      break;
    case ImageType.COLORS:
      _config._widgets.radioColors.checked = true;
      break;
    case ImageType.TWO_COLORS:
      _config._widgets.radio2Colors.checked = true;
      break;
  }

  updateFromHTMLSetup();
  writeLog("end updateHTMLFromSetup");
}

void updateFromHTMLSetup() {
  writeLog("init updateFromHTMLSetup");
  if (_config == null) {
    _config = new Config();
  }

  if(_config._widgets.radioPicture.checked)
  {
    _config.imageType = ImageType.PICTURE;
  } else if(_config._widgets.radioNumbers.checked) {
    _config.imageType = ImageType.NUMBERS;
  } else if(_config._widgets.radioColors.checked) {
    _config.imageType = ImageType.COLORS;
  } else if(_config._widgets.radio2Colors.checked) {
    _config.imageType = ImageType.TWO_COLORS;
  }

  switch(_config.imageType) {
    case ImageType.PICTURE:
      _config._widgets.imageList.hidden = false;
      prepareImageFromServerFile("images/" + localImages[_config._widgets.imageList.selectedIndex], _config, _config._onModif.add);
      break;
    case ImageType.NUMBERS:
      _config._widgets.imageList.hidden = true;
      prepareCanvasNumbers(_config);
      break;
    case ImageType.COLORS:
      _config._widgets.imageList.hidden = true;
      prepareCanvasColors(_config);
      break;
    case ImageType.TWO_COLORS:
      _config._widgets.imageList.hidden = true;
      prepareCanvas2Colors(_config);
      break;
  }

  _config.cols = _config._widgets.cols.valueAsNumber.toInt();
  _config.rows = _config._widgets.rows.valueAsNumber.toInt();

  _config._update();
  writeLog("end updateFromHTMLSetup");
}

