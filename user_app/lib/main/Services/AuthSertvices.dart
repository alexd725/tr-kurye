import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../main/screens/LoginScreen.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../delivery/screens/DeliveryDashBoard.dart';
import '../../main.dart';
import '../../user/screens/DashboardScreen.dart';
import '../components/UserCitySelectScreen.dart';
import '../models/CityListModel.dart';
import '../models/LoginResponse.dart';
import '../network/RestApis.dart';
import '../utils/Constants.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;

class AuthServices {
  Future<void> updateUserData(UserData user) async {
    userService.updateDocument({
      'player_id': getStringAsync(PLAYER_ID),
      'updatedAt': Timestamp.now(),
    }, user.uid);
  }

  Future<void> signUpWithEmailPassword(context,
      {String? name,
      String? email,
      String? password,
      String? mobileNumber,
      String? lName,
      String? userName,
      bool? isOTP,
      String? userType}) async {
    UserCredential? userCredential = await _auth.createUserWithEmailAndPassword(
        email: email!, password: password!);
    if (userCredential.user != null) {
      // User currentUser = userCredential.user!;
      //
      // UserData userModel = UserData();
      User currentUser = userCredential.user!;
      UserData userModel = UserData();

      /// Create user
      userModel.uid = currentUser.uid;
      userModel.email = currentUser.email;

      // userModel.longitude = userData?.data?.longitude;
      // userModel.latitude = userData?.data?.longitude;
      // userModel.countryName = userData?.data?.countryName;
      // userModel.cityName = userData?.data?.cityName;
      // userModel.status = userData?.data?.status;
      // userModel.playerId = userData?.data?.playerId;
      // userModel.profileImage = userData?.data?.profileImage;
      userModel.uid = currentUser.uid;
      userModel.email = currentUser.email;
      userModel.contactNumber = mobileNumber;
      userModel.name = name;
      userModel.username = userName;
      // userModel.userType = userType;
      userModel.createdAt = Timestamp.now().toDate().toString();
      userModel.updatedAt = Timestamp.now().toDate().toString();
      userModel.playerId = getStringAsync(PLAYER_ID);

      await userService
          .addDocumentWithCustomId(currentUser.uid, userModel.toJson())
          .then((value) async {
        var request = {
          "name": name,
          "username": userName,
          "user_type": userType,
          "contact_number": mobileNumber,
          "email": email,
          "password": password,
          "uid": userModel.uid,
          "player_id": getStringAsync(PLAYER_ID).validate(),
        };
        //Map req = {
        //   "name": nameController.text.trim(),
        //   "username": userNameController.text.trim(),
        //   "email": emailController.text.trim(),
        //   "password": passController.text.validate(),
        //   "user_type": widget.userType.validate(),
        //   "contact_number": '$countryCode ${phoneController.text.trim()}',
        //   "player_id": getStringAsync(PLAYER_ID).validate(),
        // };
        await signUpApi(request).then((res) async {
          if (getStringAsync(USER_TYPE) == DELIVERY_MAN) {
            appStore.setLogin(false);
            LoginScreen().launch(context,
                isNewTask: true, pageRouteAnimation: PageRouteAnimation.Slide);
          } else {
            await logInApi(request).then((res) async {
              UserCitySelectScreen().launch(context,
                  isNewTask: true,
                  pageRouteAnimation: PageRouteAnimation.Slide);
            }).catchError((e) {
              toast(e.toString());
            });
          }
        }).catchError((e) {
          toast(e.toString());
          return;
        });
        appStore.setLoading(false);
      }).catchError((e) {
        appStore.setLoading(false);
        toast(e.toString());
      });
    } else {
      throw errorSomethingWentWrong;
    }
  }

