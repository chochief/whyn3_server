library maper;

import 'dart:convert';
import 'package:crypto/crypto.dart';
// import 'dart:async';

import 'package:WhynServer/kernel/rec.dart';
// import 'package:WhynServer/proc/proc.dart';

class Maper {
  String _k1;
  Map<String, DateTime> _hashes;
  int _counter;
  final int _seconds = 3;

  Maper() {
    int _k11 = _qk(_gk(1));
    _hashes = new Map<String, DateTime>();
    _k1 = _k11.toString();
    _counter = 0;
  }

  bool check(String m1) {
    Rec.it('maper_iso check $m1');
    if (m1.length < 66) return false;
    
    // temporary hash
    String t1 = m1.substring(65);
    if (_hashes.containsKey(t1) == false) return false;
    else {
      DateTime now = new DateTime.now();
      if (now.difference(_hashes[t1]).inSeconds > _seconds) {
        _hashes.remove(t1);
        return false;
      }
    } 
    _hashes.remove(t1);

    String h1 = m1.substring(1, 65);
    String h2 = _hmac(_k1, '$t1$_k1');

    return h1 == h2;
  }

  String _hmac(String k, String msg) {
    String hm;
    try {
      var key = UTF8.encode(k);
      var bytes = UTF8.encode(msg);
      var hmacSha256 = new Hmac(sha256, key);
      hm = hmacSha256.convert(bytes).toString();
    } catch (e) {
      Rec.it('WARN: ERR in maper _hmac() | $e', always: true);
      /** будет возвращен null и check() вернет false, затем клиент переподключится */
    }
    return hm;
  }

  int _gk(int pc) => 6*3*7*9;

  void storeTemporary(String hash) {
    Rec.it('maper_iso storeTemporary $hash');
    /** 
     * _hashes не чистим специально (ни в цикле, ни по таймеру)
     * очистка происходит при проверке (наличие и дата)
     * если входящий hash сокет повторится, просто продлится срок
     * т.о. _hashes может понемногу расти (что не скажется на работе)
     * даже при росте свыше 2 млрд. проблем не будет, 
     * кроме снижения скорости доступа (но это хэш-таблица)
     * но когда растет _hashes? когда не приходит check
     */
    _hashes[hash] = new DateTime.now();
    _clearing();
  }

  int _qk(int gpc) => gpc*18*2*4*6*9;

  void _clearing() {
    _counter++;
    if (_counter > 5) {
      _counter = 0;
      DateTime now = new DateTime.now();
      List<String> removeIt = [];
      _hashes.forEach((String temphash, DateTime was) {
        if (now.difference(was).inSeconds > _seconds) removeIt.add(temphash);
      });
      removeIt.forEach((th) {
        _hashes.remove(th);
      });
      Rec.it('${Rec.typeINFO} maper clearing removed ${removeIt.length} temp hashes', always: true);
    }
  }

  /// Очитить _hashes при перезагрузке
  void reboot() {
    _hashes.clear();
  }

}