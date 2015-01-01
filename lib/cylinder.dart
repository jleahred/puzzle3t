library cylinder;

import 'package:puzzle/setup.dart';
import 'package:puzzle/log.dart';
import 'package:puzzle/draw_support.dart';
import 'package:puzzle/randomize.dart';
import 'dart:html';
import 'package:range/range.dart';



class _CylinderStatus {
  Config config;
  Possition holePossition;
  Possition startDrag;
  bool moved = false;
}



class Cylinder {
  _CylinderStatus _status = new _CylinderStatus();
  var subscriptionConfigModif;

  Cylinder(Config config) {
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
    writeLog("Cylinder: Received config modif");
    _status.holePossition = new Possition(_status.config.rows - 1, _status.config.cols - 1);
    if (prepareImage(_status.config)) {
      _drawHole();
    }
    writeLog("Cylinder: Config modif processed");
  }


  void _drawHole() {
    var rect = getRectPos(_status.holePossition.row, _status.holePossition.col, _status.config);
    getContext()
        ..fillStyle = "rgba(0, 0, 0, 1)"
        ..fillRect(rect.x, rect.y, rect.width, rect.height);
  }
  void _prepareEvents() {
    getCanvas().onMouseDown.listen((event) => _onMouseDown(event));
    getCanvas().onMouseUp.listen((event) => _onMouseUp(event));
    getCanvas().onMouseLeave.listen((event) => _onMouseRelease(event));
    getCanvas().onMouseMove.listen((event) => _onMouseMove(event));
  }

  void _onMouseDown(MouseEvent event) {
    _status.startDrag = getPossitionFromCanvasCoords(event.client.x, event.client.y, _status.config);
  }

  void _onMouseUp(MouseEvent event) {
    var possition = getPossitionFromCanvasCoords(event.client.x, event.client.y, _status.config);

    var distHoleRow = possition.row - _status.holePossition.row;

    if (_status.moved == false && distHoleRow.abs().round() == 1 && _status.holePossition.col == possition.col && possition == _status.startDrag) {
      _moveToHole(possition);
    } else {
      _status.startDrag = possition;
    }
    _onMouseRelease(event);
  }

  void _onMouseRelease(MouseEvent event) {
    _status.startDrag = null;
    _status.moved = false;
  }

  void _onMouseMove(MouseEvent event) {
    var possition = getPossitionFromCanvasCoords(event.client.x, event.client.y, _status.config);

    if (_status.startDrag != null && possition.row == _status.startDrag.row) {
      if ((possition.col - _status.startDrag.col).abs().round() == 1) {
        if (possition.col > _status.startDrag.col) {
          _moveRowRight(_status.startDrag.row);
        } else {
          _moveRowLeft(_status.startDrag.row);
        }
        _status.startDrag = possition;
        _status.moved = true;
      }
    }
  }

  void _moveToHole(Possition origin) {
    copyTo(origin, _status.holePossition, _status.config);
    _status.holePossition = origin;
    _drawHole();
  }

  void _moveRowLeft(int row) {
    var tempCanvas = copyToTempCanvas(new Possition(row, 0), _status.config);
    for (var c in range(0, _status.config.cols - 1, 1)) {
      Possition origin = new Possition(row, c + 1);
      Possition destiny = new Possition(row, c);
      copyTo(origin, destiny, _status.config);
    }
    copyFromTempCanvas(new Possition(row, _status.config.cols - 1), tempCanvas, _status.config);
    if (row == _status.holePossition.row) {
      _status.holePossition.col -= 1;
      if (_status.holePossition.col < 0) _status.holePossition.col = _status.config.cols - 1;
    }
  }

  void _moveRowRight(int row) {
    var tempCanvas = copyToTempCanvas(new Possition(row, _status.config.cols - 1), _status.config);
    for (var c in range(_status.config.cols - 2, -1, -1)) {
      Possition origin = new Possition(row, c);
      Possition destiny = new Possition(row, c + 1);
      copyTo(origin, destiny, _status.config);
    }
    copyFromTempCanvas(new Possition(row, 0), tempCanvas, _status.config);
    if (row == _status.holePossition.row) {
      _status.holePossition.col += 1;
      if (_status.holePossition.col == _status.config.cols) _status.holePossition.col = 0;
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
    for (var i in range(_status.config.cols * _status.config.rows * 20)) {
      var random = rang.nextInt(2);
      if (random == 0) { //  move column
        var rcolumn = rang.nextInt(2);
        if (rcolumn == 0) {
          _moveUp();
        } else {
          _moveDown();
        }
      } else { // move row
        var rrow = rang.nextInt(_status.config.rows);
        var rdir = rang.nextInt(2);
        if (rdir == 0) {
          _moveRowLeft(rrow);
        } else {
          _moveRowRight(rrow);
        }
      }
    }
  }
}
