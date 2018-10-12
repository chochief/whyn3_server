library web_server;

import 'dart:io';
import 'dart:async';

import 'package:WhynServer/kernel/config.dart';
import 'package:WhynServer/connection/connection.dart';
import 'package:WhynServer/proc/proc.dart' as proc;
import 'package:WhynServer/kernel/rec.dart';
import 'package:WhynServer/registrar/registrar.dart';

class WebServer {
  Registrar _registrar;
  SecurityContext _scontext; // wss
  RegExp _device = new RegExp(r'[^A-Za-z0-9]'); // рег.выражение - все кроме букв и цифр

  WebServer() {
    _registrar = new Registrar();
    if (Config.ssl) {
      // wss
      String fullchain = Config.fullchain;
      String privkey = Config.privkey;
      _scontext = new SecurityContext();
      _scontext.useCertificateChain(fullchain);
      _scontext.usePrivateKey(privkey);
    }
    Rec.it('${Rec.typeINFO} web_server is running ...', always: true);
    Rec.it('${Rec.typeINFO} operatingSystem ${Platform.operatingSystem}', always: true);
    Rec.it('${Rec.typeINFO} ${Platform.numberOfProcessors} processors', always: true);
    _start();
  }

  _start() async {
    try {
      var server;
      if (Config.ssl == false) server = await HttpServer.bind(Config.addr, Config.port);
      else server = await HttpServer.bindSecure(Config.addr, Config.port, _scontext);
      await for (HttpRequest req in server) {
        try {
          String reqPath = _tryGetPath(req);
          if (_isValidOrigin(req) == false) _response404(req);
          else if (reqPath == null || reqPath == '') _response404(req);
          else if (reqPath == '/socket') _respTemp(await WebSocketTransformer.upgrade(req));
          else {
            if (await proc.checkSocket(reqPath)) {
              String ip;
              String ua;
              String dc;
              try {
                ip = req.connectionInfo.remoteAddress.address;
                ua = req.headers.value(HttpHeaders.USER_AGENT);
                dc = _getDeviceFrom(ua);
              } catch (e) {
                Rec.it('${Rec.typeWARN} web_server problems with ip or ua or d | $e', always: true);
              }
              new Connection(await WebSocketTransformer.upgrade(req), {'ip': ip, 'dc': dc});
            } else {
              _response404(req);
              Rec.it('${Rec.typeWARN} _response404 checkSocket false $reqPath', always: true);
            }
          }
        } catch (e) {
          Rec.it('${Rec.typeERR} web_server await HttpRequest $e', always: true);
        }
      }
    } catch (e) {
      Rec.it('${Rec.typeERR} web_server _start() | ${e}', always: true);
      // reboot
      _registrar.reboot(); // выводим всех в офлайн в реестре
      proc.reboot(); // чистим maper_iso и camp_iso
      proc.stats = 0; // обнуляем статистику
      new Timer(const Duration(seconds: 10), () {
        // подождем пока почистятся _registry, maper, camp
        // и перезагружаем web_server
        _start(); 
      });
    }
  }

  void _respTemp(WebSocket socket) {
    String hash = socket.hashCode.toString(); // temporary hash
    Rec.it('_respTemp (start) $hash');
    proc.storeTemporary(hash);
    socket.add(hash);
    socket.listen((dynamic data) {
      // закрытие сокета по команде с клиента
      if (data is String && data == 'X') _close(socket); // socket.close();
      else {
        Rec.it('${Rec.typeWARN} web_server _respTemp wrong close-code', always: true);
        _close(socket); // socket.close();
      }
    });
    // socket.close(); ! на клиенте надо закрывать этот временный сокет
    Rec.it('_respTemp   (end) $hash');
  }

  void _close(WebSocket socket) {
    try {
      socket.close();
    } catch (e) {
      Rec.it('${Rec.typeERR} web_server close() $e', always: true);
    }
  }

  void _response404(HttpRequest req) {
    req.response.statusCode = 404;
    req.response.write('Not found!');
    req.response.close();
  }

  /// Безопасное получение path
  String _tryGetPath(HttpRequest req) {
    String p;
    try {
      p = req.uri.path;
    } catch (e) {
      Rec.it('${Rec.typeWARN} web_server _response404 req.uri.path | $e', always: true);
    }
    return p;
  }

  /// Безопасная проверка Origin
  bool _isValidOrigin(HttpRequest req) {
    String origin;
    try {
      origin = req.headers.value('Origin');
    } catch (e) {
      Rec.it('${Rec.typeWARN} web_server _response404 origin problems $origin | $e', always: true);
    }
    return origin == Config.origin; 
  }

  /// Безопасное получение устройства из UserAgent
  String _getDeviceFrom(String useragent) {
    String device = '';
    try {
      if (useragent == null || useragent == '') return device;
      int left = useragent.indexOf('(');
      if (left > 0) left++; else return device;
      if (left >= useragent.length) return device;
      int right = useragent.indexOf(')');
      if (right > 0) {
        device = useragent.substring(left, right);
        device = device.replaceAll(_device, ''); // удаляем все кроме букв и цифр
      }
    } catch (e) {
      print('WARN getDeviceFrom useragent $useragent');
      device = '';
    }
    return device;
  }

}

