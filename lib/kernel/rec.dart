library rec;

// import 'package:WhynServer/kernel/config.dart';

class Rec {
  static final bool record = false;
  static final bool csvrec = true;

  static final String typeLifer     = 'Lifer';
  static final String typeHacker    = 'Hacker';
  static final String typeStats     = '';
  static final String typeINFO      = 'INFO';
  static final String typeWARN      = 'WARN';
  static final String typeERR       = 'ERR';
  
  static it(String text, {bool always: false}) {
    if (always || record) print('${new DateTime.now()} $text');
    // if (always || Config.record) print('${new DateTime.now()} $text');
  }

  static csv(String row) {
    if (csvrec) print('$typeStats$row');
  }

}