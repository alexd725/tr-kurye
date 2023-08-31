import 'package:flutter/material.dart';

abstract class BaseLanguage {
  static BaseLanguage? of(BuildContext context) =>
      Localizations.of<BaseLanguage>(context, BaseLanguage);

  String get appName;

  String get updateCity;

  String get addCity;

  String get cityName;

  String get selectCountry;

  String get fixedCharge;

  String get cancelCharge;

  String get minimumDistance;

  String get minimumWeight;

  String get perDistanceCharge;

  String get perWeightCharge;

  String get cancel;

  String get update;

  String get add;

  String get km;

  String get miter;

  String get kg;

  String get pound;

  String get updateCountry;

  String get addCountry;

  String get countryName;

  String get distanceType;

  String get weightType;

  String get pleaseSelectChargeType;

  String get updateExtraCharge;

  String get addExtraCharge;

  String get country;

  String get city;

  String get title;

  String get charge;

  String get chargeType;

  String get updateParcelType;

  String get addParcelType;

  String get label;

  String get value;

  String get cityId;

  String get createdDate;

  String get updatedDate;

  String get id;

  String get status;

  String get actions;

  String get enable;

  String get disable;

  String get youCannotUpdateStatusRecordDeleted;

  String get deliveryBoy;

  String get registerDate;

  String get assign;

  String get assignOrder;

  String get orderTransfer;

  String get extraCharges;

  String get totalDeliveryPerson;

  String get totalCountry;

  String get totalCity;

  String get totalOrder;

  String get recentUser;

  String get recentDelivery;

  String get recentOrder;

  String get orderId;

  String get customerName;

  String get deliveryPerson;

  String get pickupDate;

  String get upcomingOrder;

  String get viewAll;

  String get orders;

  String get pickupAddress;

  String get orderDraft;

  String get orderDeleted;

  String get parcelType;

  String get addParcelTypes;

  String get created;

  String get paymentGateway;

  String get setup;

  String get paymentMethod;

  String get image;

  String get mode;

  String get test;

  String get live;

  String get users;

  String get weeklyOrderCount;

  String get weeklyUserCount;

  String get logout;

  String get adminSignIn;

  String get signInYourAccount;

  String get email;

  String get login;

  String get allNotification;

  String get notification;

  String get subject;

  String get type;

  String get message;

  String get createDate;

  String get orderDetail;

  String get packageInformation;

  String get weight;

  String get paymentInformation;

  String get paymentType;

  String get cash;

  String get paymentCollectFrom;

  String get delivery;

  String get paymentStatus;

  String get cod;

  String get deliveryAddress;

  String get deliveredAt;

  String get picUpSignature;

  String get deliverySignature;

  String get totalDistance;

  String get fixedCharges;

  String get totalCharges;

  String get paymentGatewaySetup;

  String get payment;

  String get secretKey;

  String get publishableKey;

  String get keyId;

  String get secretId;

  String get publicKey;

  String get encryptionKey;

  String get selectFile;

  String get save;

  String get pleaseSelectPaymentGatewayMode;

  String get reallyWantToDeleteThisRecord;

  String get reallyWantToRestoreThisRecord;

  String get reallyWantToEnableThisRecord;

  String get reallyWantToDisableThisRecord;

  String get fieldRequiredMsg;

  String get name;

  String get emailId;

  String get totalUser;

  String get password;

  String get deliveryCharges;

  String get distanceCharge;

  String get weightCharge;

  String get areYouSure;

  String get doYouWantToLogoutFromTheApp;

  String get yes;

  String get dashboard;

  String get allOrder;

  String get setting;

  String get selectLanguage;

  String get selectTheme;

  String get aboutUs;

  String get helpSupport;

  String get notificationSetting;

  String get oneSingle;

  String get create;

  String get active;

  String get courierAssigned;

  String get courierTransfer;

  String get courierArrived;

  String get delayed;

  String get courierPickedUp;

  String get courierDeparted;

  String get paymentStatusMessage;

  String get failed;

  String get youDeleteThisRecoverIt;

  String get draft;

