import 'package:flutter/material.dart';
import 'package:flutter_credit_card/credit_card_widget.dart';
import 'package:flutter_credit_card/glassmorphism_config.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:provider/provider.dart';
import '../../delivery/fragment/DProfileFragment.dart';
import '../../other_widgets/fialogs/src/dialogs.dart';
import '../../user/fragment/AccountFragment.dart';
import '../../user/screens/DashboardScreen.dart';
import '../models/CreditCardProvider.dart';
import '../utils/Constants.dart';

import 'package:flutter/material.dart';
import 'package:flutter_credit_card/credit_card_brand.dart';
import 'package:flutter_credit_card/flutter_credit_card.dart';

class AddCreditCardScreen extends StatefulWidget {
  final int? isFromCreateOrder;
  int id;
  final String cardNumber;
  final String expiryDate;
  final String cardHolderName;
  final String ccvCode;
  bool isEdit;

  AddCreditCardScreen(
      {required this.cardNumber,
      required this.expiryDate,
      required this.ccvCode,
      required this.cardHolderName,
      required this.isEdit,
      required this.id, this.isFromCreateOrder});

  @override
  State<StatefulWidget> createState() {
    return AddCreditCardScreenState();
  }
}

class AddCreditCardScreenState extends State<AddCreditCardScreen> {
  static String tag = '/AddCreditCardScreen';
  bool isLoading = true;
  String cardNumber = '';
  String expiryDate = '';
  String cardHolderName = '';
  String cvvCode = '';
  bool isCvvFocused = false;
  bool useGlassMorphism = false;
  bool useBackgroundImage = false;
  OutlineInputBorder? border;
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  @override
  void initState() {
    border = OutlineInputBorder(
      borderSide: BorderSide(
        color: Colors.grey.withOpacity(0.7),
        width: 2.0,
      ),
    );
    if (widget.isEdit) {
      setState(() {
        cardNumber = widget.cardNumber;
        expiryDate = widget.expiryDate;
        cardHolderName = widget.cardHolderName;
        cvvCode = widget.ccvCode;
      });
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final getProvider = Provider.of<CreditCardProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text("Add Your Credit Card"),
        centerTitle: true,
      ),
      resizeToAvoidBottomInset: true,
      body: Container(
        decoration: BoxDecoration(
          color: Colors.white,
        ),
        child: Column(
          children: <Widget>[
            const SizedBox(
              height: 30,
            ),
            CreditCardWidget(
              glassmorphismConfig: useGlassMorphism ? Glassmorphism.defaultConfig() : null,
              cardNumber: cardNumber,
              expiryDate: expiryDate,
              cardHolderName: cardHolderName,
              cvvCode: cvvCode,
              bankName: '',
              showBackView: isCvvFocused,
              obscureCardNumber: true,
              obscureCardCvv: true,
              isHolderNameVisible: true,
              cardBgColor: Colors.black,
              isSwipeGestureEnabled: true,
              onCreditCardWidgetChange: (CreditCardBrand creditCardBrand) {},
              customCardTypeIcons: <CustomCardTypeIcon>[
                CustomCardTypeIcon(
                  cardType: CardType.mastercard,
                  cardImage: Image.network(
                    'https://www.pngmart.com/files/22/Mastercard-Logo-PNG-Pic.png',
                    height: 48,
                    width: 48,
                  ),
                ),
              ],
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: <Widget>[
                    CreditCardForm(
                      formKey: formKey,
                      obscureCvv: true,
                      obscureNumber: true,
                      cardNumber: cardNumber,
                      cvvCode: cvvCode,
                      isHolderNameVisible: true,
                      isCardNumberVisible: true,
                      isExpiryDateVisible: true,
                      cardHolderName: cardHolderName,
                      expiryDate: expiryDate,
                      themeColor: Colors.black,
                      textColor: Colors.black,
                      cardNumberDecoration: InputDecoration(
                        labelText: 'Number',
                        hintText: 'XXXX XXXX XXXX XXXX',
                        hintStyle: const TextStyle(color: Colors.black),
                        labelStyle: const TextStyle(color: Colors.black),
                        focusedBorder: border,
                        enabledBorder: border,
                      ),
                      expiryDateDecoration: InputDecoration(
                        hintStyle: const TextStyle(color: Colors.black),
                        labelStyle: const TextStyle(color: Colors.black),
                        focusedBorder: border,
                        enabledBorder: border,
                        labelText: 'Expired Date',
                        hintText: 'XX/XX',
                      ),
                      cvvCodeDecoration: InputDecoration(
                        hintStyle: const TextStyle(color: Colors.black),
                        labelStyle: const TextStyle(color: Colors.black),
                        focusedBorder: border,
                        enabledBorder: border,
                        labelText: 'CVV',
                        hintText: 'XXX',
                      ),
                      cardHolderDecoration: InputDecoration(
                        hintStyle: const TextStyle(color: Colors.black),
                        labelStyle: const TextStyle(color: Colors.black),
                        focusedBorder: border,
                        enabledBorder: border,
                        labelText: 'Card Holder',
                      ),
                      onCreditCardModelChange: onCreditCardModelChange,
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        backgroundColor: Colors.purple,
                      ),
                      child: Container(
                        margin: const EdgeInsets.all(12),
                        child: Text(
                          widget.isEdit ? "Update" : "Validate",
                          style: TextStyle(
                            color: Colors.white,
                            fontFamily: 'halter',
                            fontSize: 14,
                            package: 'flutter_credit_card',
                          ),
                        ),
                      ),
                      onPressed: () {
                        if (formKey.currentState!.validate()) {
                          if (widget.isEdit == false) {
                            getProvider
                                .addCreditCard(
                              cardHolderName,
                              expiryDate,
                              cvvCode.toInt(),
                              cardNumber.replaceAll(' ', '').toInt(),
                            )
                            //     .then((value) {
                            //   // var snackBar = SnackBar(
                            //   //     content: Text('Credit Card Saved',
                            //   //         style: TextStyle(
                            //   //           color: appStore.isDarkMode
                            //   //               ? Colors.black
                            //   //               : Colors.white,
                            //   //         )));
                            //   // ScaffoldMessenger.of(context)
                            //   //     .showSnackBar(snackBar);
                            //   successDialog(context, "Success", "Credit Card Saved Successfully", neutralButtonText: "OK");
                            // })
                            .then((value) {
                              successDialog(context, "Success", "Credit Card Saved Successfully", neutralButtonText: "OK", neutralButtonAction: (){
                                // Navigator.of(context).popUntil((route) => route.isFirst);
                                pop();
                              },closeOnBackPress: false);

                            });
                          } else {
                            getProvider
                                .updateCreditCard(cardHolderName, expiryDate, cvvCode.toInt(), cardNumber.replaceAll(' ', '').toInt(), widget.id)
                            //     .then((value) {
                            //   var snackBar = SnackBar(
                            //       content: Text('Credit Card Saved',
                            //           style: TextStyle(
                            //             color: appStore.isDarkMode ? Colors.black : Colors.white,
                            //           )));
                            //   ScaffoldMessenger.of(context).showSnackBar(snackBar);
                            // })
                                .then((value) {
                              successDialog(context, "Success", "Credit Card Saved Successfully", neutralButtonText: "OK", neutralButtonAction: (){
                                if(widget.isFromCreateOrder != null){
                                  pop();
                                }else{
                                  // Navigator.of(context).popUntil((route) => route.isFirst);
                                  pop();
                                }
                              },closeOnBackPress: false);

                            });
                          }
                        } else {
                          print('invalid!');
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void onCreditCardModelChange(CreditCardModel? creditCardModel) {
    setState(() {
      cardNumber = creditCardModel!.cardNumber;
      expiryDate = creditCardModel.expiryDate;
      cardHolderName = creditCardModel.cardHolderName;
      cvvCode = creditCardModel.cvvCode;
      isCvvFocused = creditCardModel.isCvvFocused;
    });
  }
}
