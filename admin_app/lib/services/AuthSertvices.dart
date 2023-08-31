import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../main.dart';
import '../models/LoginResponse.dart';
import '../models/UserModel.dart';
import '../network/RestApis.dart';
import '../utils/Extensions/app_common.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;

class AuthServices {
  Future<void> signUpWithEmailPassword( context,
      {String? name, String? email, String? password, LoginResponse? userData, String? mobileNumber, String? lName, String? userName, bool? isOTP, String? userType,bool isAddUser=false}) async {
    UserCredential? userCredential = await _auth.createUserWithEmailAndPassword(email: email!, password: password!);
    log('Step2-------');
    if (userCredential.user != null) {
      User currentUser = userCredential.user!;

      UserModel userModel = UserModel();

      /// Create user
      userModel.uid = currentUser.uid;
      userModel.email = currentUser.email;
      userModel.contactNumber = userData!.data!.contactNumber;
      userModel.name = userData.data!.name;
      userModel.username = userData.data!.username;
      userModel.userType = userData.data!.userType;
      userModel.longitude = userData.data!.longitude;
      userModel.latitude = userData.data!.longitude;
      userModel.countryName = userData.data!.countryName;
      userModel.cityName = userData.data!.cityName;
      userModel.status = userData.data!.status;
      userModel.playerId = userData.data!.playerId;
      userModel.profileImage = userData.data!.profileImage;
      userModel.createdAt = Timestamp.now().toDate().toString();
      userModel.updatedAt = Timestamp.now().toDate().toString();
    //  userModel.playerId = getStringAsync(USER_PLAYER_ID);
      await userService.addDocumentWithCustomId(currentUser.uid, userModel.toJson()).then((value) async {

      }).catchError((e) {
        appStore.setLoading(false);
        toast(e.toString());
      });
    } else {
      throw 'Some thing went wrong';
    }
  }
}