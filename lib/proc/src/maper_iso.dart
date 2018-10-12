part of proc;

void _maperIsoEntry(SendPort rootPort) {
  ReceivePort port = new ReceivePort();
  Maper _maper = new Maper();
  int isoName = maperIso;
  // Queue не нужна очередь здесь, 
  // т.к. port.listen обрабатывает сообщения в порядке отправки (поступления, что то)

  // registration
  rootPort.send({
    'f': isoName,
    'c': Codes.reg, // 1 REG
    'p': port.sendPort,
  });


  port.listen((msg) {
    Rec.it('maper_iso inbox $msg');
    switch (msg['c']) {
      case Codes.storeTemp: // 3 STORE_TEMP
        _maper.storeTemporary(msg['d']);
        break;
      case Codes.checkSock: // 4 CHECK_SOCK
        rootPort.send({
          'f': isoName,
          'c': Codes.checkAnswer, // 5 CHECK_ANSWER
          'm': msg['d'],
          'a': _maper.check(msg['d']), // в msg['d'] строка m1 для анализа
        });
        break;
      case Codes.reboot:
        _maper.reboot();
        break;
      default:
    }
  });

}