  String get pickedUp;

  String get arrived;

  String get departed;

  String get completed;

  String get cancelled;

  String get demoAdminMsg;

  String get no;

  String get restoreCity;

  String get restoreCityMsg;

  String get deleteCity;

  String get deleteCityMsg;

  String get restoreCountry;

  String get restoreCountryMsg;

  String get deleteCountry;

  String get deleteCountryMsg;

  String get deleteParcelType;

  String get deleteParcelTypeMsg;

  String get restoreOrder;

  String get restoreOrderMsg;

  String get deleteOrder;

  String get deleteOrderMsg;

  String get restoreExtraCharges;

  String get restoreExtraChargesMsg;

  String get deleteExtraCharges;

  String get deleteExtraChargesMsg;

  String get enableUser;

  String get disableUser;

  String get enableUserMsg;

  String get disableUserMsg;

  String get enableDeliveryPerson;

  String get disableDeliveryPerson;

  String get enableDeliveryPersonMsg;

  String get disableDeliveryPersonMsg;

  String get enablePayment;

  String get disablePayment;

  String get enablePaymentMsg;

  String get disablePaymentMsg;

  String get edit;

  String get restore;

  String get delete;

  String get forceDelete;

  String get view;

  String get theme;

  String get page;

  String get lblOf;

  String get order;

  String get transfer;

  String get restoreDeliveryPerson;

  String get restoreDeliveryPersonMsg;

  String get deleteDeliveryPerson;

  String get deleteDeliveryPersonMsg;

  String get userDeleted;

  String get deliveryPersonDeleted;

  String get restoreUser;

  String get restoreUserMsg;

  String get deleteUser;

  String get deleteUserMsg;

  String get deliveryPersonDocuments;

  String get deliveryPersonName;

  String get documentName;

  String get document;

  String get verified;

  String get verifyDocument;

  String get verifyDocumentMsg;

  String get verify;

  String get addDocument;

  String get required;

  String get enableDocument;

  String get disableDocument;

  String get enableDocumentMsg;

  String get disableDocumentMsg;

  String get restoreDocument;

  String get restoreDocumentMsg;

  String get deleteDocument;

  String get deleteDocumentMsg;

  String get pickedAt;

  String get noData;

  String get total;

  String get back;

  String get enableCity;

  String get disableCity;

  String get enableCityMsg;

  String get disableCityMsg;

  String get enableCountry;

  String get disableCountry;

  String get enableCountryMsg;

  String get disableCountryMsg;

  String get isVerified;

  String get enableExtraCharge;

  String get disableExtraCharge;

  String get enableExtraChargeMsg;

  String get disableExtraChargeMsg;

  String get stripe;

  String get razorpay;

  String get payStack;

  String get flutterWave;

  String get sslCommerz;

  String get paypal;

  String get payTabs;

  String get mercadoPago;

  String get paytm;

  String get myFatoorah;

  String get storeId;

  String get storePassword;

  String get tokenizationKey;

  String get accessToken;

  String get profileId;

  String get serverKey;

  String get clientKey;

  String get mId;

  String get merchantKey;

  String get token;

  String get orderSummary;

  String get creteOrder;

  String get pickupCurrentValidationMsg;

  String get pickupDeliverValidationMsg;

  String get deliverNow;

  String get schedule;

  String get pickTime;

  String get endStartTimeValidationMsg;

  String get from;

  String get to;

  String get deliverTime;

  String get date;

  String get numberOfParcels;

  String get pickupInfo;

  String get pickupLocation;

  String get pickupContactNumber;

  String get contactLengthValidation;

  String get pickupDescription;

  String get deliveryInformation;

  String get deliveryLocation;

  String get deliveryContactNumber;

  String get deliveryDescription;

  String get pending;

  String get paid;

  String get onPickup;

  String get onDelivery;

  String get createOrder;

  String get parcelDetails;

  String get paymentDetails;

  String get note;

  String get courierWillPickupAt;

  String get courierWillDeliveredAt;

  String get go;

  String get pleaseEnterOrderId;