  // Future<void> signUpWithEmailPassword(context,
  //     {
  //       String? name,
  //     String? email,
  //     String? password,
  //     LoginResponse? userData,
  //     String? mobileNumber,
  //     String? lName,
  //     String? userName,
  //     bool? isOTP,
  //     String? userType,
  //     bool isAddUser = false}) async {
  //   UserCredential? userCredential = await _auth.createUserWithEmailAndPassword(
  //       email: email!, password: password!);
  //   log('Step2-------');
  //   if (userCredential.user != null) {
  //     User currentUser = userCredential.user!;
  //     UserData userModel = UserData();
  //     /// Create user
  //     userModel.uid = currentUser.uid;
  //     userModel.email = currentUser.email;
  //     userModel.contactNumber = userData?.data?.contactNumber;
  //     userModel.name = userData?.data?.name;
  //     userModel.username = userData?.data?.username;
  //     userModel.userType = userData?.data?.userType;
  //     userModel.longitude = userData?.data?.longitude;
  //     userModel.latitude = userData?.data?.longitude;
  //     userModel.countryName = userData?.data?.countryName;
  //     userModel.cityName = userData?.data?.cityName;
  //     userModel.status = userData?.data?.status;
  //     userModel.playerId = userData?.data?.playerId;
  //     userModel.profileImage = userData?.data?.profileImage;
  //     //userModel.uid = currentUser.uid;
  //     //userModel.email = currentUser.email;
  //     //userModel.contactNumber = mobileNumber;
  //     //userModel.name = name;
  //     //userModel.username = userName;
  //     //userModel.display_name = displayName;
  //
  //     userModel.userType = userType;
  //     userModel.createdAt = Timestamp.now().toDate().toString();
  //     userModel.updatedAt = Timestamp.now().toDate().toString();
  //     userModel.playerId = getStringAsync(PLAYER_ID);
  //
  //     await userService
  //         .addDocumentWithCustomId(currentUser.uid, userModel.toJson())
  //         .then((value) async {
  //       var request = {
  //         "name": name,
  //         "username": userName,
  //         "user_type": userType,
  //         "contact_number": mobileNumber,
  //         "email": email,
  //         "password": password,
  //         "uid": userModel.uid,
  //         "player_id": getStringAsync(PLAYER_ID).validate(),
  //       };
  //       updateUid(currentUser.uid).then((value) async {
  //         if (userModel.userType == DELIVERY_MAN) {
  //           /*var request = {
  //         "name": name,
  //         "username": userName,
  //         "user_type": userType,
  //         "contact_number": mobileNumber,
  //         "email": email,
  //         "password": password,
  //         "uid": userModel.uid,
  //         "player_id": getStringAsync(PLAYER_ID).validate(),
  //       };
  //       //Map req = {
  //       //   "name": nameController.text.trim(),
  //       //   "username": userNameController.text.trim(),
  //       //   "email": emailController.text.trim(),
  //       //   "password": passController.text.validate(),
  //       //   "user_type": widget.userType.validate(),
  //       //   "contact_number": '$countryCode ${phoneController.text.trim()}',
  //       //   "player_id": getStringAsync(PLAYER_ID).validate(),
  //       // };*/
  //       await signUpApi(request).then((res) async {
  //         if (getStringAsync(USER_TYPE) == DELIVERY_MAN) {
  //           appStore.setLogin(false);
  //           LoginScreen().launch(context,
  //               isNewTask: true, pageRouteAnimation: PageRouteAnimation.Slide);
  //         }
  //
  //         else {
  //          Map request = {"email": email, "password": password};
  //           await logInApi(request).then((res) async {
  //             // UserCitySelectScreen().launch(context,
  //             //     isNewTask: true,
  //             //     pageRouteAnimation: PageRouteAnimation.Slide);
  //             // await signInWithEmailPassword(context,
  //             //         email: email.toString() , password: password.toString())
  //             //     .then((value) {
  //             //   UserCitySelectScreen().launch(context,
  //             //       isNewTask: true,
  //             //       pageRouteAnimation: PageRouteAnimation.Slide);
  //             // });
  //           }).catchError((e) {
  //             print("here is error");
  //             appStore.setLoading(false);
  //             log(e.toString());
  //             toast(e.toString());
  //           });
  //         }
  //         /*}).catchError((e) {
  //         toast(e.toString());
  //         return;*/
  //       });
  //       //appStore.setLoading(false);
  //     }
  //       }).catchError((e) {
  //       log("user login errorrrrr");
  //       appStore.setLoading(false);
  //       toast(e.toString());
  //     }
  //    else {
  //     throw errorSomethingWentWrong;
  //   }
  // }

