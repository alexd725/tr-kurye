const mAppName = 'Mighty Delivery';
const mPrivacyPolicy = 'ADD_YOUR_PRIVACY_POCLICY_URL';
const mTermAndCondition = 'ADD_YOUR_TERM_AND_CONDITION_URL';
const mHelpAndSupport = 'ADD_YOUR_HELP_AND_SUPPORT_URL';
const mContactPref = 'ADD_YOUR_CONTACT_PREFERENCE';
const mCodeCanyonURL = 'ADD_YOUR_PURCHASE_URL';

const mBaseUrl = "http://set.nastorex.com/api/";
// const mBaseUrl = "http://10.10.18.72:8000/api/";

const mTestMode = false;

const googleMapAPIKey = 'AIzaSyDQDmiPg45vvSyOfOO2euQSiqOeNGjiFXo';
const mOneSignalAppId = 'ADD_YOUR_ONE_SIGNAL_APP_ID';
const mOneSignalRestKey = 'ADD_YOUR_ONE_SIGNAL_REST_KEY';
const mOneSignalChannelId = 'ADD_YOUR_ONE_SIGNAL_CHANNEL_ID';

const BANK_LIST = [
  'HDFC',
  'Bank of baroda',
  'State bank of india',
  'Bank of India',
  'Indian Bank',
];

const defaultLanguage = "en";
const defaultPhoneCode = '+91';

const minContactLength = 10;
const maxContactLength = 14;
const digitAfterDecimal = 2;

const UserTerms = "";

// font size
const headingSize = 24;
const currencySymbol = '₹';
const currencyCode = 'INR';

// SharedReference keys
const IS_LOGGED_IN = 'IS_LOGIN';
const IS_FIRST_TIME = 'IS_FIRST_TIME';

const USER_ID = 'USER_ID';
const NAME = 'NAME';
const USER_EMAIL = 'USER_EMAIL';
const TAX_OFFICE = 'TAX_OFFICE';
const TAX_NUMBER = 'TAX_NUMBER';

const USER_TOKEN = 'USER_TOKEN';
const USER_CONTACT_NUMBER = 'USER_CONTACT_NUMBER';
const USER_PROFILE_PHOTO = 'USER_PROFILE_PHOTO';
const USER_TYPE = 'USER_TYPE';
const USER_NAME = 'USER_NAME';
const USER_PASSWORD = 'USER_PASSWORD';
const USER_ADDRESS = 'USER_ADDRESS';
const STATUS = 'STATUS';
const PLAYER_ID = 'PLAYER_ID';
const FILTER_DATA = 'FILTER_DATA';
const UID = 'UID';

const IS_VERIFIED_DELIVERY_MAN = 'IS_VERIFIED_DELIVERY_MAN';
const RECENT_ADDRESS_LIST = 'RECENT_ADDRESS_LIST';

const COUNTRY_ID = 'COUNTRY_ID';
const COUNTRY_DATA = 'COUNTRY_DATA';

const CITY_ID = 'City';
const CITY_NAME = 'CITY_NAME';
const CITY_DATA = 'CITY_DATA';

const CLIENT = 'client';
const CORPORATE = 'corporate';

const DELIVERY_MAN = 'delivery_man';

const CHARGE_TYPE_FIXED = 'fixed';
const CHARGE_TYPE_PERCENTAGE = 'percentage';

const PAYMENT_TYPE_STRIPE = 'stripe';
const PAYMENT_TYPE_RAZORPAY = 'razorpay';
const PAYMENT_TYPE_PAYSTACK = 'paystack';
const PAYMENT_TYPE_FLUTTERWAVE = 'flutterwave';
const PAYMENT_TYPE_PAYPAL = 'paypal';
const PAYMENT_TYPE_PAYTABS = 'paytabs';
const PAYMENT_TYPE_MERCADOPAGO = 'mercadopago';
const PAYMENT_TYPE_PAYTM = 'paytm';
const PAYMENT_TYPE_MYFATOORAH = 'myfatoorah';
const PAYMENT_TYPE_GOOGLEPAY = 'gpay';
const PAYMENT_GATEWAY_IYZICO = 'iyzico';
const PAYMENT_TYPE_CASH = 'cash';
const PAYMENT_TYPE_WALLET = 'wallet';

