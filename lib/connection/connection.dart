library connection;

import 'dart:io';
// import 'dart:typed_data';

import 'package:WhynServer/registrar/registrar.dart';
import 'package:WhynServer/proc/proc.dart' as proc;
import 'package:WhynServer/kernel/codes.dart';
import 'package:WhynServer/kernel/rec.dart';

class Connection {
  WebSocket _socket;
  Map<String, String> _info;
  Registrar _registrar;
  int _hash;

  Connection(this._socket, this._info) {
    _registrar = new Registrar();
    // _socket.listen(inbox)
    // // ..onError((Error error) => print('ERR: conn _socket.listen.onError() | ${error}'))
    // ..onError((Error error) {
    //   Rec.it('${Rec.typeERR} conn _socket.listen.onError() | ${error}', always: true);
    //   close(); // _socket.close();
    // })
    // ..onDone(() => _closeConnection());
    _socket.listen(inbox, cancelOnError: true, onError: error, onDone: _closeConnection);
  }

  // event handlers

  // void _onOpen() {} 
  // т.е. вызов из конструктора | не используем, т.к. нужен STORED_HASH с клиента

  // Важные действия при закрытии соединения !
  void _closeConnection() {
    _registrar.exit(_hash); // !
    // close(); // ? дополнительно сказать закрыться
  }

  /// Закрыть соедиение (for reboot)
  void close() {
    try {
      // if (_socket != null && _socket.readyState == WebSocket.OPEN) _socket.close();
      _socket.close();
    } catch (e) {
      Rec.it('${Rec.typeERR} conn close() $e', always: true);
    }
  }

  void error(Error er) => Rec.it('${Rec.typeERR} conn _socket.listen.onError() | ${er}', always: true);

  /// inbox handler
  // csv
  void inbox(dynamic data) {
    try {
      // ByteData byteData = data.buffer.asByteData();
      List list;
      if (data is String) {
        if (data == 'X') {
          close(); // _socket.close();
          return;
        } else list = data.split(',');
      } else {
        Rec.it('${Rec.typeWARN} connection inbox() data is not String', always: true);
        return;
      }
      int listLength = list.length;
      if (listLength < 1) {
        Rec.it('${Rec.typeWARN} conn inbox listLength < 1', always: true);
        return;
      }
      int code = int.parse(list[0]);
      // router
      switch (code) {
        case Codes.changeHash: // 10 CHANGE HASH
        case Codes.restoreHash: // 11 RESTORE HASH
          if (listLength != 3) return;
          _register(code, int.parse(list[1]), int.parse(list[2]));
          break;
        case Codes.samf: // 18 SAMF
          if (listLength != 2) return;
          proc.settings(code, _hash, int.parse(list[1]));
          break;
        case Codes.gpsdata100: // 20 GPSDATA < 100m
        case Codes.gpsdata300: // 21 GPSDATA < 300m
        case Codes.gpsdata500: // 22 GPSDATA < 500m
        case Codes.gpsdata700: // 23 GPSDATA < 700m
        case Codes.gpsdata7pl: // 24 GPSDATA > 700m
          if (listLength != 3) return;
          proc.gpsdata(code, _hash, int.parse(list[1]), int.parse(list[2]));
          break;
        case Codes.globRequest: // 50 GLOB_GET
          if (listLength != 5) return;
          proc.getGlob(code, _hash, int.parse(list[1]), int.parse(list[2]), int.parse(list[3]), int.parse(list[4]));
          break;
        case Codes.statsRequest: // 68 STATS
          _sendStats();
          break;
        default:
      }
    } catch (e) {
      Rec.it('${Rec.typeERR} conn imbox() $e', always: true);
    }
  }
  // arraybuffer
  // void inbox(dynamic data) {
  //   // ByteData byteData = data.buffer.asByteData();
  //   ByteData byteData;
  //   if (data is Uint8List) byteData = data.buffer.asByteData();
  //   else {
  //     print('connection inbox() data is not Uint8List');
  //     return;
  //   }
  //   int byteDataLength = byteData.lengthInBytes;
  //   if (byteDataLength < 1) return;
  //   int code = byteData.getUint8(0);
  //   // router
  //   switch (code) {
  //     case 10: // CHANGE HASH
  //     case 11: // RESTORE HASH
  //       if (byteDataLength != 9) return;
  //       _register(code, byteData.getUint32(1), byteData.getUint32(5));
  //       break;
  //     case 18: // SAMF
  //       if (byteDataLength != 5) return;
  //       proc.settings(_hash, byteData.getUint32(1));
  //       break;
  //     case 20: // GPSDATA < 100m
  //     case 21: // < 300m
  //     case 22: // < 500m
  //     case 23: // < 700m
  //     case 24: // > 700m
  //       if (byteDataLength != 9) return;
  //       proc.gpsdata(_hash, byteData);
  //       break;
  //     case 50: // GLOB_GET
  //       if (byteDataLength != 17) return;
  //       proc.getGlob(_hash, byteData);
  //       break;
  //     case 68: // STATS
  //       _sendStats();
  //       break;
  //     default:
  //   }
  // }

  // outbox

  // Отправить клиенту зарегистрированный hash
  void _sendHashCode() {
    // csv
    String data = [Codes.hashResponse, _hash, _registrar.reghash].join(','); // CODE 12
    sendCsv(data);
    // arraybuffer
    // ByteData byteData = new ByteData(9);
    // byteData.setUint8(0, 12);
    // byteData.setUint32(1, _hash);
    // byteData.setUint32(5, _registrar.reghash);
    // Uint8List uint8list = byteData.buffer.asUint8List();
    // _socket.add(uint8list);
  }

  void _sendStats() {
    // csv
    String data = [Codes.statsResponse, proc.getStats()].join(','); // CODE 69
    sendCsv(data);
    // arraybuffer
    // ByteData byteData = new ByteData(5);
    // byteData.setUint8(0, 69);
    // byteData.setUint32(1, proc.getStats());
    // Uint8List uint8list = byteData.buffer.asUint8List();
    // _socket.add(uint8list);
  }
  
  // logic

  void _register(int code, int h1, int r) {
    int h2 = _socket.hashCode; // reserve
    _hash = _registrar.entrance(code, h1, r, h2, this);
    _sendHashCode();
  }

  // tools

  /// Отправить данные через ws
  //csv
  void sendCsv(String data) {
    try {
      if (_socket.readyState == WebSocket.OPEN) _socket.add(data);
    } catch (e) {
      Rec.it('${Rec.typeERR} conn sendCsv() $e', always: true);
    }
  }
  // arraybuffer
  // void send(Uint8List data) => _socket.add(data);

  String ipAddr() => _info['ip'];

  String device() => _info['dc'];
  // String userAgent() => _info['ua'];

}