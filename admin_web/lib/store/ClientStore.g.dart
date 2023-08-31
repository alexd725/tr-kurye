// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ClientStore.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$ClientStore on _ClientStore, Store {
  late final _$clientEmailAtom =
      Atom(name: '_ClientStore.clientEmail', context: context);

  @override
  String get clientEmail {
    _$clientEmailAtom.reportRead();
    return super.clientEmail;
  }

  @override
  set clientEmail(String value) {
    _$clientEmailAtom.reportWrite(value, super.clientEmail, () {
      super.clientEmail = value;
    });
  }

  late final _$isCurrentIndexAtom =
      Atom(name: '_ClientStore.isCurrentIndex', context: context);

  @override
  int get isCurrentIndex {
    _$isCurrentIndexAtom.reportRead();
    return super.isCurrentIndex;
  }

  @override
  set isCurrentIndex(int value) {
    _$isCurrentIndexAtom.reportWrite(value, super.isCurrentIndex, () {
      super.isCurrentIndex = value;
    });
  }

  late final _$clientUidAtom =
      Atom(name: '_ClientStore.clientUid', context: context);

  @override
  String get clientUid {
    _$clientUidAtom.reportRead();
    return super.clientUid;
  }

  @override
  set clientUid(String value) {
    _$clientUidAtom.reportWrite(value, super.clientUid, () {
      super.clientUid = value;
    });
  }

  late final _$isCurrentIndexOfSendPackageAtom =
      Atom(name: '_ClientStore.isCurrentIndexOfSendPackage', context: context);

  @override
  int get isCurrentIndexOfSendPackage {
    _$isCurrentIndexOfSendPackageAtom.reportRead();
    return super.isCurrentIndexOfSendPackage;
  }

  @override
  set isCurrentIndexOfSendPackage(int value) {
    _$isCurrentIndexOfSendPackageAtom
        .reportWrite(value, super.isCurrentIndexOfSendPackage, () {
      super.isCurrentIndexOfSendPackage = value;
    });
  }

  late final _$availableBalAtom =
      Atom(name: '_ClientStore.availableBal', context: context);

  @override
  num get availableBal {
    _$availableBalAtom.reportRead();
    return super.availableBal;
  }

  @override
  set availableBal(num value) {
    _$availableBalAtom.reportWrite(value, super.availableBal, () {
      super.availableBal = value;
    });
  }

  late final _$allUnreadCountAtom =
      Atom(name: '_ClientStore.allUnreadCount', context: context);

  @override
  int get allUnreadCount {
    _$allUnreadCountAtom.reportRead();
    return super.allUnreadCount;
  }

  @override
  set allUnreadCount(int value) {
    _$allUnreadCountAtom.reportWrite(value, super.allUnreadCount, () {
      super.allUnreadCount = value;
    });
  }

  late final _$isFilteringAtom =
      Atom(name: '_ClientStore.isFiltering', context: context);

  @override
  bool get isFiltering {
    _$isFilteringAtom.reportRead();
    return super.isFiltering;
  }

  @override
  set isFiltering(bool value) {
    _$isFilteringAtom.reportWrite(value, super.isFiltering, () {
      super.isFiltering = value;
    });
  }

  late final _$setClientEmailAsyncAction =
      AsyncAction('_ClientStore.setClientEmail', context: context);

  @override
  Future<void> setClientEmail(String val, {bool isInitialization = false}) {
    return _$setClientEmailAsyncAction.run(
        () => super.setClientEmail(val, isInitialization: isInitialization));
  }

  late final _$setClientUIdAsyncAction =
      AsyncAction('_ClientStore.setClientUId', context: context);

  @override
  Future<void> setClientUId(String val, {bool isInitializing = false}) {
    return _$setClientUIdAsyncAction
        .run(() => super.setClientUId(val, isInitializing: isInitializing));
  }

  late final _$setFilteringAsyncAction =
      AsyncAction('_ClientStore.setFiltering', context: context);

  @override
  Future<void> setFiltering(bool val) {
    return _$setFilteringAsyncAction.run(() => super.setFiltering(val));
  }

  late final _$setAllUnreadCountAsyncAction =
      AsyncAction('_ClientStore.setAllUnreadCount', context: context);

  @override
  Future<void> setAllUnreadCount(int val) {
    return _$setAllUnreadCountAsyncAction
        .run(() => super.setAllUnreadCount(val));
  }

  late final _$_ClientStoreActionController =
      ActionController(name: '_ClientStore', context: context);

  @override
  void setIndex(int val) {
    final _$actionInfo = _$_ClientStoreActionController.startAction(
        name: '_ClientStore.setIndex');
    try {
      return super.setIndex(val);
    } finally {
      _$_ClientStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
clientEmail: ${clientEmail},
isCurrentIndex: ${isCurrentIndex},
clientUid: ${clientUid},
isCurrentIndexOfSendPackage: ${isCurrentIndexOfSendPackage},
availableBal: ${availableBal},
allUnreadCount: ${allUnreadCount},
isFiltering: ${isFiltering}
    ''';
  }
}
