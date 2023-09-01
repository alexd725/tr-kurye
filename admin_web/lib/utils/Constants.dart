import 'package:firebase_core/firebase_core.dart';

const currencySymbolDefault = '₹';
const currencyCodeDefault = 'INR';
const mBaseUrl = "http://10.10.18.72:8000/api/";

const mOneSignalAppId = 'ADD_YOUR_ONE_SIGNAL_APP_ID';
const mOneSignalRestKey = 'ADD_YOUR_ONE_SIGNAL_REST_KEY';
const mOneSignalChannelId = 'ADD_YOUR_ONE_SIGNAL_CHANNEL_ID';

FirebaseOptions firebaseOptions = FirebaseOptions(
  apiKey: "AIzaSyBEIDsKWCjZAGvTwoFs08YABdwz45E-bw0",
  authDomain: "mightydelivery-10da9.firebaseapp.com",
  projectId: "mightydelivery-10da9",
  storageBucket: "mightydelivery-10da9.appspot.com",
  messagingSenderId: "12372904825",
  appId: "1:12372904825:web:1e89ce46dbe7f1fd22fda8",
);

const defaultPhoneCode = '+92';
const defaultCurrencySymbol = '₹';
const defaultCurrencyCode = 'INR';

const minContactLength = 10;
const maxContactLength = 14;
const digitAfterDecimal = 2;

const MESSAGES_COLLECTION = "messages";
const USER_COLLECTION = "users";
const CONTACT_COLLECTION = "contact";
const CHAT_DATA_IMAGES = "chatImages";

const CLIENT = 'client';
const ADMIN = 'admin';
const DELIVERYMAN = 'delivery_man';
const Coorporate = 'corporate';
const DEMO_ADMIN = 'demo_admin';

const textPrimarySizeGlobal = 16.00;
const textBoldSizeGlobal = 16.00;
const textSecondarySizeGlobal = 14.00;
const borderRadius = 16.00;

double tabletBreakpointGlobal = 600.0;
double desktopBreakpointGlobal = 720.0;
double statisticsItemWidth = 230.0;

const RESTORE = 'restore';
const FORCE_DELETE = 'forcedelete';
const DELETE_USER = 'deleted_at';

const CHARGE_TYPE_FIXED = 'fixed';
const CHARGE_TYPE_PERCENTAGE = 'percentage';

const DISTANCE_UNIT_KM = 'km';
const DISTANCE_UNIT_MILE = 'mile';

const PAYMENT_TYPE_STRIPE = 'stripe';
const PAYMENT_TYPE_RAZORPAY = 'razorpay';
const PAYMENT_TYPE_PAYSTACK = 'paystack';
const PAYMENT_TYPE_FLUTTERWAVE = 'flutterwave';
const PAYMENT_TYPE_PAYPAL = 'paypal';
const PAYMENT_TYPE_PAYTABS = 'paytabs';
const PAYMENT_TYPE_MERCADOPAGO = 'mercadopago';
const PAYMENT_TYPE_PAYTM = 'paytm';
const PAYMENT_TYPE_MYFATOORAH = 'myfatoorah';
const PAYMENT_GATEWAY_IYZICO = 'iyzico';
const PAYMENT_GATEWAY_GPAY = 'gpay';
const PAYMENT_TYPE_CASH = 'cash';
const PAYMENT_TYPE_WALLET = 'wallet';
const PAYMENT_GATEWAY_LIST = 'PAYMENT_GATEWAY_LIST';

// OrderStatus
const ORDER_CREATED = 'create';
const ORDER_ACCEPTED = 'active';
const ORDER_CANCELLED = 'cancelled';
const ORDER_DELAYED = 'delayed';
const ORDER_ASSIGNED = 'courier_assigned';
const ORDER_ARRIVED = 'courier_arrived';
const ORDER_PICKED_UP = 'courier_picked_up';
const ORDER_DELIVERED = 'completed';
const ORDER_DRAFT = 'draft';
const ORDER_DEPARTED = 'courier_departed';
const ORDER_TRANSFER = 'courier_transfer';
const ORDER_PAYMENT = 'payment_status_message';
const ORDER_FAIL = 'failed';

const DECLINE = 'decline';
const REQUESTED = 'requested';
const APPROVED = 'approved';

const DIALOG_TYPE_DELETE = 'Delete';
const DIALOG_TYPE_RESTORE = 'Restore';
const DIALOG_TYPE_ENABLE = 'Enable';
const DIALOG_TYPE_DISABLE = 'Disable';

