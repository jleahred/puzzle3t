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
      drawHole(_status.holePossition, _status.config);
    }
    writeLog("Cylinder: Config modif processed");
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
      moveToHole(possition, _status.holePossition, _status.config);
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


  void _moveRowLeft(int row) {
    moveRowLeft(row, _status.config);
    if (row == _status.holePossition.row) {
      _status.holePossition.col -= 1;
      if (_status.holePossition.col < 0) _status.holePossition.col = _status.config.cols - 1;
    }
  }

  void _moveRowRight(int row) {
    moveRowRight(row, _status.config);
    if (row == _status.holePossition.row) {
      _status.holePossition.col += 1;
      if (_status.holePossition.col == _status.config.cols) _status.holePossition.col = 0;
    }
  }



  void randomize() {
    for (var i in range(_status.config.cols * _status.config.rows * 20)) {
      var random = rang.nextInt(2);
      if (random == 0) { //  move column
        var rcolumn = rang.nextInt(2);
        if (rcolumn == 0) {
          moveUp(_status.holePossition, _status.config);
        } else {
          moveDown(_status.holePossition, _status.config);
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
