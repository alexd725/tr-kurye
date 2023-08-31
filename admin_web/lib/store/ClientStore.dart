import 'package:mobx/mobx.dart';

import '../utils/Constants.dart';
import '../utils/Extensions/shared_pref.dart';
part 'ClientStore.g.dart';

class ClientStore = _ClientStore with _$ClientStore;

abstract class _ClientStore with Store {
  @observable
  String clientEmail = '';

  @observable
  int isCurrentIndex = 0;

  @observable
  String clientUid = '';

  @observable
  int isCurrentIndexOfSendPackage = 0;

  @observable
  num availableBal = 0;

  @observable
  int allUnreadCount = 0;

  @observable
  bool isFiltering = false;

  @action
  Future<void> setClientEmail(String val, {bool isInitialization = false}) async {
    clientEmail = val;
  }

  @action
  Future<void> setClientUId(String val, {bool isInitializing = false}) async {
    clientUid = val;
    if (!isInitializing) await setValue(UID, val);
  }

  @action
  void setIndex(int val) {
    isCurrentIndex = val;
  }

  @action
  Future<void> setFiltering(bool val) async {
    isFiltering = val;
  }

  @action
  Future<void> setAllUnreadCount(int val) async {
    allUnreadCount = val;
  }
}
