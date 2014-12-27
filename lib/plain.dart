library plain;

import 'package:puzzle/setup.dart';
import 'package:puzzle/log.dart';
import 'package:puzzle/draw_support.dart';


class Possition {
  final int x, y;
  Possition(this.x, this.y);
}

class _PlainStatus {
  Config config;
  Possition holePossition;
  var context = getContext();
}



class Plain {
  _PlainStatus  _status = new _PlainStatus();

  Plain(Config config) {
    _status.config = config;
    _status.config.onModif.listen((_) => _onConfigModif());
  }

  void _onConfigModif() {
    writeLog("Plain: Received config modif");
    _prepareImage();
    writeLog("Plain: Config modif processed");
  }

  void _prepareImage() {
    prepareImage(_status.config);

    //  draw hole
    var rect = getRectPos(_status.config.rows - 1, _status.config.rows - 1, _status.config);
    _status.context
        ..fillStyle = "rgba(0, 0, 0, 1)"
        ..fillRect(rect.x, rect.y, rect.width, rect.height);
    _status.holePossition = new Possition(_status.config.cols - 1, _status.config.rows - 1);
  }
}
