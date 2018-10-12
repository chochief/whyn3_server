// part of proc;

// // root_iso handlers for loger_iso messages

// void _rootFromLoger(msg) {
//   if (msg['f'] != logerIso) return;
//   switch (msg['c']) {
//     case Codes.reg: // 1
//       _logerIsoPort = msg['p'];
//       Registrar _registrar = new Registrar();
//       folder(_registrar.reghash);
//       loger();
//       break;
//     default:
//   }
// }

// // root messages to loger_iso

// void folder(int reghash) {
//   _logerIsoPort.send({
//     'f': rootIso,
//     'c': Codes.folder, // 80 FOLDER
//     'r': reghash,
//   });
// }

// /// Отправить строку row в loger_iso
// /// для записи в один из логов
// void text(int code, String row) {
//   _logerIsoPort.send({
//     'f': rootIso,
//     'c': code,
//     'r': row,
//   });
// }

// // void csv(String row)
// // отстутствует, т.к. в csv пишем напрямую из camp

