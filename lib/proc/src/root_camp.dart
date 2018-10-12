part of proc;

Registrar _registrar = new Registrar();

// root_iso handlers for camp_iso messages

void _rootFromCamp(msg) {
  if (msg['f'] != campIso) return;

  switch (msg['c']) {
    case Codes.reg: // 1 REG
      _campIsoPort = msg['p'];
      loaded();
      break;
    case Codes.move: // 30 MOVE
      _registrar.notify(msg['r'], msg['d']);
      break;
    case Codes.remove: // 32
      _registrar.notify(msg['r'], msg['d']);
      break;
    case Codes.recount: // 37
      _registrar.package(msg['h'], msg['d']);
      break;
    case Codes.sectorPackage: // 38
      _registrar.package(msg['h'], msg['d']);
      break;
    case Codes.liferOffline: // 39
      _registrar.notify(msg['r'], msg['d']);
      break;
    case Codes.globPackage: // 54
      _registrar.package(msg['h'], msg['d']);
      break;
    default:
  }
  
}

// root messages to camp_iso

/// Счетчик для статистики stats
int stats = 0;
int getStats() => stats;

/// Добавить Lifer в Camp_iso либо перевести в онлайн
void come(int hash, String userdata) {
  _campIsoPort.send({
    'f': rootIso,
    'c': Codes.come, // 10 COME
    'h': hash,
    'u': userdata,
  });
  stats++;
}

/// Синхронизировать лайфера и перевести его в онлайн
void comeSync(int hash, int hashToRemove, String userdata) {
  _campIsoPort.send({
    'f': rootIso,
    'c': Codes.comeSync, // 14 COMESYNC
    'h': hash,
    'r': hashToRemove,
    'u': userdata,
  });
  stats++;
}

/// Перевести объект Lifer в офлайн (и уведомить)
/// (вызывается при закрытии соединения)
void away(int hash) {
  _campIsoPort.send({
    'f': rootIso,
    'c': Codes.away, // 44 AWAY
    'h': hash,
  });
  stats--;
}

/// Передать samf в lifer
void settings(int code, int hash, int samf) {
  _campIsoPort.send({
    'f': rootIso,
    'c': code, // 18 SETTINGS
    'h': hash,
    's': samf,
  });
}

/// Передать gpsdata
// csv
void gpsdata(int code, int hash, int mla, int mlo) {
  _campIsoPort.send({
    'f': rootIso,
    'c': code,
    'h': hash,
    'a': mla,
    'o': mlo,
  });
}
// arraybuffer
// void gpsdata(int hash, ByteData byteData) {
//   _campIsoPort.send({
//     'f': rootIso,
//     'c': byteData.getUint8(0),
//     'hash': hash,
//     'mla': byteData.getInt32(1),
//     'mlo': byteData.getInt32(5),
//   });
// }

/// Запрос данных для glob
// csv
void getGlob(int code, int hash, int tamla, int tamlo, int tcmla, int tcmlo) {
  _campIsoPort.send({
    'f': rootIso,
    'c': code, // 50
    'h': hash,
    'a': tamla,
    'b': tamlo,
    'd': tcmla,
    'e': tcmlo,
  });
}
// arraybuffer
// void getGlob(int hash, ByteData byteData) {
//   _campIsoPort.send({
//     'f': rootIso,
//     'c': 50,
//     'hash': hash,
//     'tamla': byteData.getInt32(1),
//     'tamlo': byteData.getInt32(5),
//     'tcmla': byteData.getInt32(9),
//     'tcmlo': byteData.getInt32(13),
//   });
// }