  String get indicatesAutoAssignOrder;

  String get appSetting;

  String get orderHistory;

  String get aboutUser;

  String get aboutDeliveryMan;

  String get pleaseSelectDistanceUnit;

  String get firebase;

  String get forAdmin;

  String get orderAutoAssign;

  String get distance;

  String get distanceUnit;

  String get pleaseSelectValidAddress;

  String get selectedAddressValidation;

  String get updateDocument;

  String get pressBackAgainToExit;

  String get previous;

  String get next;

  String get createOrderQue;

  String get createOrderConfirmation;

  String get language;

  String get light;

  String get dark;

  String get systemDefault;

  String get emailValidation;

  String get passwordValidation;

  String get rememberMe;

  String get forgotPassword;

  String get all;

  String get assignOrderConfirmationMsg;

  String get transferOrderConfirmationMsg;

  String get submit;

  String get editProfile;

  String get changePassword;

  String get profile;

  String get oldPassword;

  String get newPassword;

  String get confirmPassword;

  String get passwordNotMatch;

  String get profileUpdatedSuccessfully;

  String get youCannotChangeEmailId;

  String get username;

  String get youCannotChangeUsername;

  String get address;

  String get contactNumber;

  String get weeklyPaymentReport;

  String get otpVerificationOnPickupDelivery;

  String get currencySetting;

  String get currencyPosition;

  String get currencySymbol;

  String get pick;

  String get perPage;

  String get remark;

  String get showMore;

  String get showLess;

  String get choosePickupAddress;

  String get chooseDeliveryAddress;

  String get showingAllAddress;

  String get addNewAddress;

  String get selectPickupLocation;

  String get selectDeliveryLocation;

  String get searchAddress;

  String get pleaseWait;

  String get confirmPickupLocation;

  String get confirmDeliveryLocation;

  String get addressNotInArea;

  String get locationNotExist;

  String get sunday;

  String get monday;

  String get tuesday;

  String get wednesday;

  String get thursday;

  String get friday;

  String get saturday;

  String get commissionType;

  String get adminCommission;

  String get userUpdated;

  String get userAdded;

  String get editUser;

  String get addUser;

  String get editDeliveryPerson;

  String get addDeliveryPerson;

  String get bankName;

  String get accountHolderName;

  String get accountNumber;

  String get ifscCode;

  String get cancelledReason;

  String get withdrawReqList;

  String get amount;

  String get availableBalance;

  String get bankDetails;

  String get accept;

  String get withdrawRequest;

  String get acceptConfirmation;

  String get declinedConfirmation;

  String get somethingWentWrong;

  String get internetNotWorking;

  String get tryAgain;

  String get credentialNotMatch;

  String get wallet;

  String get declined;

  String get approved;

  String get requested;

  String get deliveredTo;

  String get invoiceNo;

  String get invoiceDate;

  String get orderedDate;

  String get invoiceCapital;

  String get product;

  String get price;

  String get subTotal;

  String get description;

  String get viewUser;

  String get viewDeliveryPerson;

  String get walletBalance;

  String get totalWithdraw;

  String get paidOrder;

  String get deliveryManCommission;

  String get walletHistory;

  String get earningHistory;

  String get deliveryManEarning;

  String get assigned;

  String get accepted;

  String get delivered;

  //TODO
  String get vehicle;

  String get add_vehicle;

  String get update_vehicle;

  String get vehicle_size;

  String get vehicle_capacity;

  String get vehicle_image;

  String get select_vehicle;

  String get enable_vehicle;

  String get disable_vehicle;

  String get enable_vehicle_msg;

  String get disable_vehicle_msg;

  String get delete_vehicle;

  String get do_you_want_to_delete_this_vehicle;

  String get vehicle_name;

  String get selectCity;

  String get field_required_msg;

  String get select_file;

  String get restoreVehicle;

  String get restoreVehicleMsg;

  String get deleteVehicleMsg;

  String get pleaseSelectCity;

  String get vehicleAddedSuccessfully;

  String get pleaseSelectImage;

  String get vehicleUpdateSuccessfully;
}
