// library loger;

// import 'dart:io';
// import 'package:path/path.dart' as path;
// import 'package:WhynServer/kernel/rec.dart';

// class Loger {

//   static const int lifer = 81;
//   static const int hacker = 82;
//   static const int warn = 83;
//   static const int stats = 88;
//   final Map names = {
//     Loger.lifer: 'lifer',
//     Loger.hacker: 'hacker',
//     Loger.warn: 'warn',
//     Loger.stats: 'stats',
//   };

//   Map<int, IOSink> sink;

//   String _reghashFolder;
//   String day;

//   Loger() {
//     sink = new Map<int, IOSink>();
//   }

//   /// Создать папку для всех логов (до следующей перезагрузки)
//   void folder(int reghash) {
//     DateTime now = new DateTime.now();
//     String pref = '${today(now)}-${_twoDigits(now.hour)}${_twoDigits(now.minute)}${_twoDigits(now.second)}-';
//     _reghashFolder = path.join('.loger', '$pref${reghash.toString()}');
//     Directory directory = new Directory(_reghashFolder);
//     bool dirExists = directory.existsSync();
//     if (dirExists == false) directory.createSync();
//   }

//   /// Записать в лог текстового вида
//   /// запись с датой, отделенная от других переносом строки
//   void text(int code, String row) {
//     Rec.it('loger_iso text $code');
//     if (names.containsKey(code) == false || code == Loger.stats) return;
//     DateTime now = new DateTime.now();
//     _prepare(now);
//     if (sink[code] is IOSink) sink[code].write('\n$now $row\n');
//   }

//   void csv(String row) {
//     Rec.it('loger_iso csv');
//     DateTime now = new DateTime.now();
//     _prepare(now);
//     if (sink[Loger.stats] is IOSink) sink[Loger.stats].write('$row\n');
//   }

//   // tools

//   /// Проверяет готовность к записи и коррективы при необходимости
//   void _prepare(DateTime now) {
//     // Замена файлов для записи
//     String t = today(now);
//     if (t != day) {
//       day = t; // обновление текущего дня
//       // close
//       names.forEach((int k, String v) {
//         if (sink[k] != null && sink[k] is IOSink) sink[k].close();
//       });
//       // new
//       names.forEach((int k, String v) {
//         sink[k] = (new File(_filePathBy(k))).openWrite(mode: FileMode.APPEND);
//       });
//     }
//   }

//   /// Возвращает путь к файлу лога (включая файл с расширением)
//   /// по коду и занчению day
//   String _filePathBy(int code) {
//     if (names.containsKey(code) == false) return '__warn.log';
//     String file = names[code];
//     String ext = code == Loger.stats ? 'csv' : 'log';
//     return path.join(_reghashFolder, '$day-${file.toUpperCase()}.$ext');
//   }

//   /// Берет дату и возвращает строку вида 2018041502 (yearmonthday)
//   String today(DateTime now) => '${now.year}${_twoDigits(now.month)}${_twoDigits(now.day)}';

//   /// Добавить нули в начало, если число из одной цифры
//   String _twoDigits(int number) {
//     if (number < 10) return '0$number';
//     else return '$number';
//   }

// }