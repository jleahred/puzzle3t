library toroidal;

import 'package:puzzle/setup.dart';
import 'package:puzzle/log.dart';
import 'package:puzzle/draw_support.dart';
import 'package:puzzle/randomize.dart';
import 'dart:html';
import 'package:range/range.dart';



class _ToroidalStatus {
  Config config;
  Possition startDrag;
  bool moved = false;
}



class Toroidal {
  _ToroidalStatus _status = new _ToroidalStatus();
  var subscriptionConfigModif;

  Toroidal(Config config) {
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
    writeLog("Toroidal: Received config modif");
    prepareImage(_status.config);
    writeLog("Toroidal: Config modif processed");
  }


  void _prepareEvents() {
    getCanvas().onMouseDown.listen((event) => _onMouseDown(event));
    getCanvas().onMouseUp.listen((event) => _onMouseRelease(event));
    getCanvas().onMouseLeave.listen((event) => _onMouseRelease(event));
    getCanvas().onMouseMove.listen((event) => _onMouseMove(event));
  }

  void _onMouseDown(MouseEvent event) {
    _status.startDrag = getPossitionFromCanvasCoords(event.client.x, event.client.y, _status.config);
  }

  void _onMouseRelease(MouseEvent event) {
    _status.startDrag = null;
    _status.moved = false;
  }

  void _onMouseMove(MouseEvent event) {
    var possition = getPossitionFromCanvasCoords(event.client.x, event.client.y, _status.config);

    if (_status.startDrag != null) {
      if ((possition.col - _status.startDrag.col).abs().round() == 1  &&  possition.row == _status.startDrag.row) {
        if (possition.col > _status.startDrag.col) {
          moveRowRight(_status.startDrag.row, _status.config);
        } else {
          moveRowLeft(_status.startDrag.row, _status.config);
        }
        _status.startDrag = possition;
        _status.moved = true;
      }
      if ((possition.row - _status.startDrag.row).abs().round() == 1  &&  possition.col == _status.startDrag.col) {
        if (possition.row > _status.startDrag.row) {
          _moveColDown(_status.startDrag.col);
        } else {
          _moveColUp(_status.startDrag.col);
        }
        _status.startDrag = possition;
        _status.moved = true;
      }
    }
  }


  void _moveColUp(int col) {
    var tempCanvas = copyToTempCanvas(new Possition(0, col), _status.config);
    for (var r in range(0, _status.config.rows - 1, 1)) {
      Possition origin = new Possition(r+1, col);
      Possition destiny = new Possition(r, col);
      copyTo(origin, destiny, _status.config);
    }
    copyFromTempCanvas(new Possition(_status.config.rows - 1, col), tempCanvas, _status.config);
  }

  void _moveColDown(int col) {
    var tempCanvas = copyToTempCanvas(new Possition(_status.config.rows - 1, col), _status.config);
    for (var r in range(_status.config.rows - 2, -1, -1)) {
      Possition origin = new Possition(r, col);
      Possition destiny = new Possition(r + 1, col);
      copyTo(origin, destiny, _status.config);
    }
    copyFromTempCanvas(new Possition(0, col), tempCanvas, _status.config);
  }

  void randomize() {
    for (var i in range(_status.config.cols * _status.config.rows * 20)) {
      var random = rang.nextInt(2);
      if (random == 0) { //  move column
        var rcol = rang.nextInt(_status.config.cols);
        var rdir = rang.nextInt(2);
        if (rdir == 0) {
          _moveColUp(rcol);
        } else {
          _moveColDown(rcol);
        }
      } else { // move row
        var rrow = rang.nextInt(_status.config.rows);
        var rdir = rang.nextInt(2);
        if (rdir == 0) {
          moveRowLeft(rrow, _status.config);
        } else {
          moveRowRight(rrow, _status.config);
        }
      }
    }
  }
}
