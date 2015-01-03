library plain;

import 'package:puzzle/setup.dart';
import 'package:puzzle/log.dart';
import 'package:puzzle/draw_support.dart';
import 'package:puzzle/randomize.dart';
import 'dart:html';
import 'package:range/range.dart';



class _PlainStatus {
  Config config;
  Possition holePossition;
}



class Plain {
  _PlainStatus _status = new _PlainStatus();
  var subscriptionConfigModif;

  Plain(Config config) {
    resetCanvas();
    _prepareConfig(config);
    _prepareEvents();
  }

  void reset() {
    //  awfull
    subscriptionConfigModif.cancel();

    _status.config = null;
    _status = null;
  }


  void _prepareConfig(Config config) {
    _status.config = config;
    subscriptionConfigModif = _status.config.onModif.listen((_) => _onConfigModif());
    _onConfigModif();
  }
  void _onConfigModif() {
    writeLog("Plain: Received config modif");
    _status.holePossition = new Possition(_status.config.rows - 1, _status.config.cols - 1);
    if(prepareImage(_status.config))
    {
      drawHole(_status.holePossition, _status.config);
    }
    writeLog("Plain: Config modif processed");
  }


  void _prepareEvents() {
    getCanvas().onClick.listen((event) => _onMouseDown(event));
    //window.onKeyDown.listen((event) => _onKeyPress(event));
  }

  void _onMouseDown(MouseEvent event) {
    var possition = getPossitionFromCanvasCoords(event.client.x, event.client.y, _status.config);

    var distHoleCol = possition.col - _status.holePossition.col;
    var distHoleRow = possition.row - _status.holePossition.row;

    if ((distHoleCol.abs() + distHoleRow.abs()).round() == 1) {
      moveToHole(possition, _status.holePossition, _status.config);
    }
  }


  /*void _onKeyPress(KeyboardEvent event) {
    if (event.keyCode == KeyCode.LEFT) {
      _moveLeft();
    } else if (event.keyCode == KeyCode.RIGHT) {
      _moveRight();
    } else if (event.keyCode == KeyCode.UP) {
      moveUp(_status.holePossition, _status.config);
    } else if (event.keyCode == KeyCode.DOWN) {
      moveDown(_status.holePossition, _status.config);
    }
  }*/

  void _moveLeft() {
    if (_status.holePossition.col < _status.config.cols - 1) {
      var origin = new Possition(_status.holePossition.row, _status.holePossition.col + 1);
      moveToHole(origin, _status.holePossition, _status.config);
    }
  }

  void _moveRight() {
    if (_status.holePossition.col > 0) {
      var origin = new Possition(_status.holePossition.row, _status.holePossition.col - 1);
      moveToHole(origin, _status.holePossition, _status.config);
    }
  }


  void randomize() {
    for (var i in range(_status.config.cols * _status.config.rows * 20)) {
      var random = rang.nextInt(4);
      if (random == 0) {
        _moveLeft();
      }
      else if (random == 1) {
        _moveRight();
      }
      if (random == 2) {
        moveUp(_status.holePossition, _status.config);
      }
      if (random == 3) {
        moveDown(_status.holePossition, _status.config);
      }

    }
  }
}
