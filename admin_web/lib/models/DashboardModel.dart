import '../models/OrderModel.dart';
import '../models/UserModel.dart';

class DashboardModel {
  int? totalCountry;
  int? totalCity;
  int? totalClient;
  int? totalDeliveryMan;
  int? totalOrder;
  int? todayRegisterUser;
  double? totalEarning;
  int? totalCancelledOrder;
  int? totalCreateOrder;
  int? totalActiveOrder;
  int? totalDelayedOrder;
  int? totalCourierAssignedOrder;
  int? totalCourierPickedUpOrder;
  int? totalCourierDepartedOrder;
  int? totalCourierArrivedOrder;
  int? totalCompletedOrder;
  int? totalFailedOrder;
  int? todayCreateOrder;
  int? todayActiveOrder;
  int? todayDelayedOrder;
  int? todayCancelledOrder;
  int? todayCourierAssignedOrder;
  int? todayCourierPickedUpOrder;
  int? todayCourierDepartedOrder;
  int? todayCourierArrivedOrder;
  int? todayCompletedOrder;
  int? todayFailedOrder;
  AppSetting? appSetting;
  List<OrderModel>? upcomingOrder;
  List<RecentOrder>? recentOrder;
  List<UserModel>? recentClient;
  List<UserModel>? recentDeliveryMan;
  Week? week;
  List<WeeklyOrderCount>? weeklyOrderCount;
  List<WeeklyOrderCount>? userWeeklyCount;
  int? allUnreadCount;
  List<WeeklyOrderCount>? weeklyPaymentReport;
  Month? month;
  List<MonthlyOrderCount>? monthlyOrderCount;
  List<MonthlyPaymentCompletedReport>? monthlyPaymentCompletedReport;
  List<MonthlyPaymentCompletedReport>? monthlyPaymentCancelledReport;

  DashboardModel(
      {this.totalCountry,
      this.totalCity,
      this.totalClient,
      this.totalDeliveryMan,
      this.totalOrder,
      this.todayRegisterUser,
      this.totalEarning,
      this.totalCancelledOrder,
      this.totalCreateOrder,
      this.totalActiveOrder,
      this.totalDelayedOrder,
      this.totalCourierAssignedOrder,
      this.totalCourierPickedUpOrder,
      this.totalCourierDepartedOrder,
      this.totalCourierArrivedOrder,
      this.totalCompletedOrder,
      this.totalFailedOrder,
      this.todayCreateOrder,
      this.todayActiveOrder,
      this.todayDelayedOrder,
      this.todayCancelledOrder,
      this.todayCourierAssignedOrder,
      this.todayCourierPickedUpOrder,
      this.todayCourierDepartedOrder,
      this.todayCourierArrivedOrder,
      this.todayCompletedOrder,
      this.todayFailedOrder,
      this.appSetting,
      this.upcomingOrder,
      this.recentOrder,
      this.recentClient,
      this.recentDeliveryMan,
      this.week,
      this.weeklyOrderCount,
      this.userWeeklyCount,
      this.allUnreadCount,
      this.weeklyPaymentReport,
      this.month,
      this.monthlyOrderCount,
      this.monthlyPaymentCompletedReport,
      this.monthlyPaymentCancelledReport});

