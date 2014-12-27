library drawTable;


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


void prepareImage(Config config) {
  if (config.currentImage == null) {
    writeLog("draw_table: Image not ready");
    return;
  }
  writeLog("draw_table: Preparing image");
  var image = config.currentImage;
  var scale = getScale(image);

  var cwidth = (image.width * scale + config.cols - 1).toInt();
  var cheight = (image.height * scale + config.rows - 1).toInt();
  var ipieze_width = image.width / config.cols;
  var ipieze_height = image.height / config.rows;
  CanvasElement canvas = querySelector("#canvas");
  canvas
      ..width = cwidth
      ..height = cheight;
  var context = canvas.context2D;
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
  var rect = getRectPos(config.rows - 1, config.cols - 1, config);
  context
      ..fillStyle = "rgba(0, 0, 0, 1)"
      ..fillRect(rect.x, rect.y, rect.width, rect.height);
  writeLog("draw_table: Image ready");
}



num getScale(ImageElement image) {
  //var scalew = 1.0;
  //var scaleh = 1.0;
  //if (image.width > 1000) scalew = 1000.0 / image.width;
  //if (image.height > 1000) scaleh = 1000.0 / image.height;
  var scalew = 1000.0 / image.width;
  var scaleh = 1000.0 / image.height;
  return min(scalew, scaleh);
}



Rect getRectPos(int row, int col, Config config) {
  var image = config.currentImage;

  var scale = getScale(image);

  var piezeWidth = (image.width / config.cols * scale).toInt();
  var piezeHeight = (image.height / config.rows * scale).toInt();

  var x = col * piezeWidth + col;
  var y = row * piezeHeight + row;
  return new Rect(x, y, piezeWidth, piezeHeight);
}
