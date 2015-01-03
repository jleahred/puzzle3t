library setup;

import 'dart:html';
import 'package:puzzle/plain.dart';
import 'package:puzzle/cylinder.dart';
import 'dart:async';
import 'package:puzzle/log.dart';
import 'package:puzzle/randomize.dart';
import 'package:puzzle/images.dart';
import 'package:puzzle/draw_support.dart';
import 'package:puzzle/toroidal.dart';


Config _config;


enum Topology { PLAIN, CYLINDER, TOROIDAL }
enum ImageType { PICTURE, NUMBERS, COLORS, TWO_COLORS }

class Config {
  var topology = Topology.PLAIN;
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

    if(_widgets.topology.selectedIndex == 0) {
      _puzzle = new Plain(this);
    } else if(_widgets.topology.selectedIndex == 1) {
      _puzzle = new Cylinder(this);
    } else if(_widgets.topology.selectedIndex == 2) {
      _puzzle = new Toroidal(this);
    }
    writeLog("Config updated");
  }
}

class _ConfigWidgets {
  SelectElement topology = querySelector("#topology_select");
  NumberInputElement cols = querySelector("#range_columns");
  NumberInputElement rows = querySelector("#range_rows");
  RadioButtonInputElement radioPicture = querySelector("#radio_picture");
  RadioButtonInputElement radioNumbers = querySelector("#radio_numbers");
  RadioButtonInputElement radioColors = querySelector("#radio_colors");
  RadioButtonInputElement radio2Colors = querySelector("#radio_2colors");
  SelectElement imageList = querySelector("#image_list");

  _ConfigWidgets() {
    querySelector("#randomize_button").onClick.listen((_) => _randomizePuzzle());
    querySelector("#setup_button").onClick.listen((_) => _showHideDivs(querySelector("#setup_div"), querySelector("#readme_div")));
    querySelector("#readme_button").onClick.listen((_) => _showHideDivs(querySelector("#readme_div"), querySelector("#setup_div")));


    topology.onChange.listen((_) => updateFromHTMLSetup());
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


void _showHideDivs(var div1, var div2){
  if(div1.style.display != "") {
    div1.style.display = "";
  } else {
    div1.style.display = "none";
  }
  div2.style.display = "none";
}

void _randomizePuzzle() {
  randomize(_config._puzzle);
}


void updateHTMLFromSetup() {
  writeLog("init updateHTMLFromSetup");
  if (_config == null) {
    _config = new Config();
  }

  _config._widgets.topology.selectedIndex = _config.topology.index;
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
      prepareCanvasColors(_config);
      break;
  }

  _config.topology = _config._widgets.topology;

  _config.cols = getValueCheckingBounds(_config._widgets.cols);
  _config.rows = getValueCheckingBounds(_config._widgets.rows);

  _config._update();
  writeLog("end updateFromHTMLSetup");
}

int getValueCheckingBounds(var widget) {
  if(widget.valueAsNumber.toInt() > int.parse(widget.max)) {
    widget.valueAsNumber = int.parse(widget.max);
  }
  return widget.valueAsNumber.toInt();
}
