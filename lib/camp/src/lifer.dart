part of camp;

class Lifer {
  Camp _camp;

  // Stats _stats;
  final int _uniq;
  String userdata;

  int _hash;
  int get hash => _hash;
  void set hash(int v) {
    _hash = v;
  }

  /// Определяет получать ли уведомления от подписок !
  bool _online;
  bool get online => _online;
  set online(bool v) {
    _online = v;
    // if (_online == true) _stats.setComeTime(); // время входа для stats
    // else pause = true; // _online -> false -> включаем паузу !
    if (_online == false) pause = true; // _online -> false -> включаем паузу !
    _marking();
  }

  int _mla;
  int get mla => _mla;

  int _mlo;
  int get mlo => _mlo;

  num _la;
  num get la => _la;
  num _lo;
  num get lo => _lo;

  int _samf;
  int get samf => _samf;

  Set<String> _chats;
  Set<String> _underchats;
  Set<String> get underchats => _underchats;

  int _mark;
  int get mark => _mark;

  /// Текущее членство лайфера
  String _membership;
  String get membership => _membership;
  void set membership(String v) {
    _membership = v;
  }

  /// Подписки лайфера (максимум 8 шт.)
  /// не включаю членство
  Set<String> _subscriptions;
  Set<String> get subscriptions => _subscriptions;
  void set subscriptions(Set<String> v) {
    _subscriptions = v;
  }

  /// Наличие паузы в получении данных
  /// если был away (переподключение), 
  /// значит изменения не приходили, и нужен package
  bool pause;

  Lifer(this._camp, this._hash, this._uniq) {
    // _stats = new Stats(_camp, _uniq, this);
    _samfChange(9); // _samf = 9 и т.д.
    online = true; // _marking() в set online вызовется
    pause = true;
  }

  /// Установка значения метки
  /// 0 - f онлайн | 1 - m онлайн | 6 - n онлайн | 8 - офлайн
  void _marking() {
    if (_samf == null) return;
    int m;
    if (online == false) m = 8;
    else {
      // String sa = Samf.saFromSamf(_samf);
      // if (sa == 'nn') m = 6;
      if (_chats.contains('nnnn')) m = 6;
      else {
        String sex = Samf.sexFromSamf(_samf);
        if (sex == 'f') m = 0;
        else if (sex == 'm') m = 1;
        else m = 6;
      }
    }
    _mark = m;
  }

  /// Пересчитать свойства производные от samf
  void _samfChange(int nsamf) {
    _samf = nsamf;
    _chats = Samf.chats(_samf);
    _underchats = Samf.underchats(_chats);
  }

  // public for camp_iso

  void settings(int nsamf) {
    if (nsamf == null) return;
    if (_samf == nsamf) return; // нет изменений

    if (pause) {
      // если это первый обновляющий состояние samf
      // либо смена samf до первого после паузы gpsdata()
      // просто меняем samf и производные
      _samfChange(nsamf);
      _marking(); // !
    } else {
      // если это смена samf с актуальным gpsdata()
      // уведомляем перед изменением samf
      sleep(); 
      // изменяем samf и производные
      _samfChange(nsamf);
      _marking(); // !
      // заходим после изменения samf
      gpsdata(_mla, _mlo); 
    }

    // if (membership != null) 
    //   _camp.sector(membership).rechat(this);

    // print('pause: $pause');
    // if (pause == false) {
    //   /**
    //    * pause false, иначе gps-данные старые
    //    * т.е. скоро придут новые и обновят всё через gpsdata()
    //    * если pause false - данные свежие, и можно получить пакеты 
    //    * и сделать 30 MOVE
    //    * поскольку получаем пакеты - samfDelay на клиенте должен чистить карту
    //    */
    //   _updatePoints();
    //   _camp.sector(membership).move(this);
    // }
  }

  /// Получить точки секторов по координатам tA и tC экрана
  void glob(int tamla, int tamlo, int tcmla, int tcmlo) {
    if (Mapco.validate(tamla, tamlo) == false || 
        Mapco.validate(tcmla, tcmlo) == false) {
      Rec.it('${Rec.typeWARN} glob bounds validate false', always: true);
      return; // отбрасываем
    }
    num tala = Mapco.micro(tamla);
    num talo = Mapco.micro(tamlo);
    num tcla = Mapco.micro(tcmla);
    num tclo = Mapco.micro(tcmlo);
    Set<String> sectors = Mapco.screenSectors([tala, talo], [tcla, tclo]);
    Set<Lifer> points = new Set<Lifer>();
    sectors.forEach((s) {
      points.addAll(_camp.sector(s).getPointsFor(this));
    });
    Byter.sendPackage(Codes.globPackage, hash, points); // 54 GLOB_PACKAGE
  }

