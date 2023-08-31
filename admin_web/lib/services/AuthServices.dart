import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../models/CityListModel.dart';
import '../models/UserModel.dart';
import '../utils/Constants.dart';
import '../utils/Extensions/string_extensions.dart';
import '../utils/Extensions/int_extensions.dart';
import '../main.dart';
import '../models/LoginResponse.dart';
import '../network/RestApis.dart';
import '../screens/Client/DashboardScreen.dart';
import '../components/Client/UserCitySelectComponent.dart';
import '../utils/Extensions/common.dart';
import '../utils/Extensions/constants.dart';
import '../utils/Extensions/device_extensions.dart';
import '../utils/Extensions/shared_pref.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;

class AuthServices {
  Future<void> updateUserData(UserModel user) async {
    userService.updateDocument({
      'player_id': getStringAsync(USER_PLAYER_ID),
      'updatedAt': Timestamp.now(),
    }, user.uid);
  }

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
      userModel.playerId = getStringAsync(USER_PLAYER_ID);
      await userService.addDocumentWithCustomId(currentUser.uid, userModel.toJson()).then((value) async {
        if (!isAddUser) {
          Map request = {"email": userModel.email, "password": password};
          await logInApi(request).then((res) async {
            await signInWithEmailPassword(context, email: email, password: password).then((value) {
              showDialog(
                  context: getContext,
                  builder: (_) {
                    return UserCitySelectScreen(onUpdate: () {
                      Navigator.pushNamedAndRemoveUntil(context, DashboardScreen.route, (route) {
                        return true;
                      });
                    });
                  });
            });
          }).catchError((e) {
            appStore.setLoading(false);
            log(e.toString());
            toast(e.toString());
          });
        }
      }).catchError((e) {
        appStore.setLoading(false);
        toast(e.toString());
      });
    } else {
      throw errorSomethingWentWrong;
    }
  }

  Future<void> signInWithEmailPassword(context, {required String email, required String password}) async {
    await _auth.signInWithEmailAndPassword(email: email, password: password).then((value) async {
      appStore.setLoading(true);
      final User user = value.user!;
      UserModel userModel = await userService.getUser(email: user.email);
      await updateUserData(userModel);

      appStore.setLoading(true);
      //Login Details to SharedPreferences
      setValue(UID, userModel.uid.validate());
      setValue(USER_EMAIL, userModel.email.validate());
      setValue(USER_TYPE, userModel.userType);
      setValue(IS_LOGGED_IN, true);

      //Login Details to AppStore
      clientStore.setClientEmail(userModel.email.validate());
      clientStore.setClientUId(userModel.uid.validate());

      //
    }).catchError((e) {
      log(e.toString());
    });
  }

  Future<void> loginFromFirebaseUser(User currentUser, {LoginResponse? loginDetail, String? fullName, String? fName, String? lName}) async {
    UserModel userModel = UserModel();

    if (await userService.isUserExist(loginDetail!.data!.email)) {
      ///Return user data
      await userService.userByEmail(loginDetail.data!.email).then((user) async {
        userModel = user;
        clientStore.setClientEmail(userModel.email.validate());
        clientStore.setClientUId(userModel.uid.validate());

        await updateUserData(user);
      }).catchError((e) {
        log(e);
        throw e;
      });
    } else {
      /// Create user
      userModel.uid = currentUser.uid.validate();
      userModel.id = loginDetail.data!.id.validate();
      userModel.email = loginDetail.data!.email.validate();
      userModel.name = loginDetail.data!.name.validate();
      userModel.contactNumber = loginDetail.data!.contactNumber.validate();
      userModel.username = loginDetail.data!.username.validate();
      userModel.email = loginDetail.data!.email.validate();
      userModel.userType = CLIENT;

      if (isIOS) {
        userModel.username = fullName;
      } else {
        userModel.username = loginDetail.data!.username.validate();
      }

      userModel.contactNumber = loginDetail.data!.contactNumber.validate();
      userModel.profileImage = loginDetail.data!.profileImage.validate();
      userModel.playerId = getStringAsync(USER_PLAYER_ID);

      setValue(UID, currentUser.uid.validate());
      log(getStringAsync(UID));
      setValue(USER_EMAIL, userModel.email.validate());
      setValue(IS_LOGGED_IN, true);

      log(userModel.toJson().toString());

      await userService.addDocumentWithCustomId(currentUser.uid, userModel.toJson()).then((value) {
        //
      }).catchError((e) {
        throw e;
      });
    }
  }
}

getCountryDetailApiCall(int countryId, context) async {
  await getCountryDetail(countryId).then((value) {
    setValue(COUNTRY_DATA, value.toJson());
  }).catchError((error) {});
}

getCityDetailApiCall(int cityId, context) async {
  await getCityDetail(cityId).then((value) async {
    await setValue(CITY_DATA, value.toJson());
    if (CityData.fromJson(getJSONAsync(CITY_DATA)).name.validate().isNotEmpty) {
      if (getStringAsync(USER_TYPE) == CLIENT) {
        Navigator.pushNamedAndRemoveUntil(getContext, DashboardScreen.route, (route) {
          return true;
        });
      }
    } else {
      finish(context);
      showDialog(
          context: context,
          builder: (_) {
            return UserCitySelectScreen();
          });
    }
  }).catchError((error) {});
}

Future deleteUserFirebase() async {
  if (FirebaseAuth.instance.currentUser != null) {
    FirebaseAuth.instance.currentUser!.delete();
    await FirebaseAuth.instance.signOut();
  }
}
