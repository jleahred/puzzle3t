library draw_support;


import 'package:puzzle/setup.dart';
import 'dart:html';
import 'package:puzzle/log.dart';
import 'dart:math';
import 'package:range/range.dart';


class Rect {
  final int x;
  final int y;
  final int width;
  final int height;

  Rect(this.x, this.y, this.width, this.height);
}


class Possition {
  int row, col;
  Possition(this.row, this.col);

  bool operator==(Possition other) {
    if(other.row == row  &&  other.col==col)  return true;
    else return false;
  }
}



CanvasRenderingContext2D _catchedContext;
CanvasElement _catchedCanvas;


bool prepareImage(Config config) {
  switch (config.imageType) {
    case ImageType.PICTURE:
      return _prepareImageFromServerFile(config);
    case ImageType.NUMBERS:
      return prepareCanvasNumbers(config);
    case ImageType.COLORS:
      return prepareCanvasColors(config);
    case ImageType.TWO_COLORS:
      return prepareCanvasColors(config);
  }
}

void _normalizeCanvasSize(Config config) {
  CanvasElement canvas = getCanvas();
  canvas
      ..width = canvas.width ~/ config.cols * config.cols + config.cols - 1
      ..height = canvas.height ~/ config.rows * config.rows + config.rows - 1;
}

bool _prepareImageFromServerFile(Config config) {
  if (config.currentImage == null || config.currentImage.width == 0) {
    writeLog("draw_support: Image not ready");
    return false;
  }
  writeLog("draw_support: Preparing image");
  var image = config.currentImage;
  var scale = getScaleFromImage(image);

  CanvasElement canvas = getCanvas();
  canvas
      ..width = (image.width * scale).toInt()
      ..height = (image.height * scale).toInt();
  _normalizeCanvasSize(config);
  var ipieze_width = image.width / config.cols;
  var ipieze_height = image.height / config.rows;
  var context = getContext();
  context
      ..fillStyle = "rgba(0, 0, 0, 1)"
      ..fillRect(0, 0, canvas.width, canvas.height);

  for (int c in range(config.cols)) {
    for (int r in range(config.rows)) {
      var ix = c * image.width / config.cols;
      var iy = r * image.height / config.rows;

      var rect = getRectPos(r, c, config);
      context.drawImageScaledFromSource(image, ix, iy, ipieze_width, ipieze_height, rect.x, rect.y, rect.width, rect.height);
    }
  }
  writeLog("draw_support: Image ready");
  return true;
}



num getScaleFromImage(ImageElement image) {
  return getScaleWH(image.width, image.height);
}

num getScaleWH(int width, int height) {
  var scalew = 1000.0 / width;
  var scaleh = 800.0 / height;
  return min(scalew, scaleh);
}



Rect getRectPos(int row, int col, Config config) {
  var image = config.currentImage;

  var scale = getScaleFromImage(image);

  var piezeWidth = getPiezeWidth(config);
  var piezeHeight = getPiezeHeight(config);

  var x = col * piezeWidth + col;
  var y = row * piezeHeight + row;
  return new Rect(x, y, piezeWidth, piezeHeight);
}


CanvasElement getCanvas() {
  if (_catchedCanvas == null) {
    resetCanvas();
  }
  return _catchedCanvas;
}

CanvasElement resetCanvas() {
  if (_catchedCanvas != null) {
    _catchedCanvas.remove();
    _catchedContext = null;
  }
  _catchedCanvas = new CanvasElement();
  querySelector("#canvas_div").children.add(_catchedCanvas);
  return _catchedCanvas;
}


CanvasRenderingContext2D getContext() {
  if (_catchedContext == null) {
    _catchedContext = getCanvas().context2D;
  }
  return _catchedContext;
}


int getPiezeWidth(Config config) => (getCanvas().clientWidth - (config.cols - 1)) ~/ config.cols;

int getPiezeHeight(Config config) => (getCanvas().clientHeight - (config.rows - 1)) ~/ config.rows;