  /// Обновить данные по подпискам и членству
  void _updatePoints() {
    _camp.sector(membership).come(this);
    subscriptions.forEach((s) {
      _camp.sector(s).subscribe(this);
    });
  }

  /// Подключить лайфера как с нуля
  /// членство и подписки
  void _updateConnections(String entry) {
    membership = entry;
    subscriptions =  Mapco.sectors(_mla, _mlo);
    _updatePoints();
    _camp.sector(membership).move(this);
  }

  void gpsdata(int vmla, int vmlo) {
    if (Mapco.validate(vmla, vmlo) == false) {
      Rec.it('${Rec.typeWARN} gpsdata validate false', always: true);
      return; // отбрасываем
    }
    _mla = vmla;
    _mlo = vmlo;
    _la = Mapco.micro(_mla);
    _lo = Mapco.micro(_mlo);
    String entry = Mapco.sector(_la, _lo);
    if (membership == null) {
      _updateConnections(entry);
    } else if (membership == entry) {
      if (pause == true) _updatePoints();
      /**
       * если pause true, значит это новое подключение
       * значит карта клиента почищена в т.ч.
       */
      _camp.sector(membership).move(this);
    } else if (membership != entry) {
      /**
       * не экономим, т.к. пакеты обновятся только у одного лайфера
       * что всегда происходит при подключении - то же будет при смене сектора
       * экономии минимум, а сложность сильно вверх уходит (если иначе)
       */
      // выходим из членства и отписываемся 
      _camp.sector(membership).leave(this, _camp.sector(entry));
      subscriptions.forEach((String s) {
        _camp.sector(s).unsubscribe(this);
      });
      // подключаемся как с нуля
      _updateConnections(entry);
      Byter.sendCommand(Codes.recount, hash); // 37 RECOUNT_UNSUBSCRIBES
    } else Rec.it('${Rec.typeWARN} lifer gpsdata 4th', always: true);
    
    if (pause == true) {
      // /** обновляем начальные координаты когда они придут после паузы */
      // _stats.comeLa = _la;
      // _stats.comeLo = _lo;
      // /** также возьмем comeSamf */
      // _stats.setComeSamf();
      Rec.csv('COME,${new DateTime.now().toIso8601String()},$_mla,$_mlo,$userdata,$hash,$_uniq,$samf');
    }
    pause = false; // gpsdata прерывает паузу
  }

  /// Действие при перезагрузке
  void reboot() {
    membership = null;
    subscriptions.clear();
    online = false;
  }

  /// Перевестись в офлайн (уведомить подписчиков)
  /// (соединение wsocket закрыто)
  void away() {
    // _camp.sector(membership).offline(this); // уведомить подписчиков сектора
    online = false; // перевести lifer в offline
    sleep();
    // _stats.sendCsv();
    Rec.csv('AWAY,${new DateTime.now().toIso8601String()},$_mla,$_mlo,$userdata,$hash,$_uniq,$samf');
  }

  /**
   * ни в цикле, ни по таймеру запускать sleep не будем !
   * но может быть из away сразу - пока да !
   * метод запускается из settings !
   * фишка пусть будет - маленькие точки остаются
   * не мешают - т.к. они офлайн, значит не будут уведомляться
   * по количеству не должно превышать побывавших пользователей (браузеров)
   */
  /// Удалить членство и подписки
  /// т.е. удаляем маленькую точку с карт подписчиков
  void sleep() {
    // удаление членства
    if (membership != null) {
      _camp.sector(membership).clear(this);
      membership = null;
    }
    // удаление подписок
    subscriptions.forEach((s) {
      _camp.sector(s).unsubscribe(this);
    });
    subscriptions.clear();
  }

  /// Поиск пересечения чатов
  bool chating(Set<String> chs) => _chats.intersection(chs).length > 0;

  /// Подключен ли данный sector к лайферу
  /// т.е. наблюдается ли он (членство или подписка)
  bool connecting(String sector) => 
    sector == membership || subscriptions.contains(sector);

}