  // this is for driver

  Future<void> signUpWithEmailPasswordDriver(context,
      {String? idNumber,
      String? name,
      String? email,
      String? password,
      String? mobileNumber,
      String? lName,
      String? userName,
      String? carOrMotor,
      bool? isOTP,
      String? userType,
      String? plateNumber,
      required LoginResponse userData}) async {
    UserCredential? userCredential = await _auth.createUserWithEmailAndPassword(
        email: email!, password: password!);
    if (userCredential.user != null) {
      User currentUser = userCredential.user!;

      UserData userModel = UserData();

      /// Create user
      ///
      userModel.uid = currentUser.uid;
      userModel.idNumber = idNumber;
      userModel.carOrMotor = carOrMotor;
      userModel.email = currentUser.email;
      userModel.contactNumber = mobileNumber;
      userModel.name = name;
      userModel.username = userName;
      //userModel.display_name = displayName;
      userModel.userType = userType;
      userModel.createdAt = Timestamp.now().toDate().toString();
      userModel.updatedAt = Timestamp.now().toDate().toString();
      userModel.playerId = getStringAsync(PLAYER_ID);

      await userService
          .addDocumentWithCustomId(currentUser.uid, userModel.toJson())
          .then((value) async {
        var request = {
          "id_no": idNumber,
          "car_or_moto": carOrMotor,
          "name": name,
          "username": userName,
          "user_type": userType,
          "contact_number": mobileNumber,
          "email": email,
          "password": password,
          "uid": userModel.uid,
          "player_id": getStringAsync(PLAYER_ID).validate(),
          "plate_number": plateNumber,
        };
        //if (getStringAsync(USER_TYPE) == DELIVERY_MAN) {
        appStore.setLogin(false);
        LoginScreen().launch(context,
            isNewTask: true, pageRouteAnimation: PageRouteAnimation.Slide);
        //} else {
        //  await logInApi(request).then((res) async {
        //    UserCitySelectScreen().launch(context,
        //        isNewTask: true, pageRouteAnimation: PageRouteAnimation.Slide);
        //  }).catchError((e) {
        //    toast(e.toString());
        //  });
        //}
        //await signUpApi(request).then((res) async {
        //
        //}).catchError((e) {
        //  toast(e.toString());
        //  return;
        //});
        //appStore.setLoading(false);
      }).catchError((e) {
        appStore.setLoading(false);
        toast(e.toString());
      });
    } else {
      throw errorSomethingWentWrong;
    }
  }

  // this is for corporate

