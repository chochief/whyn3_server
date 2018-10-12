part of camp;

/// Класс вспомогательных статических методов
/// для отправки byte-данных из camp вовне
/// (т.е. в root-изолятор и дальше)
class Byter {

  static Camp _camp;
  static set camp(Camp c) {
    if (_camp == null) _camp = c;
  }
  
  /// Уведомить получателей о передвижении member
  static void notifyAboutMove(int code, Set recipients, Lifer member) {
    if (recipients.length > 0) {
      // arraybuffer
      // ByteData byteData = new ByteData(14);
      // byteData.setUint8(0, code);
      // byteData.setUint32(1, member.hash);
      // byteData.setInt32(5, member.mla);
      // byteData.setInt32(9, member.mlo);
      // byteData.setUint8(13, member.mark);
      // Uint8List data = byteData.buffer.asUint8List();
      // csv
      String data = [code, member.hash, member.mla, member.mlo, member.mark].join(',');
      // sending
      _camp.rootPort.send({
        'f': _camp.isoName,
        'c': code,
        'r': recipients,
        'd': data,
      });
    }
  }

  /// Уведомить получателей о lifer (hash), отправив code
  static void notifyAboutHash(int code, Set recipients, int hash) {
    if (recipients.length > 0) {
      // arraybuffer
      // ByteData byteData = new ByteData(5);
      // byteData.setUint8(0, code);
      // byteData.setUint32(1, hash);
      // Uint8List data = byteData.buffer.asUint8List();
      // csv
      String data = [code, hash].join(',');
      // sending
      _camp.rootPort.send({
        'f': _camp.isoName,
        'c': code,
        'r': recipients,
        'd': data,
      });
    }
  }

  /// Отправить package для lifer (hash)
  /// с кодом code точек points
  static void sendPackage(int code, int hash, Set<Lifer> points) {
    if (points.length > 0) {
      // arraybuffer
      // ByteData byteData = new ByteData(points.length*13+1);
      // byteData.setUint8(0, code);
      // int byteOffset = 1;
      // points.forEach((p) {
      //   byteData.setUint32(byteOffset, p.hash);
      //   byteData.setInt32(byteOffset+4, p.mla);
      //   byteData.setInt32(byteOffset+8, p.mlo);
      //   byteData.setUint8(byteOffset+12, p.mark);
      //   byteOffset += 13;
      // });
      // Uint8List data = byteData.buffer.asUint8List();
      // csv
      List list = [code];
      points.forEach((p) {
        list.add(p.hash); list.add(p.mla); list.add(p.mlo); list.add(p.mark);
      });
      String data = list.join(',');
      // sending
      _camp.rootPort.send({
        'f': _camp.isoName,
        'c': code,
        'h': hash,
        'd': data,
      });
    }
  }

  /// Отправить команду (code) на клиент lifer (hash)
  static void sendCommand(int code, int hash) {
    // arraybuffer
    // ByteData byteData = new ByteData(1);
    // byteData.setUint8(0, code);
    // Uint8List data = byteData.buffer.asUint8List();
    // csv
    String data = '$code';
    // sending
    _camp.rootPort.send({
      'f': _camp.isoName,
      'c': code,
      'h': hash,
      'd': data,
    });
  }

}