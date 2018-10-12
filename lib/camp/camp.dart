library camp;

import 'dart:isolate';
// import 'dart:typed_data';
import 'dart:math';

// import 'package:WhynServer/loger/loger.dart';
import 'package:WhynServer/kernel/codes.dart';
import 'package:WhynServer/kernel/rec.dart';

part 'src/sector.dart';
part 'src/lifer.dart';
part 'src/samf.dart';
part 'src/mapco.dart';
part 'src/byter.dart';
// part 'src/stats.dart';

class Camp {
  SendPort _rootPort;
  SendPort get rootPort => _rootPort;

  // SendPort _logerIsoPort;
  // SendPort get logerIsoPort => _logerIsoPort;

  int _isoName;
  int get isoName => _isoName;

  Map<int, Lifer> _lifers;
  Map<String, Sector> _sectors;

  int _uniq; // счетчик для создания uid лайфера (используемого при логировании)

  Camp(this._rootPort, this._isoName) {
    _lifers = new Map<int, Lifer>();
    _sectors = new Map<String, Sector>();
    _uniq = 0;
  }

  /// Перезагрузить camp
  void reboot() {
    // каждый сектор очищаем от членов и подписчиков
    _sectors.forEach((String k, Sector s) {
      s.reboot();
    });
    // каждого лайфера очищаем от членства и подписок
    // а также переводим в офлайн
    _lifers.forEach((int h, Lifer l) {
      l.reboot();
    });
    // _lifers - ничего не делаем
  }

  /// Зарегистрировать lifer и(или) перевести его в онлайн
  void come(int hash, String userdata) {
    Lifer lifer = _lifers[hash];
    if (lifer == null) {
      lifer = new Lifer(this, hash, _uniq++);
      _lifers[hash] = lifer;
    }
    lifer.userdata = userdata;
    lifer.online = true; // !
  }

  /// Синхронизировать хеш лайфера (в camp с _registry)
  /// и перевести лайфера в онлайн
  void comeSync(int hash, int hashToRemove, String userdata) {
    Lifer lifer = _lifers[hashToRemove];
    if (_lifers.containsKey(hash)) {
      Rec.it('${Rec.typeWARN}: camp comeSync new hash $hash used (to remove $hashToRemove)', always: true);
      /**
       * продолжаем синхронизацию (приведение camp._lifers к _registry)
       * это невозможная ситуация, но если случится - не критично
       */
    }
    // _lifers - заменяем ключ hashToRemove на hash
    _lifers[hash] = lifer;
    _lifers.remove(hashToRemove);
    // lifer - заменяем hash и переводим в онлайн
    lifer.hash = hash; // !
    lifer.userdata = userdata;
    lifer.online = true; // !
  }

  /// Перевести lifer в офлайн (и уведомить подписчиков)
  void away(int hash) {
    Lifer lifer = _lifers[hash];
    if (lifer != null) lifer.away();
    else Rec.it('${Rec.typeWARN} camp away lifer not found (hash: $hash)', always: true);
  }

  /// Получить lifer по hash
  Lifer lifer(int hash) => _lifers[hash];

  /// Получить сектор по ключу
  Sector sector(String key) {
    Sector sect = _sectors[key];
    if (sect == null) {
      sect = new Sector(key, this);
      _sectors[key] = sect;
    }
    return sect;
  }

  // /// Записать в camp ссылку на порт loger_iso
  // void loger(SendPort _logerIsoPort) => this._logerIsoPort = _logerIsoPort;

  // /// Записать строку row в текстовый лог
  // /// напр., text(Loger.warn, 'hi from camp!');
  // void text(int code, String row) {
  //   logerIsoPort.send({
  //     'f': isoName,
  //     'c': code,
  //     'r': row,
  //   });
  // }

  // /// Записать строку в таблицу stats.csv
  // void csv(String row) {
  //   // отправка в loger_iso
  //   logerIsoPort.send({
  //     'f': isoName,
  //     'c': Loger.stats,
  //     'r': row,
  //   });
  // }

}