  DashboardModel.fromJson(Map<String, dynamic> json) {
    totalCountry = json['total_country'];
    totalCity = json['total_city'];
    totalClient = json['total_client'];
    totalDeliveryMan = json['total_delivery_man'];
    totalOrder = json['total_order'];
    todayRegisterUser = json['today_register_user'];
    totalEarning = json['total_earning'];
    totalCancelledOrder = json['total_cancelled_order'];
    totalCreateOrder = json['total_create_order'];
    totalActiveOrder = json['total_active_order'];
    totalDelayedOrder = json['total_delayed_order'];
    totalCourierAssignedOrder = json['total_courier_assigned_order'];
    totalCourierPickedUpOrder = json['total_courier_picked_up_order'];
    totalCourierDepartedOrder = json['total_courier_departed_order'];
    totalCourierArrivedOrder = json['total_courier_arrived_order'];
    totalCompletedOrder = json['total_completed_order'];
    totalFailedOrder = json['total_failed_order'];
    todayCreateOrder = json['today_create_order'];
    todayActiveOrder = json['today_active_order'];
    todayDelayedOrder = json['today_delayed_order'];
    todayCancelledOrder = json['today_cancelled_order'];
    todayCourierAssignedOrder = json['today_courier_assigned_order'];
    todayCourierPickedUpOrder = json['today_courier_picked_up_order'];
    todayCourierDepartedOrder = json['today_courier_departed_order'];
    todayCourierArrivedOrder = json['today_courier_arrived_order'];
    todayCompletedOrder = json['today_completed_order'];
    todayFailedOrder = json['today_failed_order'];
    appSetting = json['app_setting'] != null ? new AppSetting.fromJson(json['app_setting']) : null;
    upcomingOrder = json['upcoming_order'] != null ? (json['upcoming_order'] as List).map((i) => OrderModel.fromJson(i)).toList() : null;

    if (json['recent_order'] != null) {
      recentOrder = <RecentOrder>[];
      json['recent_order'].forEach((v) {
        recentOrder!.add(new RecentOrder.fromJson(v));
      });
    }
    if (json['recent_client'] != null) {
      recentClient = <UserModel>[];
      json['recent_client'].forEach((v) {
        recentClient!.add(new UserModel.fromJson(v));
      });
    }
    if (json['recent_delivery_man'] != null) {
      recentDeliveryMan = <UserModel>[];
      json['recent_delivery_man'].forEach((v) {
        recentDeliveryMan!.add(new UserModel.fromJson(v));
      });
    }
    week = json['week'] != null ? new Week.fromJson(json['week']) : null;
    if (json['weekly_order_count'] != null) {
      weeklyOrderCount = <WeeklyOrderCount>[];
      json['weekly_order_count'].forEach((v) {
        weeklyOrderCount!.add(new WeeklyOrderCount.fromJson(v));
      });
    }
    userWeeklyCount = json['user_weekly_count'] != null ? (json['user_weekly_count'] as List).map((i) => WeeklyOrderCount.fromJson(i)).toList() : null;

    allUnreadCount = json['all_unread_count'];
    if (json['weekly_payment_report'] != null) {
      weeklyPaymentReport = <WeeklyOrderCount>[];
      json['weekly_payment_report'].forEach((v) {
        weeklyPaymentReport!.add(new WeeklyOrderCount.fromJson(v));
      });
    }
    month = json['month'] != null ? new Month.fromJson(json['month']) : null;
    if (json['monthly_order_count'] != null) {
      monthlyOrderCount = <MonthlyOrderCount>[];
      json['monthly_order_count'].forEach((v) {
        monthlyOrderCount!.add(new MonthlyOrderCount.fromJson(v));
      });
    }
    if (json['monthly_payment_completed_report'] != null) {
      monthlyPaymentCompletedReport = <MonthlyPaymentCompletedReport>[];
      json['monthly_payment_completed_report'].forEach((v) {
        monthlyPaymentCompletedReport!.add(new MonthlyPaymentCompletedReport.fromJson(v));
      });
    }
    if (json['monthly_payment_cancelled_report'] != null) {
      monthlyPaymentCancelledReport = <MonthlyPaymentCompletedReport>[];
      json['monthly_payment_cancelled_report'].forEach((v) {
        monthlyPaymentCancelledReport!.add(new MonthlyPaymentCompletedReport.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['total_country'] = this.totalCountry;
    data['total_city'] = this.totalCity;
    data['total_client'] = this.totalClient;
    data['total_delivery_man'] = this.totalDeliveryMan;
    data['total_order'] = this.totalOrder;
    data['today_register_user'] = this.todayRegisterUser;
    data['total_earning'] = this.totalEarning;
    data['total_cancelled_order'] = this.totalCancelledOrder;
    data['total_create_order'] = this.totalCreateOrder;
    data['total_active_order'] = this.totalActiveOrder;
    data['total_delayed_order'] = this.totalDelayedOrder;
    data['total_courier_assigned_order'] = this.totalCourierAssignedOrder;
    data['total_courier_picked_up_order'] = this.totalCourierPickedUpOrder;
    data['total_courier_departed_order'] = this.totalCourierDepartedOrder;
    data['total_courier_arrived_order'] = this.totalCourierArrivedOrder;
    data['total_completed_order'] = this.totalCompletedOrder;
    data['total_failed_order'] = this.totalFailedOrder;
    data['today_create_order'] = this.todayCreateOrder;
    data['today_active_order'] = this.todayActiveOrder;
    data['today_delayed_order'] = this.todayDelayedOrder;
    data['today_cancelled_order'] = this.todayCancelledOrder;
    data['today_courier_assigned_order'] = this.todayCourierAssignedOrder;
    data['today_courier_picked_up_order'] = this.todayCourierPickedUpOrder;
    data['today_courier_departed_order'] = this.todayCourierDepartedOrder;
    data['today_courier_arrived_order'] = this.todayCourierArrivedOrder;
    data['today_completed_order'] = this.todayCompletedOrder;
    data['today_failed_order'] = this.todayFailedOrder;
    if (this.appSetting != null) {
      data['app_setting'] = this.appSetting!.toJson();
    }
    if (this.upcomingOrder != null) {
      data['upcoming_order'] = this.upcomingOrder!.map((v) => v.toJson()).toList();
    }
    if (this.recentOrder != null) {
      data['recent_order'] = this.recentOrder!.map((v) => v.toJson()).toList();
    }
    if (this.recentClient != null) {
      data['recent_client'] = this.recentClient!.map((v) => v.toJson()).toList();
    }
    if (this.recentDeliveryMan != null) {
      data['recent_delivery_man'] = this.recentDeliveryMan!.map((v) => v.toJson()).toList();
    }
    if (this.week != null) {
      data['week'] = this.week!.toJson();
    }
    if (this.weeklyOrderCount != null) {
      data['weekly_order_count'] = this.weeklyOrderCount!.map((v) => v.toJson()).toList();
    }
    if (this.userWeeklyCount != null) {
      data['user_weekly_count'] = this.userWeeklyCount!.map((v) => v.toJson()).toList();
    }
    data['all_unread_count'] = this.allUnreadCount;
    if (this.weeklyPaymentReport != null) {
      data['weekly_payment_report'] = this.weeklyPaymentReport!.map((v) => v.toJson()).toList();
    }
    if (this.month != null) {
      data['month'] = this.month!.toJson();
    }
    if (this.monthlyOrderCount != null) {
      data['monthly_order_count'] = this.monthlyOrderCount!.map((v) => v.toJson()).toList();
    }
    if (this.monthlyPaymentCompletedReport != null) {
      data['monthly_payment_completed_report'] = this.monthlyPaymentCompletedReport!.map((v) => v.toJson()).toList();
    }
    if (this.monthlyPaymentCancelledReport != null) {
      data['monthly_payment_cancelled_report'] = this.monthlyPaymentCancelledReport!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class AppSetting {
  int? id;
  String? siteName;
  String? siteEmail;
  String? siteDescription;
  String? siteCopyright;
  String? facebookUrl;
  String? twitterUrl;
  String? linkedinUrl;
  String? instagramUrl;
  String? supportNumber;
  String? supportEmail;
  NotificationSettings? notificationSettings;
  int? autoAssign;
  String? distanceUnit;
  int? distance;
  int? otpVerifyOnPickupDelivery;
  String? currency;
  String? currencyCode;
  String? currencyPosition;
  String? createdAt;
  String? updatedAt;

  AppSetting(
      {this.id,
      this.siteName,
      this.siteEmail,
      this.siteDescription,
      this.siteCopyright,
      this.facebookUrl,
      this.twitterUrl,
      this.linkedinUrl,
      this.instagramUrl,
      this.supportNumber,
      this.supportEmail,
      this.notificationSettings,
      this.autoAssign,
      this.distanceUnit,
      this.distance,
      this.otpVerifyOnPickupDelivery,
      this.currency,
      this.currencyCode,
      this.currencyPosition,
      this.createdAt,
      this.updatedAt});

  AppSetting.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    siteName = json['site_name'];
    siteEmail = json['site_email'];
    siteDescription = json['site_description'];
    siteCopyright = json['site_copyright'];
    facebookUrl = json['facebook_url'];
    twitterUrl = json['twitter_url'];
    linkedinUrl = json['linkedin_url'];
    instagramUrl = json['instagram_url'];
    supportNumber = json['support_number'];
    supportEmail = json['support_email'];
    notificationSettings = json['notification_settings'] != null ? new NotificationSettings.fromJson(json['notification_settings']) : null;
    autoAssign = json['auto_assign'];
    distanceUnit = json['distance_unit'];
    distance = json['distance'];
    otpVerifyOnPickupDelivery = json['otp_verify_on_pickup_delivery'];
    currency = json['currency'];
    currencyCode = json['currency_code'];
    currencyPosition = json['currency_position'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['site_name'] = this.siteName;
    data['site_email'] = this.siteEmail;
    data['site_description'] = this.siteDescription;
    data['site_copyright'] = this.siteCopyright;
    data['facebook_url'] = this.facebookUrl;
    data['twitter_url'] = this.twitterUrl;
    data['linkedin_url'] = this.linkedinUrl;
    data['instagram_url'] = this.instagramUrl;
    data['support_number'] = this.supportNumber;
    data['support_email'] = this.supportEmail;
    if (this.notificationSettings != null) {
      data['notification_settings'] = this.notificationSettings!.toJson();
    }
    data['auto_assign'] = this.autoAssign;
    data['distance_unit'] = this.distanceUnit;
    data['distance'] = this.distance;
    data['otp_verify_on_pickup_delivery'] = this.otpVerifyOnPickupDelivery;
    data['currency'] = this.currency;
    data['currency_code'] = this.currencyCode;
    data['currency_position'] = this.currencyPosition;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    return data;
  }
}

class NotificationSettings {
  Active? active;
  Active? create;
  Active? failed;
  Active? delayed;
  Active? cancelled;
  Active? completed;
  Active? courierArrived;
  Active? courierAssigned;
  Active? courierDeparted;
  Active? courierTransfer;
  Active? courierPickedUp;
  Active? paymentStatusMessage;

  NotificationSettings(
      {this.active,
      this.create,
      this.failed,
      this.delayed,
      this.cancelled,
      this.completed,
      this.courierArrived,
      this.courierAssigned,
      this.courierDeparted,
      this.courierTransfer,
      this.courierPickedUp,
      this.paymentStatusMessage});

  NotificationSettings.fromJson(Map<String, dynamic> json) {
    active = json['active'] != null ? new Active.fromJson(json['active']) : null;
    create = json['create'] != null ? new Active.fromJson(json['create']) : null;
    failed = json['failed'] != null ? new Active.fromJson(json['failed']) : null;
    delayed = json['delayed'] != null ? new Active.fromJson(json['delayed']) : null;
    cancelled = json['cancelled'] != null ? new Active.fromJson(json['cancelled']) : null;
    completed = json['completed'] != null ? new Active.fromJson(json['completed']) : null;
    courierArrived = json['courier_arrived'] != null ? new Active.fromJson(json['courier_arrived']) : null;
    courierAssigned = json['courier_assigned'] != null ? new Active.fromJson(json['courier_assigned']) : null;
    courierDeparted = json['courier_departed'] != null ? new Active.fromJson(json['courier_departed']) : null;
    courierTransfer = json['courier_transfer'] != null ? new Active.fromJson(json['courier_transfer']) : null;
    courierPickedUp = json['courier_picked_up'] != null ? new Active.fromJson(json['courier_picked_up']) : null;
    paymentStatusMessage = json['payment_status_message'] != null ? new Active.fromJson(json['payment_status_message']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.active != null) {
      data['active'] = this.active!.toJson();
    }
    if (this.create != null) {
      data['create'] = this.create!.toJson();
    }
    if (this.failed != null) {
      data['failed'] = this.failed!.toJson();
    }
    if (this.delayed != null) {
      data['delayed'] = this.delayed!.toJson();
    }
    if (this.cancelled != null) {
      data['cancelled'] = this.cancelled!.toJson();
    }
    if (this.completed != null) {
      data['completed'] = this.completed!.toJson();
    }
    if (this.courierArrived != null) {
      data['courier_arrived'] = this.courierArrived!.toJson();
    }
    if (this.courierAssigned != null) {
      data['courier_assigned'] = this.courierAssigned!.toJson();
    }
    if (this.courierDeparted != null) {
      data['courier_departed'] = this.courierDeparted!.toJson();
    }
    if (this.courierTransfer != null) {
      data['courier_transfer'] = this.courierTransfer!.toJson();
    }
    if (this.courierPickedUp != null) {
      data['courier_picked_up'] = this.courierPickedUp!.toJson();
    }
    if (this.paymentStatusMessage != null) {
      data['payment_status_message'] = this.paymentStatusMessage!.toJson();
    }
    return data;
  }
}

class Active {
  String? iSFIREBASENOTIFICATION;
  String? iSONESIGNALNOTIFICATION;

  Active({this.iSFIREBASENOTIFICATION, this.iSONESIGNALNOTIFICATION});

  Active.fromJson(Map<String, dynamic> json) {
    iSFIREBASENOTIFICATION = json['IS_FIREBASE_NOTIFICATION'];
    iSONESIGNALNOTIFICATION = json['IS_ONESIGNAL_NOTIFICATION'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['IS_FIREBASE_NOTIFICATION'] = this.iSFIREBASENOTIFICATION;
    data['IS_ONESIGNAL_NOTIFICATION'] = this.iSONESIGNALNOTIFICATION;
    return data;
  }
}

class RecentOrder {
  int? id;
  int? clientId;
  String? clientName;
  String? date;
  String? readableDate;
  PickupPoint? pickupPoint;
  PickupPoint? deliveryPoint;
  int? countryId;
  String? countryName;
  int? cityId;
  String? cityName;
  String? parcelType;
  int? totalWeight;
  double? totalDistance;
  int? weightCharge;
  double? distanceCharge;
  String? pickupDatetime;
  String? deliveryDatetime;
  int? parentOrderId;
  String? status;
  int? paymentId;
  String? paymentType;
  String? paymentStatus;
  String? paymentCollectFrom;
  int? deliveryManId;
  String? deliveryManName;
  int? fixedCharges;
  List<ExtraCharges>? extraCharges;
  double? totalAmount;
  int? totalParcel;
  String? reason;
  int? pickupConfirmByClient;
  int? pickupConfirmByDeliveryMan;
  String? pickupTimeSignature;
  String? deliveryTimeSignature;
  int? autoAssign;
  List<String>? cancelledDeliveryManIds;
  String? deletedAt;
  bool? returnOrderId;

  RecentOrder(
      {this.id,
      this.clientId,
      this.clientName,
      this.date,
      this.readableDate,
      this.pickupPoint,
      this.deliveryPoint,
      this.countryId,
      this.countryName,
      this.cityId,
      this.cityName,
      this.parcelType,
      this.totalWeight,
      this.totalDistance,
      this.weightCharge,
      this.distanceCharge,
      this.pickupDatetime,
      this.deliveryDatetime,
      this.parentOrderId,
      this.status,
      this.paymentId,
      this.paymentType,
      this.paymentStatus,
      this.paymentCollectFrom,
      this.deliveryManId,
      this.deliveryManName,
      this.fixedCharges,
      this.extraCharges,
      this.totalAmount,
      this.totalParcel,
      this.reason,
      this.pickupConfirmByClient,
      this.pickupConfirmByDeliveryMan,
      this.pickupTimeSignature,
      this.deliveryTimeSignature,
      this.autoAssign,
      this.cancelledDeliveryManIds,
      this.deletedAt,
      this.returnOrderId});

  RecentOrder.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    clientId = json['client_id'];
    clientName = json['client_name'];
    date = json['date'];
    readableDate = json['readable_date'];
    pickupPoint = json['pickup_point'] != null ? new PickupPoint.fromJson(json['pickup_point']) : null;
    deliveryPoint = json['delivery_point'] != null ? new PickupPoint.fromJson(json['delivery_point']) : null;
    countryId = json['country_id'];
    countryName = json['country_name'];
    cityId = json['city_id'];
    cityName = json['city_name'];
    parcelType = json['parcel_type'];
    totalWeight = json['total_weight'];
    totalDistance = json['total_distance'];
    weightCharge = json['weight_charge'];
    distanceCharge = json['distance_charge'];
    pickupDatetime = json['pickup_datetime'];
    deliveryDatetime = json['delivery_datetime'];
    parentOrderId = json['parent_order_id'];
    status = json['status'];
    paymentId = json['payment_id'];
    paymentType = json['payment_type'];
    paymentStatus = json['payment_status'];
    paymentCollectFrom = json['payment_collect_from'];
    deliveryManId = json['delivery_man_id'];
    deliveryManName = json['delivery_man_name'];
    fixedCharges = json['fixed_charges'];
    if (json['extra_charges'] != null) {
      extraCharges = <ExtraCharges>[];
      json['extra_charges'].forEach((v) {
        extraCharges!.add(new ExtraCharges.fromJson(v));
      });
    }
    totalAmount = json['total_amount'];
    totalParcel = json['total_parcel'];
    reason = json['reason'];
    pickupConfirmByClient = json['pickup_confirm_by_client'];
    pickupConfirmByDeliveryMan = json['pickup_confirm_by_delivery_man'];
    pickupTimeSignature = json['pickup_time_signature'];
    deliveryTimeSignature = json['delivery_time_signature'];
    autoAssign = json['auto_assign'];
    // if (json['cancelled_delivery_man_ids'] != null) {
    //   cancelledDeliveryManIds = <String>[];
    //   json['cancelled_delivery_man_ids'].forEach((v) {
    //     cancelledDeliveryManIds!.add(new String.fromJson(v));
    //   });
    // }
    deletedAt = json['deleted_at'];
    returnOrderId = json['return_order_id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['client_id'] = this.clientId;
    data['client_name'] = this.clientName;
    data['date'] = this.date;
    data['readable_date'] = this.readableDate;
    if (this.pickupPoint != null) {
      data['pickup_point'] = this.pickupPoint!.toJson();
    }
    if (this.deliveryPoint != null) {
      data['delivery_point'] = this.deliveryPoint!.toJson();
    }
    data['country_id'] = this.countryId;
    data['country_name'] = this.countryName;
    data['city_id'] = this.cityId;
    data['city_name'] = this.cityName;
    data['parcel_type'] = this.parcelType;
    data['total_weight'] = this.totalWeight;
    data['total_distance'] = this.totalDistance;
    data['weight_charge'] = this.weightCharge;
    data['distance_charge'] = this.distanceCharge;
    data['pickup_datetime'] = this.pickupDatetime;
    data['delivery_datetime'] = this.deliveryDatetime;
    data['parent_order_id'] = this.parentOrderId;
    data['status'] = this.status;
    data['payment_id'] = this.paymentId;
    data['payment_type'] = this.paymentType;
    data['payment_status'] = this.paymentStatus;
    data['payment_collect_from'] = this.paymentCollectFrom;
    data['delivery_man_id'] = this.deliveryManId;
    data['delivery_man_name'] = this.deliveryManName;
    data['fixed_charges'] = this.fixedCharges;
    if (this.extraCharges != null) {
      data['extra_charges'] = this.extraCharges!.map((v) => v.toJson()).toList();
    }
    data['total_amount'] = this.totalAmount;
    data['total_parcel'] = this.totalParcel;
    data['reason'] = this.reason;
    data['pickup_confirm_by_client'] = this.pickupConfirmByClient;
    data['pickup_confirm_by_delivery_man'] = this.pickupConfirmByDeliveryMan;
    data['pickup_time_signature'] = this.pickupTimeSignature;
    data['delivery_time_signature'] = this.deliveryTimeSignature;
    data['auto_assign'] = this.autoAssign;
    // if (this.cancelledDeliveryManIds != null) {
    //   data['cancelled_delivery_man_ids'] =
    //       this.cancelledDeliveryManIds!.map((v) => v.toJson()).toList();
    // }
    data['deleted_at'] = this.deletedAt;
    data['return_order_id'] = this.returnOrderId;
    return data;
  }
}

class PickupPoint {
  String? address;
  String? endTime;
  String? latitude;
  String? longitude;
  String? startTime;
  String? description;
  String? contactNumber;

  PickupPoint({this.address, this.endTime, this.latitude, this.longitude, this.startTime, this.description, this.contactNumber});

  PickupPoint.fromJson(Map<String, dynamic> json) {
    address = json['address'];
    endTime = json['end_time'];
    latitude = json['latitude'];
    longitude = json['longitude'];
    startTime = json['start_time'];
    description = json['description'];
    contactNumber = json['contact_number'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['address'] = this.address;
    data['end_time'] = this.endTime;
    data['latitude'] = this.latitude;
    data['longitude'] = this.longitude;
    data['start_time'] = this.startTime;
    data['description'] = this.description;
    data['contact_number'] = this.contactNumber;
    return data;
  }
}

class ExtraCharges {
  String? key;
  int? value;
  String? valueType;

  ExtraCharges({this.key, this.value, this.valueType});

  ExtraCharges.fromJson(Map<String, dynamic> json) {
    key = json['key'];
    value = json['value'];
    valueType = json['value_type'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['key'] = this.key;
    data['value'] = this.value;
    data['value_type'] = this.valueType;
    return data;
  }
}

class RecentClient {
  int? id;
  String? name;
  String? email;
  String? username;
  int? status;
  String? userType;
  int? countryId;
  String? countryName;
  int? cityId;
  String? cityName;
  String? address;
  String? contactNumber;
  String? createdAt;
  String? updatedAt;
  String? profileImage;
  String? loginType;
  String? latitude;
  String? longitude;
  String? uid;
  String? playerId;
  String? fcmToken;
  String? lastNotificationSeen;
  int? isVerifiedDeliveryMan;
  String? deletedAt;
  String? userBankAccount;

  RecentClient(
      {this.id,
      this.name,
      this.email,
      this.username,
      this.status,
      this.userType,
      this.countryId,
      this.countryName,
      this.cityId,
      this.cityName,
      this.address,
      this.contactNumber,
      this.createdAt,
      this.updatedAt,
      this.profileImage,
      this.loginType,
      this.latitude,
      this.longitude,
      this.uid,
      this.playerId,
      this.fcmToken,
      this.lastNotificationSeen,
      this.isVerifiedDeliveryMan,
      this.deletedAt,
      this.userBankAccount});

  RecentClient.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    email = json['email'];
    username = json['username'];
    status = json['status'];
    userType = json['user_type'];
    countryId = json['country_id'];
    countryName = json['country_name'];
    cityId = json['city_id'];
    cityName = json['city_name'];
    address = json['address'];
    contactNumber = json['contact_number'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    profileImage = json['profile_image'];
    loginType = json['login_type'];
    latitude = json['latitude'];
    longitude = json['longitude'];
    uid = json['uid'];
    playerId = json['player_id'];
    fcmToken = json['fcm_token'];
    lastNotificationSeen = json['last_notification_seen'];
    isVerifiedDeliveryMan = json['is_verified_delivery_man'];
    deletedAt = json['deleted_at'];
    userBankAccount = json['user_bank_account'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['email'] = this.email;
    data['username'] = this.username;
    data['status'] = this.status;
    data['user_type'] = this.userType;
    data['country_id'] = this.countryId;
    data['country_name'] = this.countryName;
    data['city_id'] = this.cityId;
    data['city_name'] = this.cityName;
    data['address'] = this.address;
    data['contact_number'] = this.contactNumber;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    data['profile_image'] = this.profileImage;
    data['login_type'] = this.loginType;
    data['latitude'] = this.latitude;
    data['longitude'] = this.longitude;
    data['uid'] = this.uid;
    data['player_id'] = this.playerId;
    data['fcm_token'] = this.fcmToken;
    data['last_notification_seen'] = this.lastNotificationSeen;
    data['is_verified_delivery_man'] = this.isVerifiedDeliveryMan;
    data['deleted_at'] = this.deletedAt;
    data['user_bank_account'] = this.userBankAccount;
    return data;
  }
}

class RecentDeliveryMan {
  int? id;
  String? name;
  String? email;
  String? username;
  int? status;
  String? userType;
  int? countryId;
  String? countryName;
  int? cityId;
  String? cityName;
  String? address;
  String? contactNumber;
  String? createdAt;
  String? updatedAt;
  String? profileImage;
  String? loginType;
  String? latitude;
  String? longitude;
  String? uid;
  String? playerId;
  String? fcmToken;
  String? lastNotificationSeen;
  int? isVerifiedDeliveryMan;
  String? deletedAt;
  UserBankAccount? userBankAccount;

  RecentDeliveryMan(
      {this.id,
      this.name,
      this.email,
      this.username,
      this.status,
      this.userType,
      this.countryId,
      this.countryName,
      this.cityId,
      this.cityName,
      this.address,
      this.contactNumber,
      this.createdAt,
      this.updatedAt,
      this.profileImage,
      this.loginType,
      this.latitude,
      this.longitude,
      this.uid,
      this.playerId,
      this.fcmToken,
      this.lastNotificationSeen,
      this.isVerifiedDeliveryMan,
      this.deletedAt,
      this.userBankAccount});

  RecentDeliveryMan.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    email = json['email'];
    username = json['username'];
    status = json['status'];
    userType = json['user_type'];
    countryId = json['country_id'];
    countryName = json['country_name'];
    cityId = json['city_id'];
    cityName = json['city_name'];
    address = json['address'];
    contactNumber = json['contact_number'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    profileImage = json['profile_image'];
    loginType = json['login_type'];
    latitude = json['latitude'];
    longitude = json['longitude'];
    uid = json['uid'];
    playerId = json['player_id'];
    fcmToken = json['fcm_token'];
    lastNotificationSeen = json['last_notification_seen'];
    isVerifiedDeliveryMan = json['is_verified_delivery_man'];
    deletedAt = json['deleted_at'];
    userBankAccount = json['user_bank_account'] != null ? new UserBankAccount.fromJson(json['user_bank_account']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['email'] = this.email;
    data['username'] = this.username;
    data['status'] = this.status;
    data['user_type'] = this.userType;
    data['country_id'] = this.countryId;
    data['country_name'] = this.countryName;
    data['city_id'] = this.cityId;
    data['city_name'] = this.cityName;
    data['address'] = this.address;
    data['contact_number'] = this.contactNumber;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    data['profile_image'] = this.profileImage;
    data['login_type'] = this.loginType;
    data['latitude'] = this.latitude;
    data['longitude'] = this.longitude;
    data['uid'] = this.uid;
    data['player_id'] = this.playerId;
    data['fcm_token'] = this.fcmToken;
    data['last_notification_seen'] = this.lastNotificationSeen;
    data['is_verified_delivery_man'] = this.isVerifiedDeliveryMan;
    data['deleted_at'] = this.deletedAt;
    if (this.userBankAccount != null) {
      data['user_bank_account'] = this.userBankAccount!.toJson();
    }
    return data;
  }
}

class UserBankAccount {
  int? id;
  int? userId;
  String? bankName;
  String? bankCode;
  String? accountHolderName;
  String? accountNumber;
  String? createdAt;
  String? updatedAt;
  String? deletedAt;

  UserBankAccount({this.id, this.userId, this.bankName, this.bankCode, this.accountHolderName, this.accountNumber, this.createdAt, this.updatedAt, this.deletedAt});

  UserBankAccount.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    userId = json['user_id'];
    bankName = json['bank_name'];
    bankCode = json['bank_code'];
    accountHolderName = json['account_holder_name'];
    accountNumber = json['account_number'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    deletedAt = json['deleted_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['user_id'] = this.userId;
    data['bank_name'] = this.bankName;
    data['bank_code'] = this.bankCode;
    data['account_holder_name'] = this.accountHolderName;
    data['account_number'] = this.accountNumber;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    data['deleted_at'] = this.deletedAt;
    return data;
  }
}

class Week {
  String? weekStart;
  String? weekEnd;

  Week({this.weekStart, this.weekEnd});

  Week.fromJson(Map<String, dynamic> json) {
    weekStart = json['week_start'];
    weekEnd = json['week_end'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['week_start'] = this.weekStart;
    data['week_end'] = this.weekEnd;
    return data;
  }
}

class WeeklyOrderCount {
  String? day;
  int? total;
  String? date;
  num? totalAmount;

  WeeklyOrderCount({this.day, this.total, this.date});

  WeeklyOrderCount.fromJson(Map<String, dynamic> json) {
    day = json['day'];
    total = json['total'];
    date = json['date'];
    totalAmount = json['total_amount'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['day'] = this.day;
    data['total'] = this.total;
    data['date'] = this.date;
    data['total_amount'] = this.totalAmount;
    return data;
  }
}

class WeeklyPaymentReport {
  String? day;
  double? totalAmount;
  String? date;

  WeeklyPaymentReport({this.day, this.totalAmount, this.date});

  WeeklyPaymentReport.fromJson(Map<String, dynamic> json) {
    day = json['day'];
    totalAmount = json['total_amount'];
    date = json['date'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['day'] = this.day;
    data['total_amount'] = this.totalAmount;
    data['date'] = this.date;
    return data;
  }
}

class Month {
  String? monthStart;
  String? monthEnd;
  int? diff;

  Month({this.monthStart, this.monthEnd, this.diff});

  Month.fromJson(Map<String, dynamic> json) {
    monthStart = json['month_start'];
    monthEnd = json['month_end'];
    diff = json['diff'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['month_start'] = this.monthStart;
    data['month_end'] = this.monthEnd;
    data['diff'] = this.diff;
    return data;
  }
}

class MonthlyOrderCount {
  int? total;
  String? date;

  MonthlyOrderCount({this.total, this.date});

  MonthlyOrderCount.fromJson(Map<String, dynamic> json) {
    total = json['total'];
    date = json['date'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['total'] = this.total;
    data['date'] = this.date;
    return data;
  }
}

class MonthlyPaymentCompletedReport {
  var totalAmount;
  var date;

  MonthlyPaymentCompletedReport({this.totalAmount, this.date});

  MonthlyPaymentCompletedReport.fromJson(Map<String, dynamic> json) {
    totalAmount = json['total_amount'];
    date = json['date'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['total_amount'] = this.totalAmount;
    data['date'] = this.date;
    return data;
  }
}

// class MonthlyPaymentCancelledReport {
//   int? totalAmount;
//   String? date;
//
//   MonthlyPaymentCancelledReport({this.totalAmount, this.date});
//
//   MonthlyPaymentCancelledReport.fromJson(Map<String, dynamic> json) {
//     totalAmount = json['total_amount'];
//     date = json['date'];
//   }
//
//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = new Map<String, dynamic>();
//     data['total_amount'] = this.totalAmount;
//     data['date'] = this.date;
//     return data;
//   }
// }
