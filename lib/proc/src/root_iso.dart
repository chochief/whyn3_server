part of proc;

const int rootIso = 0;
const int maperIso = 1;
const int campIso = 2;
const int logerIso = 3;

Completer loader; // начальная загрузка

SendPort _maperIsoPort;
SendPort _campIsoPort;
// SendPort _logerIsoPort;

Future<bool> root() async {
  loader = new Completer();

  ReceivePort receivePort = new ReceivePort();

  // ROOT_ISO PORT RECEIVER
  receivePort.listen((msg) {

    switch (msg['f']) { // from
      case maperIso:
        _rootFromMaper(msg);
        break;
      case campIso:
        _rootFromCamp(msg);
        break;
      // case logerIso:
      //   _rootFromLoger(msg);
      //   break;
      default:
    }

  });

  // starting isolates
  // MAPER_ISO
  Isolate.spawn(_maperIsoEntry, receivePort.sendPort)
  .then((Isolate maperIso) => Rec.it('MAPER_ISO: ${maperIso.hashCode}'))
  .catchError((IsolateSpawnException e) => Rec.it('${Rec.typeERR} in spawning MAPER_ISO: $e', always: true));

  // CAMP_ISO
  Isolate.spawn(_campIsoEntry, receivePort.sendPort)
  .then((Isolate campIso) => Rec.it('CAMP_ISO: ${campIso.hashCode}'))
  .catchError((IsolateSpawnException e) => Rec.it('${Rec.typeERR} in spawning CAMP_ISO: $e', always: true));

  // LOGER_ISO
  // Isolate.spawn(_logerIsoEntry, receivePort.sendPort)
  // .then((Isolate logerIso) => Rec.it('LOGER_ISO: ${logerIso.hashCode}'))
  // .catchError((IsolateSpawnException e) => Rec.it('Error in spawning LOGER_ISO: $e'));

  return loader.future;
}

void _toIso(SendPort iso, int code, String data) {
  if (iso == null) return;
  iso.send({
    'f': rootIso,
    'c': code,
    'd': data,
  });
}

// /// Отправить в camp_iso ссылку на порт loger_iso
// void loger() {
//   if (_campIsoPort != null && _logerIsoPort != null && _maperIsoPort != null) {
//     _campIsoPort.send({
//       'f': rootIso,
//       'c': Codes.logerPort, // 2 LOGER PORT
//       'l': _logerIsoPort,
//     });
//     //
//     loader.complete(true);
//     Rec.it('loader complete!');
//   }
// }

void loaded() {
  if (_maperIsoPort != null && _campIsoPort != null) {
    loader.complete(true);
    Rec.it('${Rec.typeINFO} root_iso loader complete all iso ready', always: true);
  }
}

void reboot() {
  if (_maperIsoPort != null && _campIsoPort != null) {
    _campIsoPort.send({
      'f': rootIso,
      'c': Codes.reboot, // 99
    });
    _maperIsoPort.send({
      'f': rootIso,
      'c': Codes.reboot, // 99
    });
  } else Rec.it('${Rec.typeERR} root_iso reboot ports not found', always: true);
}