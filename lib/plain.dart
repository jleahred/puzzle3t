library plain;

import 'package:puzzle/setup.dart';
import 'package:puzzle/log.dart';
import 'package:puzzle/draw_table.dart';





class Plain {
  var _config;
  Plain(Config config) {
    _config = config;
    _config.onModif.listen((_) => _onConfigModif());
  }

  void _onConfigModif() {
    writeLog("Plain: Received config modif");
    prepareImage(_config);
    writeLog("Plain: Config modif processed");
  }

}

