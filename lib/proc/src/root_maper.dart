part of proc;

// root_iso handlers for maper_iso messages

void _rootFromMaper(msg) {
  Rec.it('rootIso from maper_iso $msg');
  if (msg['f'] != maperIso) return;
  switch (msg['c']) {
    case Codes.reg: // 1 REG
      _maperIsoPort = msg['p'];
      loaded();
      break;
    case Codes.checkAnswer: // 5 CHECK_ANSWER
      String m1 = msg['m'];
      if (_maperChecks.containsKey(m1)) {
        _maperChecks[m1].complete(msg['a']);
        _maperChecks.remove(m1);
      } else Rec.it('${Rec.typeWARN} rootFromMaper unknown answer for m1: $m1', always: true);
      break;
    default:
  }
}

// to maper_iso

void storeTemporary(String hash) {
  _toIso(_maperIsoPort, Codes.storeTemp, hash); // 3 STORE_TEMP
}

Map<String, Completer> _maperChecks = new Map<String, Completer>();

Future<bool> checkSocket(String m1) async {
  Rec.it('INFO root_maper checkSocket m1 $m1');
  Completer completer = new Completer();
  _maperChecks[m1] = completer;
  _toIso(_maperIsoPort, Codes.checkSock, m1); // 4 CHECK_SOCK
  return completer.future;
}
