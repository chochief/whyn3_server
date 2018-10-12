library config;

import 'dart:io';
import 'package:yaml/yaml.dart';
import 'package:WhynServer/kernel/rec.dart';

class Config {
  
  static String app;
  static String srv;
  static bool ssl;
  static String fullchain;
  static String privkey;
  static String addr;
  static int port;
  static String origin;
  static bool csv;
  static bool record;

  static bool load() {
    File config = new File('config.yaml');
    if (config.existsSync() == false) {
      Rec.it('${Rec.typeERR} config.yaml not found', always: true);
      return false;
    }
    String data = config.readAsStringSync();
    if (data == null || data == '') {
      Rec.it('${Rec.typeERR} config.yaml is empty', always: true);
      return false;
    }
    try {
      var yaml = loadYaml(data);
      app = yaml['app'];
      srv = yaml['srv'];
      ssl = yaml['ssl'];
      fullchain = yaml['fullchain'];
      privkey = yaml['privkey'];
      addr = (yaml['addr']).toString().trim();
      port = yaml['port'];
      origin = yaml['origin'];
      csv = yaml['csv'];
      record = yaml['record'];
    } catch (e) {
      Rec.it('${Rec.typeERR} congig.yaml read file error', always: true);
      return false;
    }
    return true;
  }
}