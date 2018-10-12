library whyn_server;

import 'dart:async';

import 'proc/proc.dart' as proc;
import 'registrar/registrar.dart';
import 'web_server/web_server.dart';
import 'kernel/config.dart';
import 'kernel/rec.dart';

main() async {

  if (Config.load() == false) {
    return;
  }
  Rec.it('${Rec.typeINFO} RunTime: ${new DateTime.now()}', always: true);
  Rec.it('${Rec.typeINFO} app: ${Config.app}', always: true);
  Rec.it('${Rec.typeINFO} srv: ${Config.srv}', always: true);
  Rec.it('${Rec.typeINFO} ssl: ${Config.ssl}', always: true);
  Rec.it('${Rec.typeINFO} fullchain: ${Config.fullchain}', always: true);
  Rec.it('${Rec.typeINFO} privkey: ${Config.privkey}', always: true);
  Rec.it('${Rec.typeINFO} addr: ${Config.addr}', always: true);
  Rec.it('${Rec.typeINFO} port: ${Config.port}', always: true);
  Rec.it('${Rec.typeINFO} origin: ${Config.origin}', always: true);

  new Registrar();
  await proc.root();

  new Timer(const Duration(seconds: 6), () {
    new WebServer();
  });

}
