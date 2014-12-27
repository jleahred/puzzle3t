library plain;

import 'dart:html';
import 'package:puzzle/setup.dart';
import 'dart:math';
import 'package:range/range.dart';

Plain _plain;

class Plain {

}


void createPlain(Config config) {
  preparePicture(config);
}


void preparePicture(Config config) {
  ImageElement image = new ImageElement(src: "images/snow_man.png");
  image.onLoad.listen((e) {
    var scalew = 1.0;
    var scaleh = 1.0;
    if (image.width > 800) scalew = 800.0 / image.width;
    if (image.height > 800) scaleh = 800.0 / image.width;
    var scale = min(scalew, scaleh);

    var piezeWidth = image.width/config.cols * scale;
    var piezeHeight = image.height/config.rows * scale;
    var cwidth = (piezeWidth * config.cols + config.cols-1).toInt();
    var cheight = (piezeHeight * config.rows + config.rows-1).toInt();
    var ipieze_width = image.width / config.cols;
    var ipieze_height = image.height / config.rows;
    CanvasElement canvas = querySelector("#canvas");
    canvas
        ..width = cwidth
        ..height = cheight;
    var context = canvas.context2D;
    context..fillRect(0, 0, cwidth, cheight);

    for (int c in range(config.cols)) {
      for (int r in range(config.rows)) {
        var ix = c * image.width/config.cols;
        var iy = r * image.height/config.rows;

        var cx = c * piezeWidth + c;
        var cy = r * piezeHeight + r;

        if((c==config.cols-1 &&  r==config.rows-1)==false)
          context.drawImageScaledFromSource(image, ix, iy, ipieze_width, ipieze_height, cx, cy, piezeWidth, piezeHeight);
      }
    }
  });
}
