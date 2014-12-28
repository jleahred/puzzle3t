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
  final int row, col;
  Possition(this.row, this.col);
}



CanvasRenderingContext2D _catchedContext;
CanvasElement _catchedCanvas;


bool prepareImage(Config config) {
  if (config.currentImage == null || config.currentImage.width == 0) {
    writeLog("draw_support: Image not ready");
    return false;
  }
  writeLog("draw_support: Preparing image");
  var image = config.currentImage;
  var scale = getScale(image);

  var cwidth = image.width * scale;
  cwidth = cwidth ~/ config.cols * config.cols + config.cols - 1;
  var cheight = image.height * scale;
  cheight = cheight ~/ config.rows * config.rows + config.rows - 1;
  var ipieze_width = image.width / config.cols;
  var ipieze_height = image.height / config.rows;
  CanvasElement canvas = getCanvas();
  canvas
      ..width = cwidth
      ..height = cheight;
  var context = getContext();
  context
      ..fillStyle = "rgba(0, 0, 0, 1)"
      ..fillRect(0, 0, cwidth, cheight);

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



num getScale(ImageElement image) {
  //var scalew = 1.0;
  //var scaleh = 1.0;
  //if (image.width > 1000) scalew = 1000.0 / image.width;
  //if (image.height > 1000) scaleh = 1000.0 / image.height;
  var scalew = 1000.0 / image.width;
  var scaleh = 800.0 / image.height;
  return min(scalew, scaleh);
}



Rect getRectPos(int row, int col, Config config) {
  var image = config.currentImage;

  var scale = getScale(image);

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
    _catchedContext= null;
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
