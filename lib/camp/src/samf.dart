part of camp;

class Samf {

  static const int sn = 1; // 1
  static const int sm = 2; // 2
  static const int sf = 4; // 3
  static const int an = 8; // 4
  static const int aa = 16; // 5
  static const int ab = 32; // 6
  static const int ac = 64; // 7
  static const int ad = 128; // 8
  static const int ae = 256; // 9
  static const int af = 512; // 10
  static const int ma = 1024; // 11
  static const int mb = 2048; // 12
  static const int mc = 4096; // 13
  static const int md = 8192; // 14
  static const int me = 16384; // 15
  static const int mf = 32768; // 16
  static const int fa = 65536; // 17
  static const int fb = 131072; // 18
  static const int fc = 262144; // 19
  static const int fd = 524288; // 20
  static const int fe = 1048576; // 21
  static const int ff = 2097152; // 22

  static Map se = {
    'sn': sn,
    'sm': sm,
    'sf': sf,
    'an': an,
    'aa': aa,
    'ab': ab,
    'ac': ac, 
    'ad': ad, 
    'ae': ae, 
    'af': af, 
    'ma': ma, 
    'mb': mb, 
    'mc': mc, 
    'md': md, 
    'me': me, 
    'mf': mf, 
    'fa': fa, 
    'fb': fb, 
    'fc': fc, 
    'fd': fd, 
    'fe': fe, 
    'ff': ff,
  };

  static List ses = [sn, sm, sf];
  static List sea = [an, aa, ab, ac, ad, ae, af];
  static List sem = [ma, mb, mc, md, me, mf];
  static List sef = [fa, fb, fc, fd, fe, ff];

  static Map es = _reverse(se);

  static Map _reverse(Map a) {
    Map b = {};
    a.forEach((String k, int v) {
      if (ses.contains(v) || sea.contains(v)) b[v] = k.substring(1);
      else b[v] = k;
    });
    return b;
  }

  static bool pressed(int samf, int i) {
    if (i == null) return false;
    return (samf & i) != 0;
  }

  static String sexFromSamf(int samf) {
    String s = decode(sn);
    for (var i = 0; i < ses.length; i++) {
      if (pressed(samf, ses[i])) {
        s = decode(ses[i]);
        break;
      }
    }
    return s;
  }

  static String ageFromSamf(int samf) {
    String a = decode(an);
    for (var i = 0; i < sea.length; i++) {
      if (pressed(samf, sea[i])) {
        a = decode(sea[i]);
        break;
      }
    }
    return a;
  }

  /// Извлекает s и a из samf
  static String saFromSamf(int samf) {
    String s = decode(sn);
    String a = decode(an);
    String sa = 'nn';
    for (var i = 0; i < ses.length; i++) {
      if (pressed(samf, ses[i])) {
        s = decode(ses[i]);
        break;
      }
    }
    for (var i = 0; i < sea.length; i++) {
      if (pressed(samf, sea[i])) {
        a = decode(sea[i]);
        break;
      }
    }
    if (s == 'n' || a == 'n') sa = 'nn';
    else sa = '$s$a';
    return sa;
  }

  /// Извлекает все f из samf
  static List<String> mfFromSamf(int samf) {
    List<String> f = [];
    for (var i = 0; i < sem.length; i++) {
      if (pressed(samf, sem[i])) f.add(decode(sem[i]));
    }
    for (var i = 0; i < sef.length; i++) {
      if (pressed(samf, sef[i])) f.add(decode(sef[i]));
    }
    return f;
  }

  /// Возвращает строку значений всех фильтров
  static String filtersFromSamf(int samf) {
    String e = '--';
    List<String> f = [];
    for (var i = 0; i < sem.length; i++) {
      if (pressed(samf, sem[i])) f.add(decode(sem[i]));
      else f.add(e);
    }
    for (var i = 0; i < sef.length; i++) {
      if (pressed(samf, sef[i])) f.add(decode(sef[i]));
      else f.add(e);
    }
    return f.join(',');
  }

  static String decode(int digit) => es[digit];

  static Set<String> chats(int samf) {
    String sa = saFromSamf(samf);
    Set<String> chs = new Set<String>();
    if (sa != 'nn') {
      List<String> filters = mfFromSamf(samf);
      filters.forEach((String f) {
        chs.add('$sa$f');
      });
    }
    if (chs.isEmpty) chs.add('nnnn');
    return chs;
  }

  static String mirror(String chat) {
    if (chat.length != 4) return 'nnnn';
    return '${chat.substring(2)}${chat.substring(0, 2)}';
  }

  static Set<String> underchats(Set<String> chs) {
    Set<String> uchs = new Set<String>();
    chs.forEach((String chat) {
      uchs.add(mirror(chat));
    });
    if (uchs.isEmpty) uchs.add('nnnn');
    return uchs;
  }

}