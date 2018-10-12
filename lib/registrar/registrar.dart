library registrar;

import 'dart:math';
// import 'dart:typed_data';

import 'package:WhynServer/connection/connection.dart';
import 'package:WhynServer/proc/proc.dart' as proc;
import 'package:WhynServer/kernel/codes.dart';
import 'package:WhynServer/kernel/rec.dart';
// import 'package:WhynServer/loger/loger.dart';

class Registrar {
  static Registrar _registrar;
  Map<int, Object> _registry;
  Random _random;
  final int _maxHash = 4294967295;
  int _reghash;
  get reghash => _reghash;

  static const int paused = 0;

  factory Registrar() {
    if (_registrar == null) _registrar = new Registrar._internal();
    return _registrar;
  }

  Registrar._internal() {
    _registry = new Map<int, Object>();
    _reghash = this.hashCode;
    Rec.it('${Rec.typeINFO} reghash $reghash', always: true);
    _random = new Random.secure();
  }

  /// Очистить реестр (перед перезагрузкой web_server)
  void reboot() {
    _registry.forEach((h, obj) {
      if (obj != Registrar.paused) {
        if (obj is Connection) obj.close();
        _registry[h] = Registrar.paused;
      }
    });
  }

  /// Проверка регистрации
  /// возвращает hash для клиента
  int entrance(int code, int h1, int r, int h2, Object conn) {
    if ([Codes.changeHash, Codes.restoreHash].contains(code) == false) return -1; // недопустимый вызов
    int h;
    String ip = '';
    String dc = '';
    if (conn is Connection) {
      ip = conn.ipAddr();
      dc = conn.device();
    }
    String udata = '$ip,$dc,$r:$h1';
    if (h1 == 0) {
      // предположительно первый вход
      if (r == 0) h = _reg(h2, conn, Rec.typeLifer, 'new lifer', udata);
      else h = _reg(h2, conn, Rec.typeHacker, 'h1 == 0 but r == $r', udata);
    } else {
      // предположительное не первый вход
      if (h1 == null || h1 < 0 || h1 > _maxHash || r == null || r < 0 || r > _maxHash) {
        h = _reg(h2, conn, Rec.typeHacker, 'invalid h1 or r', udata);
      } else {
        // h1 и r валидные
        if (r == _reghash) {
          // было подключение после загрузки сервера
          if (_registry.containsKey(h1)) {
            // в реестре есть запись
            if (_registry[h1] == Registrar.paused) {
              // запись на паузе как и нужно
              if (code == Codes.restoreHash) {
                // code 11 - стандартное восстановление старого hash
                h = h1;
                _registry[h] = conn;
                proc.come(h, udata);
              } else {
                // code 10 - стандартное получение нового hash
                if (_registry.containsKey(h2)) h = _genHash();
                else h = h2;
                // _registry
                _registry[h] = conn;
                _registry.remove(h1);
                // camp
                proc.comeSync(h, h1, udata);
              }
            } else h = _reg(h2, conn, Rec.typeHacker, '_registry was not paused', udata);
          } else h = _reg(h2, conn, Rec.typeHacker, '_registry not found in', udata);
        } else h = _reg(h2, conn, Rec.typeLifer, '_registry was early', udata);
      }
    }
    return h;
  }

  int _reg(int h2, Object conn, String type, String text, String udata) {
    int h;
    if (_registry.containsKey(h2)) h = _genHash();
    else h = h2;
    _registry[h] = conn;
    /**
     * при стандартном code 10 требуется замена в реестре и в camp 
     * в исключительных случаях (т.е. здесь) - нечего заменять, просто come
     */
    proc.come(h, udata);
    // proc.text(code, text);
    bool a = type == Rec.typeHacker ? true : false;
    Rec.it('$type $text $udata', always: a);
    return h;
  }

  /// Найти незанятый hash в реестре
  int _genHash() {
    int newHash;
    do {
      newHash =_random.nextInt(_maxHash);
    } while (_registry.containsKey(newHash));
    return newHash;
  }

  /// Выполнить действия при закрытии соединения
  void exit(int hash) {
    if (hash == null) {
      Rec.it('${Rec.typeWARN} registrar exit() hash == null ($hash)', always: true);
      return;
    }
    if (_registry.containsKey(hash) == false) {
      Rec.it('${Rec.typeWARN} registrar exit() hash not found ($hash)', always: true);
      return;
    }
    _registry[hash] = Registrar.paused;
    proc.away(hash);
  }

  /// Разослать уведомления списку получателей
  // csv
  void notify(Set<int> recepients, String data) {
    recepients.forEach((recHash) {
      if (_registry.containsKey(recHash)) {
        Object record = _registry[recHash];
        if (record is Connection) record.sendCsv(data);
      }
    });
  }
  // arraybuffer
  // void notify(Set<int> recepients, Uint8List data) {
  //   recepients.forEach((recHash) {
  //     if (_registry.containsKey(recHash)) {
  //       Object record = _registry[recHash];
  //       if (record is Connection) record.send(data);
  //     }
  //   });
  // }

  /// Отправить пакет получателю
  // csv
  void package(int h, String data) {
    if (_registry.containsKey(h)) {
        Object record = _registry[h];
        if (record is Connection) record.sendCsv(data);
    }
  }
  // arraybuffer
  // void package(int h, Uint8List data) {
  //   if (_registry.containsKey(h)) {
  //       Object record = _registry[h];
  //       if (record is Connection) record.send(data);
  //   }
  // }

}