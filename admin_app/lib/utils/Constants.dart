var errorThisFieldRequired = 'This field is required';
const currencySymbolDefault = '₹';
const currencyCodeDefault = 'INR';

const mBaseUrl = "http://set.nastorex.com/api/";
// const mBaseUrl = "http://10.10.18.72:8000/api/";

const googleMapAPIKey = 'AIzaSyDQDmiPg45vvSyOfOO2euQSiqOeNGjiFXo';

const mOneSignalAppIdAdmin = 'ADD_One_Signal_AppId_Admin';

String defaultPhoneCode = "+91";

const minContactLength = 10;
const maxContactLength = 14;
const digitAfterDecimal = 2;

const USER_COLLECTION = "users";

const CLIENT = 'client';
const DELIVERYMAN = 'delivery_man';
const Coorporate = 'corporate';

const passwordLengthGlobal = 6;
const defaultRadius = 8.0;
const defaultSmallRadius = 6.0;

const textPrimarySizeGlobal = 16.00;
const textBoldSizeGlobal = 16.00;
const textSecondarySizeGlobal = 14.00;
const borderRadius = 16.00;

double tabletBreakpointGlobal = 600.0;
double desktopBreakpointGlobal = 720.0;
double statisticsItemWidth = 230.0;

const RESTORE = 'restore';
const FORCE_DELETE = 'forcedelete';

const CHARGE_TYPE_FIXED = 'fixed';
const CHARGE_TYPE_PERCENTAGE = 'percentage';

const DISTANCE_UNIT_KM = 'km';
const DISTANCE_UNIT_MILE = 'mile';

const PAYMENT_GATEWAY_STRIPE = 'stripe';
const PAYMENT_GATEWAY_RAZORPAY = 'razorpay';
const PAYMENT_GATEWAY_PAYSTACK = 'paystack';
const PAYMENT_GATEWAY_FLUTTERWAVE = 'flutterwave';
const PAYMENT_GATEWAY_PAYPAL = 'paypal';
const PAYMENT_GATEWAY_PAYTABS = 'paytabs';
const PAYMENT_GATEWAY_MERCADOPAGO = 'mercadopago';
const PAYMENT_GATEWAY_PAYTM = 'paytm';
const PAYMENT_GATEWAY_MYFATOORAH = 'myfatoorah';
const PAYMENT_TYPE_CASH = 'cash';
const PAYMENT_GATEWAY_GPAY = 'gpay';
const PAYMENT_GATEWAY_IYZICO = 'iyzico';
const PAYMENT_TYPE_WALLET = 'wallet';

const DECLINE = 'decline';
const REQUESTED = 'requested';
const APPROVED = 'approved';

const ORDER_DRAFT = 'draft';
const ORDER_DEPARTED = 'courier_departed';
const ORDER_ACCEPTED = 'active';
const ORDER_CANCELLED = 'cancelled';
const ORDER_DELAYED = 'delayed';
const ORDER_ASSIGNED = 'courier_assigned';
const ORDER_ARRIVED = 'courier_arrived';
const ORDER_PICKED_UP = 'courier_picked_up';
const ORDER_DELIVERED = 'completed';
const ORDER_CREATED = 'create';
const ORDER_TRANSFER = 'courier_transfer';
const ORDER_PAYMENT = 'payment_status_message';
const ORDER_FAIL = 'failed';

const TRANSACTION_ORDER_FEE = "order_fee";
const TRANSACTION_TOPUP = "topup";
const TRANSACTION_ORDER_CANCEL_CHARGE = "order_cancel_charge";
const TRANSACTION_ORDER_CANCEL_REFUND = "order_cancel_refund";
const TRANSACTION_CORRECTION = "correction";
const TRANSACTION_COMMISSION = "commission";
const TRANSACTION_WITHDRAW = "withdraw";

const DIALOG_TYPE_DELETE = 'Delete';
const DIALOG_TYPE_RESTORE = 'Restore';
const DIALOG_TYPE_ENABLE = 'Enable';
const DIALOG_TYPE_DISABLE = 'Disable';
const DIALOG_TYPE_ASSIGN = 'Assign';
const DIALOG_TYPE_TRANSFER = 'Transfer';

const CREDIT = 'credit';

const TOKEN = 'TOKEN';
const IS_LOGGED_IN = 'IS_LOGGED_IN';
const USER_ID = 'USER_ID';
const USER_TYPE = 'USER_TYPE';
const USER_EMAIL = 'USER_EMAIL';
const USER_PASSWORD = 'USER_PASSWORD';
const NAME = 'NAME';
const USER_PROFILE_PHOTO = 'USER_PROFILE_PHOTO';
const USER_CONTACT_NUMBER = 'USER_CONTACT_NUMBER';
const USER_NAME = 'USER_NAME';
const USER_ADDRESS = 'USER_ADDRESS';
const REMEMBER_ME = 'REMEMBER_ME';
const FILTER_DATA = 'FILTER_DATA';
const RECENT_ADDRESS_LIST = 'RECENT_ADDRESS_LIST';

const PAYMENT_ON_PICKUP = 'on_pickup';
const PAYMENT_ON_DELIVERY = 'on_delivery';
const PAYMENT_ON_ANOTHER_DELIVERY2 = "on_another_delivery2";
const PAYMENT_ON_ANOTHER_DELIVERY3 = "on_another_delivery3";
const PAYMENT_ON_ANOTHER_DELIVERY4 = "on_another_delivery4";
const PAYMENT_ON_ANOTHER_DELIVERY5 = "on_another_delivery5";

const DEMO_ADMIN = 'demo_admin';
const ADMIN = 'admin';
const FCM_TOKEN = 'FCM_TOKEN';
const PLAYER_ID = 'PLAYER_ID';

// Payment status
const PAYMENT_PENDING = 'pending';
const PAYMENT_FAILED = 'failed';
const PAYMENT_PAID = 'paid';

const THEME_MODE_INDEX = 'theme_mode_index';
const SELECTED_LANGUAGE_CODE = 'selected_language_code';

const default_Language = 'en';

//region LiveStream Keys
const streamLanguage = 'streamLanguage';
const streamDarkMode = 'streamDarkMode';

const FIXED_CHARGES = "fixed_charges";
const MIN_DISTANCE = "min_distance";
const MIN_WEIGHT = "min_weight";
const PER_DISTANCE_CHARGE = "per_distance_charges";
const PER_WEIGHT_CHARGE = "per_weight_charges";

// Menu Index
const DASHBOARD_INDEX = 0;
const ORDER_INDEX = 1;
const USER_INDEX = 2;
const DELIVERY_PERSON_INDEX = 3;
const APP_SETTING_INDEX = 4;

class AppThemeMode {
  final int themeModeLight = 1;
  final int themeModeDark = 2;
  final int themeModeSystem = 0;
}

// Currency Position
const CURRENCY_POSITION_LEFT = 'left';
const CURRENCY_POSITION_RIGHT = 'right';

const MONTHLY_ORDER_COUNT = 'monthly_order_count';
const MONTHLY_PAYMENT_CANCELLED_REPORT = 'monthly_payment_cancelled_report';
const MONTHLY_PAYMENT_COMPLETED_REPORT = 'monthly_payment_completed_report';
