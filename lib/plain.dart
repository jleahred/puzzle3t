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

  Plain(Config config) {
    _prepareConfig(config);
    _prepareEvents();
  }


  void _prepareConfig(Config config) {
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

    _status.holePossition = new Possition(_status.config.cols - 1, _status.config.rows - 1);
    _drawHole();
  }

  void _drawHole() {
    var rect = getRectPos(_status.holePossition.row, _status.holePossition.col, _status.config);
    getContext()
        ..fillStyle = "rgba(0, 0, 0, 1)"
        ..fillRect(rect.x, rect.y, rect.width, rect.height);
  }
  void _prepareEvents() {
    getCanvas().onClick.listen((event) => _onMouseDown(event));
    window.onKeyDown.listen((event) => _onKeyPress(event));
  }

  void _onMouseDown(MouseEvent event) {
    var possition = getPossitionFromCanvasCoords(event.client.x, event.client.y, _status.config);

    var distHoleCol = possition.col - _status.holePossition.col;
    var distHoleRow = possition.row - _status.holePossition.row;

    if ((distHoleCol.abs() + distHoleRow.abs()).round() == 1) {
      _moveToHole(possition);
    }
  }


  void _moveToHole(Possition origin) {
    copyTo(origin, _status.holePossition, _status.config);
    _status.holePossition = origin;
    _drawHole();
  }

  void _onKeyPress(KeyboardEvent event) {
    if (event.keyCode == KeyCode.LEFT) {
      _moveLeft();
    } else if (event.keyCode == KeyCode.RIGHT) {
      _moveRight();
    } else if (event.keyCode == KeyCode.UP) {
      _moveUp();
    } else if (event.keyCode == KeyCode.DOWN) {
      _moveDown();
    }
  }

  void _moveLeft() {
    if (_status.holePossition.col < _status.config.cols - 1) {
      var origin = new Possition(_status.holePossition.row, _status.holePossition.col + 1);
      _moveToHole(origin);
    }
  }

  void _moveRight() {
    if (_status.holePossition.col > 0) {
      var origin = new Possition(_status.holePossition.row, _status.holePossition.col - 1);
      _moveToHole(origin);
    }
  }

  void _moveUp() {
    if (_status.holePossition.row < _status.config.rows - 1) {
      var origin = new Possition(_status.holePossition.row + 1, _status.holePossition.col);
      _moveToHole(origin);
    }
  }

  void _moveDown() {
    if (_status.holePossition.row > 0) {
      var origin = new Possition(_status.holePossition.row - 1, _status.holePossition.col);
      _moveToHole(origin);
    }
  }

  void randomize() {
    for (var i in range(200)) {
      var random = rang.nextInt(4);
      if (random == 0) {
        _moveLeft();
      }
      else if (random == 1) {
        _moveRight();
      }
      if (random == 2) {
        _moveUp();
      }
      if (random == 3) {
        _moveDown();
      }

    }
  }
}
