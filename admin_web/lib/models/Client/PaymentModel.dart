
import '../../utils/Constants.dart';

class PaymentModel{
  int? index;
  String? title;
  String? image;
  bool? isSelected=false;
  PaymentModel({this.index,this.image, this.title});

}

List<PaymentModel> getPaymentItems() {
  List<PaymentModel> list = [];
  list.add(PaymentModel(index: 1,image: 'assets/ic_cash.png', title: PAYMENT_TYPE_CASH));
  //list.add(PaymentModel(index: 2,image: 'assets/ic_credit_card.png', title: 'Online'));
  list.add(PaymentModel(index: 2,image: 'assets/ic_credit_card.png', title: PAYMENT_TYPE_WALLET));
  return list;
}