  Future<void> signUpWithEmailPasswordCorporate(context,
      {String? institution,
      String? password,
      String? mobileNumber,
      String? lName,
      String? taxNumber,
      String? email,
      String? taxOffice,
      bool? isOTP,
      String? userType}) async {
    UserCredential? userCredential = await _auth.createUserWithEmailAndPassword(
        email: email!, password: password!);
    if (userCredential.user != null) {
      User currentUser = userCredential.user!;

      UserData userModel = UserData();

      /// Create user
      userModel.uid = currentUser.uid;
      userModel.email = currentUser.email;
      userModel.contactNumber = mobileNumber;
      userModel.institutionName = institution;
      userModel.taxOffice = taxOffice;
      userModel.taxNumber = taxNumber;
      userModel.name = institution;
      userModel.username = email;
      //userModel.display_name = displayName;
      userModel.userType = userType;
      userModel.createdAt = Timestamp.now().toDate().toString();
      userModel.updatedAt = Timestamp.now().toDate().toString();
      userModel.playerId = getStringAsync(PLAYER_ID);

      await userService
          .addDocumentWithCustomId(currentUser.uid, userModel.toJson())
          .then((value) async {
        var request = {
          "name": institution,
          "institutions": institution,
          "tax_office": taxOffice,
          "tax_number": taxNumber,
          "username": email,
          "user_type": userType,
          "contact_number": mobileNumber,
          "email": email,
          "password": password,
          "uid": userModel.uid,
          "player_id": getStringAsync(PLAYER_ID).validate(),
        };
        //Map req = {
        //   "name": nameController.text.trim(),
        //   "username": userNameController.text.trim(),
        //   "email": emailController.text.trim(),
        //   "password": passController.text.validate(),
        //   "user_type": widget.userType.validate(),
        //   "contact_number": '$countryCode ${phoneController.text.trim()}',
        //   "player_id": getStringAsync(PLAYER_ID).validate(),
        // };
        await signUpApi(request).then((res) async {
          if (getStringAsync(USER_TYPE) == DELIVERY_MAN) {
            appStore.setLogin(false);
            LoginScreen().launch(context,
                isNewTask: true, pageRouteAnimation: PageRouteAnimation.Slide);
          } else {
            await logInApi(request).then((res) async {
              UserCitySelectScreen().launch(context,
                  isNewTask: true,
                  pageRouteAnimation: PageRouteAnimation.Slide);
            }).catchError((e) {
              print("issue1 is here");
              toast(e.toString());
            });
          }
        }).catchError((e) {
          print("issue2 is here");
          // toast(e.toString());
          return;
        });
        appStore.setLoading(false);
      }).catchError((e) {
        appStore.setLoading(false);
        print("issue3 is here");
        // toast(e.toString());
      });
    } else {
      throw errorSomethingWentWrong;
    }
  }

  // Future<void> signIn(context, {String? email, String? password, LoginResponse? res}) async {
  //   UserCredential? userCredential = await _auth.createUserWithEmailAndPassword(email: email!, password: password!);
  //   if (userCredential != null && userCredential.user != null) {
  //     User currentUser = userCredential.user!;
  //
  //     UserData userModel = UserData();
  //
  //     /// Create user
  //     userModel.uid = currentUser.uid;
  //     userModel.email = currentUser.email;
  //     userModel.contactNumber = res!.data!.contactNumber;
  //     userModel.name = res.data!.name;
  //     userModel.username = res.data!.username;
  //     userModel.countryId = res.data!.countryId;
  //     userModel.address = res.data!.address;
  //     userModel.cityId = res.data!.cityId;
  //     userModel.userType = CLIENT;
  //     userModel.createdAt = Timestamp.now().toDate().toString();
  //     userModel.updatedAt = Timestamp.now().toDate().toString();
  //     userModel.playerId = getStringAsync(PLAYER_ID);
  //
  //     await userService.addDocumentWithCustomId(currentUser.uid, userModel.toJson()).then((value) async {
  //       appStore.setUId(currentUser.uid);
  //
  //       await signInWithEmailPassword(context, email: email, password: password).then((value) {
  //         //
  //       });
  //     });
  //   } else {
  //     throw errorSomethingWentWrong;
  //   }
  // }

  Future<void> signInWithEmailPassword(context,
      {required String email, required String password}) async {
    await _auth
        .signInWithEmailAndPassword(email: email, password: password)
        .then((value) async {
      appStore.setLoading(true);
      final User user = value.user!;
      UserData userModel = await userService.getUser(email: user.email);
      await updateUserData(userModel);

      appStore.setLoading(true);
      //Login Details to SharedPreferences
      setValue(UID, userModel.id.validate());
      setValue(USER_EMAIL, userModel.email.validate());
      setValue(IS_LOGGED_IN, true);
      setValue(TAX_NUMBER, userModel.taxNumber.validate());
      setValue(TAX_OFFICE, userModel.taxOffice.validate());

      updateUid(getStringAsync(UID)).then((value) {
        log("value...." + value.toString());
      });

      //Login Details to AppStore
      //appStore.setUserEmail(userModel.email.validate());
      //appStore.setUId(userModel.uid.validate());

      //
    }).catchError((e) {
      log(e.toString());
    });
  }

