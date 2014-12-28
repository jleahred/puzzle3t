library randomize;
import 'dart:math';
import 'package:puzzle/log.dart';


Random rang = new Random();

void randomize(var puzzle) {
  writeLog("init randomize");
  puzzle.randomize();
  writeLog("finish randomize");
}