const PAYMENT_PENDING = 'pending';
const PAYMENT_FAILED = 'failed';
const PAYMENT_PAID = 'paid';

const PAYMENT_ON_DELIVERY = "on_delivery";
const PAYMENT_ON_ANOTHER_DELIVERY2 = "on_another_delivery2";
const PAYMENT_ON_ANOTHER_DELIVERY3 = "on_another_delivery3";
const PAYMENT_ON_ANOTHER_DELIVERY4 = "on_another_delivery4";
const PAYMENT_ON_ANOTHER_DELIVERY5 = "on_another_delivery5";
const PAYMENT_ON_PICKUP = "on_pickup";

const RESTORE = 'restore';
const FORCE_DELETE = 'forcedelete';
const DELETE_USER = 'deleted_at';

const DECLINE = 'decline';
const REQUESTED = 'requested';
const APPROVED = 'approved';

// OrderStatus
const ORDER_CREATED = 'create';
const ORDER_ACCEPTED = 'active';
/*const COURIER_ASSIGNED = 'courier_assigned';
const COURIER_DEPARTED = 'courier_departed';
const COURIER_TRANSFER = 'courier_transfer';
const ORDER_CREATE = 'create';
const ORDER_ACTIVE = 'active';*/
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

const TRANSACTION_ORDER_FEE = "order_fee";
const TRANSACTION_TOPUP = "topup";
const TRANSACTION_ORDER_CANCEL_CHARGE = "order_cancel_charge";
const TRANSACTION_ORDER_CANCEL_REFUND = "order_cancel_refund";
const TRANSACTION_CORRECTION = "correction";
const TRANSACTION_COMMISSION = "commission";
const TRANSACTION_WITHDRAW = "withdraw";

const stripeURL = 'https://api.stripe.com/v1/payment_intents';

class AppThemeMode {
  final int themeModeLight = 1;
  final int themeModeDark = 2;
  final int themeModeSystem = 0;
}

AppThemeMode appThemeMode = AppThemeMode();

const REMEMBER_ME = 'REMEMBER_ME';

const mAppIconUrl = "assets/app_logo.jpg";

///FireBase Collection Name
const MESSAGES_COLLECTION = "messages";
const USER_COLLECTION = "users";
const CONTACT_COLLECTION = "contact";
const CHAT_DATA_IMAGES = "chatImages";

const IS_ENTER_KEY = "IS_ENTER_KEY";
const SELECTED_WALLPAPER = "SELECTED_WALLPAPER";
const PER_PAGE_CHAT_COUNT = 50;

const TEXT = "TEXT";
const IMAGE = "IMAGE";

const VIDEO = "VIDEO";
const AUDIO = "AUDIO";

const FIXED_CHARGES = "fixed_charges";
const MIN_DISTANCE = "min_distance";
const MIN_WEIGHT = "min_weight";
const PER_DISTANCE_CHARGE = "per_distance_charges";
const PER_WEIGHT_CHARGE = "per_weight_charges";

// Currency Position
const CURRENCY_POSITION_LEFT = 'left';
const CURRENCY_POSITION_RIGHT = 'right';

const CREDIT = 'credit';

//chat
List<String> rtlLanguage = ['ar', 'ur'];

enum MessageType {
  TEXT,
  IMAGE,
  VIDEO,
  AUDIO,
}

extension MessageExtension on MessageType {
  String? get name {
    switch (this) {
      case MessageType.TEXT:
        return 'TEXT';
      case MessageType.IMAGE:
        return 'IMAGE';
      case MessageType.VIDEO:
        return 'VIDEO';
      case MessageType.AUDIO:
        return 'AUDIO';
      default:
        return null;
    }
  }
}