  Future<void> loginFromFirebaseUser(User currentUser,
      {LoginResponse? loginDetail,
      String? fullName,
      String? fName,
      String? lName}) async {
    UserData userModel = UserData();

    if (await userService.isUserExist(loginDetail!.data!.email)) {
      ///Return user data
      await userService.userByEmail(loginDetail.data!.email).then((user) async {
        userModel = user;
        appStore.setUserEmail(userModel.email.validate());
        appStore.setUId(userModel.uid.validate());

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
      userModel.playerId = getStringAsync(PLAYER_ID);

      setValue(UID, currentUser.uid.validate());
      print(
          "_______________________________________________ ${getStringAsync(UID)}");
      log(getStringAsync(UID));
      setValue(USER_EMAIL, userModel.email.validate());
      setValue(IS_LOGGED_IN, true);

      log(userModel.toJson());

      await userService
          .addDocumentWithCustomId(currentUser.uid, userModel.toJson())
          .then((value) {
        //
      }).catchError((e) {
        throw e;
      });
    }
  }

// Future<void> signUpWithOTP(context, {String? name, String? email, String? password, String? mobileNumber, String? lName, String? userName, String? verificationId, String? otpCode}) async {
//   AuthCredential credential = PhoneAuthProvider.credential(verificationId: verificationId.validate(), smsCode: otpCode.validate());
//   await FirebaseAuth.instance.signInWithCredential(credential).then((result) async {
//     if (result != null && result.user != null) {
//       User currentUser = result.user!;
//
//       UserData userModel = UserData();
//       var displayName = name! + lName!;
//
//       /// Create user
//      // userModel.uid = currentUser.uid;
//       userModel.email = currentUser.email;
//       userModel.contactNumber = mobileNumber;
//       userModel.name = name;
//       userModel.username = userName;
//       userModel.userType = CLIENT;
//       userModel.createdAt = Timestamp.now().toDate().toString();
//       userModel.updatedAt = Timestamp.now().toDate().toString();
//
//       await userService.addDocumentWithCustomId(currentUser.uid, userModel.toJson()).then((value) async {
//         var request = {
//           UserKeys.firstName: name,
//           UserKeys.lastName: lName,
//           UserKeys.userName: userName,
//           UserKeys.userType: LoginTypeUser,
//           UserKeys.contactNumber: mobileNumber,
//           UserKeys.email: email,
//           UserKeys.password: password,
//           UserKeys.uid: userModel.uid,
//           UserKeys.loginType: getStringAsync(LOGIN_TYPE)
//         };
//         await createUser(request).then((res) async {
//           await loginUser(request).then((res) async {
//             DashboardScreen(index: 0).launch(context, isNewTask: true, pageRouteAnimation: PageRouteAnimation.Slide);
//           }).catchError((e) {
//             toast(e.toString());
//           });
//         }).catchError((e) {
//           toast(e.toString());
//           return;
//         });
//         appStore.setLoading(false);
//
//       }).catchError((e) {
//         appStore.setLoading(false);
//         toast(e.toString());
//       });
//     } else {
//       throw errorSomethingWentWrong;
//     }
//   });
// }
}

getCountryDetailApiCall(int countryId, context) async {
  await getCountryDetail(countryId).then((value) {
    setValue(COUNTRY_DATA, value.data!.toJson());
  }).catchError((error) {});
}

getCityDetailApiCall(int cityId, context) async {
  await getCityDetail(cityId).then((value) async {
    await setValue(CITY_DATA, value.data!.toJson());
    if (CityModel.fromJson(getJSONAsync(CITY_DATA))
        .name
        .validate()
        .isNotEmpty) {
      if (getStringAsync(USER_TYPE) == CLIENT) {
        DashboardScreen().launch(context, isNewTask: true);
      } else {
        DeliveryDashBoard().launch(context, isNewTask: true);
      }
    } else {
      UserCitySelectScreen().launch(context, isNewTask: true);
    }
  }).catchError((error) {});
}

Future deleteUserFirebase() async {
  if (FirebaseAuth.instance.currentUser != null) {
    FirebaseAuth.instance.currentUser!.delete();
    await FirebaseAuth.instance.signOut();
  }
}