Possition getPossitionFromCoords(int x, int y, Config config) {
  int row = (y + y ~/ getPiezeHeight(config)) ~/ getPiezeHeight(config);
  int col = (x + x ~/ getPiezeWidth(config)) ~/ getPiezeWidth(config);
  return new Possition(row, col);
}

Possition getPossitionFromCanvasCoords(int x, int y, Config config) {
  var cx = (x - getCanvas().getBoundingClientRect().left).toInt();
  var cy = (y - getCanvas().getBoundingClientRect().top).toInt();

  return getPossitionFromCoords(cx, cy, config);
}

void copyTo(Possition orig, Possition dest, Config config) {
  var context = getContext();
  var rectOrigin = getRectPos(orig.row, orig.col, config);
  var rectDest = getRectPos(dest.row, dest.col, config);
  context.drawImageScaledFromSource(getCanvas(), rectOrigin.x, rectOrigin.y, rectOrigin.width, rectOrigin.height, rectDest.x, rectDest.y, rectDest.width, rectDest.height);
}

CanvasElement  copyToTempCanvas(Possition orig, Config config) {
  var toTempCanvas = new CanvasElement();
  var rectOrigin = getRectPos(orig.row, orig.col, config);
  var context = toTempCanvas.context2D;
  toTempCanvas
      ..width = rectOrigin.width
      ..height = rectOrigin.height;
  context.drawImageScaledFromSource(getCanvas(), rectOrigin.x, rectOrigin.y, rectOrigin.width, rectOrigin.height, 0, 0, rectOrigin.width, rectOrigin.height);

  return toTempCanvas;
}

void copyFromTempCanvas(Possition destiny, CanvasElement fromCanvas, Config config) {
  var rectDest = getRectPos(destiny.row, destiny.col, config);
  var context = getContext();
  context.drawImageScaledFromSource(fromCanvas, 0, 0, fromCanvas.width, fromCanvas.height, rectDest.x, rectDest.y, rectDest.width, rectDest.height);
}

void _prepareCanvasGen(Config config, var drawCell) {
  var canvas = getCanvas();
  var scale = getScaleWH(1000, 800);
  canvas
      ..width = (1000 * scale).toInt()
      ..height = (800 * scale).toInt();
  _normalizeCanvasSize(config);

  getContext()
      ..fillStyle = "black"
      ..fillRect(0, 0, canvas.width, canvas.height)
      ..font = '18pt Arial'
      ..fillStyle = "black";

  int counter = 0;
  for (var r in range(config.rows)) {
    for (var c in range(config.cols)) {
      var rect = getRectPos(r, c, config);
      counter++;

      drawCell(r, c, rect, config);
    }
  }
}


void _drawNumberCell(int r, int c, Rect rect, Config config) {
  var piezeWidth = getPiezeWidth(config);
  var piezeHeight = getPiezeHeight(config);
  getContext()
      ..fillStyle = "white"
      ..fillRect(rect.x, rect.y, rect.width, rect.height)
      ..fillStyle = "blue"
      ..fillText((r * config.cols + c + 1).toString(), rect.x + piezeWidth / 3, rect.y + piezeHeight / 3);
}


bool prepareCanvasNumbers(Config config) {
  _prepareCanvasGen(config, _drawNumberCell);
  return true;
}


void _drawColorCell(int r, int c, Rect rect, Config config) {
  var colors = ["pink", "red", "orange", "yellow", "green", "blue", "gray", "cyan"];
  /*var cr = c * (200 ~/ config.cols) + 50;
  var cg = 200 - c * (100 ~/ (config.cols ~/ 2));
  var cb = 100 - c * (150 ~/ (config.cols ~/ 2)) + 150;
  */
  var nColors = config.imageType == ImageType.TWO_COLORS ? 2 : config.cols;
  getContext()
      ..fillStyle = colors[c % nColors]
      ..fillRect(rect.x, rect.y, rect.width, rect.height);
}

bool prepareCanvasColors(Config config) {
  _prepareCanvasGen(config, _drawColorCell);
  return true;
}