const TOKEN = 'TOKEN';
const USER_ID = 'USER_ID';
const USER_TYPE = 'USER_TYPE';
const USER_EMAIL = 'USER_EMAIL';
const USER_PASSWORD = 'USER_PASSWORD';
const NAME = 'NAME';
const USER_PROFILE_PHOTO = 'USER_PROFILE_PHOTO';
const USER_CONTACT_NUMBER = 'USER_CONTACT_NUMBER';
const USER_NAME = 'USER_NAME';
const USER_ADDRESS = 'USER_ADDRESS';
const IS_LOGGED_IN = 'IS_LOGGED_IN';
const FCM_TOKEN = 'FCM_TOKEN';
const USER_STATUS = 'USER_STATUS';
const USER_PLAYER_ID = 'USER_PLAYER_ID';
const FILTER_DATA = 'FILTER_DATA';
const UID = 'UID';
const IS_VERIFIED_DELIVERY_MAN = 'IS_VERIFIED_DELIVERY_MAN';
const RECENT_ADDRESS_LIST = 'RECENT_ADDRESS_LIST';
const REMEMBER_ME = 'REMEMBER_ME';

const COUNTRY_ID = 'COUNTRY_ID';
const COUNTRY_DATA = 'COUNTRY_DATA';

const CITY_ID = 'City';
const CITY_DATA = 'CITY_DATA';

const PAYMENT_ON_PICKUP = 'on_pickup';
const PAYMENT_ON_DELIVERY = 'on_delivery';

// Vehicle status
const VEHICLE_IMAGE = 'VEHICLE_IMAGE';

// Payment status
const PAYMENT_PENDING = 'pending';
const PAYMENT_FAILED = 'failed';
const PAYMENT_PAID = 'paid';

/* Theme Mode Type */
const ThemeModeLight = 0;
const ThemeModeDark = 1;
const THEME_MODE_INDEX = 'theme_mode_index';
const SELECTED_LANGUAGE_CODE = 'selected_language_code';

const default_Language = 'en';

//region LiveStream Keys
const streamLanguage = 'streamLanguage';
const streamDarkMode = 'streamDarkMode';
const streamVehicleMode = 'streamVehicleMode';

const FIXED_CHARGES = "fixed_charges";
const MIN_DISTANCE = "min_distance";
const MIN_WEIGHT = "min_weight";
const PER_DISTANCE_CHARGE = "per_distance_charges";
const PER_WEIGHT_CHARGE = "per_weight_charges";

const PENDING = 'Pending';
const APPROVEDText = 'Approved';
const REJECTED = 'Rejected';

// Admin Menu Index
const DASHBOARD_INDEX = 0;
const COUNTRY_INDEX = 1;
const CITY_INDEX = 2;
const VEHICLE_INDEX = 3;
const EXTRA_CHARGES_INDEX = 4;
const PARCEL_TYPE_INDEX = 5;
const PAYMENT_GATEWAY_INDEX = 6;
const CREATE_ORDER_INDEX = 7;
const ORDER_INDEX = 8;
const DOCUMENT_INDEX = 9;
const DELIVERY_PERSON_DOCUMENT_INDEX = 10;
const USER_INDEX = 11;
const Coorporate_INDEX = 12;
const DELIVERY_PERSON_INDEX = 13;
const APP_SETTING_INDEX = 14;
const DRIVER_INVOICES = 15;
const USER_INVOICES = 16;
const WITHDRAW_INDEX = 17;

// Currency Position
const CURRENCY_POSITION_LEFT = 'left';
const CURRENCY_POSITION_RIGHT = 'right';

const mAppIconUrl = "assets/app_logo.jpg";

const CREDIT = 'credit';

// Client Menu Index
const ORDER_LIST_INDEX = 0;
const DRAFT_LIST_INDEX = 1;
const WALLET_INDEX = 2;
const WITHDRAW_HISTORY_INDEX = 3;
const BANK_DETAIL_INDEX = 4;
const CHANGE_PASSWORD_INDEX = 5;
const DELETE_ACCOUNT_INDEX = 6;
const ABOUT_US_INDEX = 7;

const TRANSACTION_ORDER_FEE = "order_fee";
const TRANSACTION_TOPUP = "topup";
const TRANSACTION_ORDER_CANCEL_CHARGE = "order_cancel_charge";
const TRANSACTION_ORDER_CANCEL_REFUND = "order_cancel_refund";
const TRANSACTION_CORRECTION = "correction";
const TRANSACTION_COMMISSION = "commission";
const TRANSACTION_WITHDRAW = "withdraw";

const IS_ENTER_KEY = "IS_ENTER_KEY";
const SELECTED_WALLPAPER = "SELECTED_WALLPAPER";
const PER_PAGE_CHAT_COUNT = 50;

const TEXT = "TEXT";
const IMAGE = "IMAGE";

const VIDEO = "VIDEO";
const AUDIO = "AUDIO";

enum MessageType {
  TEXT,
  IMAGE,
  VIDEO,
  AUDIO,
}

List<String> rtlLanguage = ['ar', 'ur'];
const MONTHLY_ORDER_COUNT = 'monthly_order_count';
const MONTHLY_PAYMENT_CANCELLED_REPORT = 'monthly_payment_cancelled_report';
const MONTHLY_PAYMENT_COMPLETED_REPORT = 'monthly_payment_completed_report';
