library log;
import 'dart:html';


TextAreaElement  _textLog;

void writeLog(String text) {
  if(_textLog == null) {
    _textLog = querySelector("#log");
    _textLog.text = "";
  }
  var time = new DateTime.now();
  _textLog.appendText(time.toString() + "  " + text + "\n");
}
