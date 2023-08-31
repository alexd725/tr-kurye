import 'package:cloud_firestore/cloud_firestore.dart';
import '../utils/Constants.dart';
import 'BaseServices.dart';

class UserService extends BaseService {
  FirebaseFirestore fireStore = FirebaseFirestore.instance;

  UserService() {
    ref = fireStore.collection(USER_COLLECTION);
  }
}
