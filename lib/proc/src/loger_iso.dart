// part of proc;

// void _logerIsoEntry(SendPort rootPort) {

//   // LOGER_ISO here

//   ReceivePort port = new ReceivePort();
//   int isoName = logerIso;
//   Loger loger = new Loger();

//   // registration
//   rootPort.send({
//     'f': isoName, // from
//     'c': Codes.reg, // 1 REG
//     'p': port.sendPort,
//   });

//   port.listen((msg) {
//     Rec.it('loger_iso inbox ${msg['c']}');
//     switch (msg['c']) {
//       case Codes.folder: // 80 FOLDER
//         loger.folder(msg['r']);
//         break;
//       case Loger.lifer: // 81
//       case Loger.hacker: // 82
//       case Loger.warn: // 83
//         loger.text(msg['c'], msg['r']);
//         break;
//       case Loger.stats: // 88
//         loger.csv(msg['r']);
//         break;
//       default:
//     } 
//   });

// }