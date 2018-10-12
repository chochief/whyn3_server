part of camp;

class Sector {
  String _key;
  String get key => _key;

  Camp _camp;
  
  Set<Lifer> _members;
  Set<Lifer> _subscribers;
  
  Sector(this._key, this._camp) {
    _members = new Set<Lifer>();
    _subscribers = new Set<Lifer>();
  }

  void reboot() {
    _members.clear();
    _subscribers.clear();
  }

  /// Уведомить подписчиков о переходе member в офлайн 
  /// 39 LIFER_OFFLINE
  void offline(Lifer member) {
    if (_members.contains(member) == false) return;
    Byter.notifyAboutHash(Codes.liferOffline, getRecipientsForNotyfyBy(member), member.hash); 
  }

  /// Уведомить подписчиков об удалении member
  /// и удалить member из сектора
  /// 32 REMOVE
  void clear(Lifer member) {
    if (_members.contains(member) == false) return;
    Byter.notifyAboutHash(Codes.remove, getRecipientsForNotyfyBy(member), member.hash);
    _members.remove(member); // удаление member
  }

  /**
   * Событие - изменение samf у member
   * уведомляем всех членов и подписчиков сектора (только кто online)
   * с кодом 32 REMOVE (т.е. удаляем себя у всех)
   * код 30 MOVE пойдет следом (т.е. будет почти обычное включение)
   */
  void rechat(Lifer member) {
    if (_members.contains(member) == false) return;
    Set recipients = new Set();
    _members.forEach((m) {
      if (m != member && m.online) recipients.add(m.hash);
    });
    _subscribers.forEach((ssc) {
      if (ssc.online) recipients.add(ssc.hash);
    });
    Byter.notifyAboutHash(Codes.remove, recipients, member.hash); // 32 REMOVE
  }

  /// Отписаться от обновлений сектора
  void unsubscribe(Lifer lifer) => _subscribers.remove(lifer); 

  /// Подписаться на обновления сектора
  /// и получить пакет с текущим состоянием
  void subscribe(Lifer lifer, {bool package: true}) {
    if (_subscribers.contains(lifer) == false) _subscribers.add(lifer);
    // отправить пакет с сектором новому подписчику 38 SECTOR_PACKAGE
    if (package) Byter.sendPackage(Codes.sectorPackage, lifer.hash, getPointsFor(lifer)); 
  }

  /// Стать участником сектора
  /// и получить пакет с текущим состоянием
  void come(Lifer member, {bool package: true}) {
    if (_members.contains(member) == false) _members.add(member);
    // отправить пакет сектора новому участнику 38 SECTOR_PACKAGE
    if (package) Byter.sendPackage(Codes.sectorPackage, member.hash, getPointsFor(member)); 
  }

  /// Переместить точку внутри сектора и уведомить подписчиков
  /// 30 MOVE
  void move(Lifer member) {
    if (_members.contains(member) == false) return;
    Byter.notifyAboutMove(Codes.move, getRecipientsForNotyfyBy(member), member);
  }

  /// Выйти из членства в секторе
  /// учитывается пересечение секторов подписчиков
  /// (чтобы не посылать remove а затем move)
  void leave(Lifer member, Sector newSector) {
    if (_members.contains(member) == false) return;
    // уведомляем (об удалении) только тех, у кто не видит нового сектора
    // остальные получат новые данные для hash (и переместят точку)
    Set<String> chats = member.underchats;
    Set recipientsAwayOnly = new Set();
    _members.forEach((m) {
      if (m != member && m.online && m.chating(chats) 
          && m.connecting(newSector.key) == false) recipientsAwayOnly.add(m.hash);
    });
    _subscribers.forEach((ssc) {
      if (ssc.online && ssc.chating(chats) && ssc.connecting(newSector.key) == false)
        recipientsAwayOnly.add(ssc.hash);
    });
    Byter.notifyAboutHash(Codes.remove, recipientsAwayOnly, member.hash); // 32 REMOVE
    _members.remove(member);
  }

  bool hasMember(Lifer lifer) => _members.contains(lifer);

  bool hasSubscriber(Lifer lifer) => _subscribers.contains(lifer);

  /// Собрать получателей уведомления от member
  Set getRecipientsForNotyfyBy(Lifer member) {
    Set<String> chats = member.underchats;
    Set recipients = new Set();
    _members.forEach((m) {
      if (m != member && m.online && m.chating(chats)) recipients.add(m.hash);
    });
    _subscribers.forEach((ssc) {
      if (ssc.online && ssc.chating(chats)) recipients.add(ssc.hash);
    });
    return recipients;
  }

  /// Получить точки сектора, подходящие для lifer
  Set<Lifer> getPointsFor(Lifer lifer) {
    Set<String> chats = lifer.underchats;
    Set<Lifer> points = new Set<Lifer>();
    _members.forEach((m) {
      if (m != lifer && m.chating(chats)) points.add(m);
    });
    return points;
  }

}