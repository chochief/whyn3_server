part of proc;

void _campIsoEntry(SendPort rootPort) {

  // CAMP_ISO here

  ReceivePort port = new ReceivePort();
  int isoName = campIso;
  Camp camp = new Camp(rootPort, isoName);
  Byter.camp = camp; // передача в Byter ссылки на Camp

  // registration
  rootPort.send({
    'f': isoName, // from
    'c': Codes.reg, // 1 REG
    'p': port.sendPort,
  });

  /// Получаем ссылку на объект Lifer по hash
  /// если не находим, на консоль выводтся WARN
  Lifer liferRestore(int hash) {
    Lifer l = camp.lifer(hash);
    if (l == null) {
      Rec.it('${Rec.typeWARN} camp_iso inbox lifer not found $hash', always: true);
    }
    return l;
  }

  port.listen((msg) {
    switch (msg['c']) {
      // case Codes.logerPort: // 2 LOGER PORT
      //   camp.loger(msg['l']);
      //   break;
      case Codes.come: // 10 COME
        camp.come(msg['h'], msg['u']);
        break;
      case Codes.comeSync: // 14 COMESYNC
        camp.comeSync(msg['h'], msg['r'], msg['u']);
        break;
      case Codes.settings: // 18 SETTINGS
        Lifer lifer = liferRestore(msg['h']);
        if (lifer != null) lifer.settings(msg['s']);
        break;
      case Codes.gpsdata100: // 20
      case Codes.gpsdata300: // 21
      case Codes.gpsdata500: // 22
      case Codes.gpsdata700: // 23
      case Codes.gpsdata7pl: // 24
        Lifer lifer = liferRestore(msg['h']);
        if (lifer != null) lifer.gpsdata(msg['a'], msg['o']);
        break;
      case Codes.away: // 44 AWAY
        camp.away(msg['h']);
        break;
      case Codes.globRequest: // 50 GLOB_GET
        Lifer lifer = liferRestore(msg['h']);
        if (lifer != null) lifer.glob(msg['a'], msg['b'], msg['d'], msg['e']);
        break;
      case Codes.reboot:
        camp.reboot();
        break;
      default:
    } 
  });

}