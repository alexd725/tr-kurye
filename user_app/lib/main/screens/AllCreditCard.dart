import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:provider/provider.dart';

import '../../delivery/fragment/DProfileFragment.dart';
import '../../user/fragment/AccountFragment.dart';
import '../../other_widgets/fialogs/fialogs.dart';
import '../components/BodyCornerWidget.dart';
import '../models/CreditCardProvider.dart';
import '../utils/Constants.dart';
import 'CreditCard.dart';

class AllCreditCard extends StatefulWidget {
  const AllCreditCard({Key? key}) : super(key: key);

  @override
  State<AllCreditCard> createState() => _AllCreditCardState();
}

class _AllCreditCardState extends State<AllCreditCard> {
  bool isLoading = true;

  @override
  void initState() {
    Provider.of<CreditCardProvider>(context, listen: false)
        .getCreditCard(
      getIntAsync(USER_ID),
    )
        .then((value) {
      setState(() {
        isLoading = false;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final getProvider = Provider.of<CreditCardProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: Text("All Credit Card: ${getProvider.creditCard.length}"),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (ctx) =>
                          AddCreditCardScreen(id: ''.toInt(), cardNumber: "", expiryDate: "", ccvCode: "", cardHolderName: "", isEdit: false),
                    ),
                  ).then((value) {
                    Provider.of<CreditCardProvider>(context, listen: false)
                        .getCreditCard(
                      getIntAsync(USER_ID),
                    )
                        .then((value) {
                      setState(() {
                        isLoading = false;
                      });
                    });
                  });
                },
                child: Icon(Icons.add)),
          ),
        ],
      ),
      body: BodyCornerWidget(
        child: Observer(builder: (context) {
          return isLoading
              ? Center(child: CircularProgressIndicator())
              : ListView.builder(
                  itemCount: getProvider.creditCard.length,
                  itemBuilder: (ctx, i) {
                    return Slidable(
                      key: const ValueKey(0),

                      // The start action pane is the one at the left or the top side.
                      startActionPane: ActionPane(
                        // A motion is a widget used to control how the pane animates.
                        motion: const ScrollMotion(),

                        // A pane can dismiss the Slidable.
                        dismissible: DismissiblePane(onDismissed: () {
                          print("delete1");
                          alertDialog(
                            context,
                            'Alert',
                            'Are you sure you want to delete?',
                            hideNeutralButton: true,
                            positiveButtonText: 'Yes',
                            positiveButtonAction: () {
                              setState(() {
                                isLoading = true;
                              });
                              getProvider.deleteCreditCard(getProvider.creditCard[i].id).then((value) {
                                getProvider.getCreditCard(getIntAsync(USER_ID)).then((value) {
                                  setState(() {
                                    isLoading = false;
                                  });
                                });
                              });
                            },
                            negativeButtonText: 'No',
                            negativeButtonAction: () {
                              setState(() {
                                isLoading = true;
                              });
                              getProvider.getCreditCard(getIntAsync(USER_ID)).then((value) {
                                setState(() {
                                  isLoading = false;
                                });
                              });
                            },
                          );
                        }),

                        // All actions are defined in the children parameter.
                        children: [
                          // A SlidableAction can have an icon and/or a label.
                          SlidableAction(
                            onPressed: (v) {
                              print("delete2 $v");
                              alertDialog(
                                context,
                                'Alert',
                                'Are you sure you want to delete?',
                                hideNeutralButton: true,
                                positiveButtonText: 'Yes',
                                positiveButtonAction: () {
                                  setState(() {
                                    isLoading = true;
                                  });
                                  getProvider.deleteCreditCard(getProvider.creditCard[i].id).then((value) {
                                    getProvider.getCreditCard(getIntAsync(USER_ID)).then((value) {
                                      setState(() {
                                        isLoading = false;
                                      });
                                    });
                                  });
                                },
                                negativeButtonText: 'No',
                                negativeButtonAction: () {
                                  setState(() {
                                    isLoading = true;
                                  });
                                  getProvider.getCreditCard(getIntAsync(USER_ID)).then((value) {
                                    setState(() {
                                      isLoading = false;
                                    });
                                  });
                                },
                              );
                            },
                            backgroundColor: Color(0xFFFE4A49),
                            foregroundColor: Colors.white,
                            icon: Icons.delete,
                            label: 'Delete',
                          ),
                        ],
                      ),

                      // The end action pane is the one at the right or the bottom side.
                      endActionPane: ActionPane(
                        motion: ScrollMotion(),
                        children: [
                          SlidableAction(
                            onPressed: (v) {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => AddCreditCardScreen(
                                            cardNumber: getProvider.creditCard[i].number.toString(),
                                            expiryDate: getProvider.creditCard[i].expiringDate,
                                            ccvCode: getProvider.creditCard[i].ccv.toString(),
                                            cardHolderName: getProvider.creditCard[i].cardholder,
                                            isEdit: true,
                                            id: getProvider.creditCard[i].id,
                                          )));
                            },
                            backgroundColor: Color(0xFF0392CF),
                            foregroundColor: Colors.white,
                            icon: Icons.save,
                            label: 'Edit',
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          ListTile(
                            title: Text(getProvider.creditCard[i].cardholder.toUpperCase()),
                            // trailing: Column(
                            //   mainAxisAlignment: MainAxisAlignment.center,
                            //   children: [
                            //     myPopMenu(context),
                            //     Text(getProvider.creditCard[i].expiringDate),
                            //   ],
                            // ),
                            trailing: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(getProvider.creditCard[i].expiringDate),
                                SizedBox(height: 8.0),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    InkWell(
                                        onTap: () {
                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) => AddCreditCardScreen(
                                                        // cardNumber: getProvider.creditCard[i].number.toString(),
                                                        cardNumber: "",
                                                        expiryDate: getProvider.creditCard[i].expiringDate,
                                                        ccvCode: getProvider.creditCard[i].ccv.toString(),
                                                        cardHolderName: getProvider.creditCard[i].cardholder,
                                                        isEdit: true,
                                                        id: getProvider.creditCard[i].id,
                                                      )));
                                        },
                                        child: Icon(Icons.edit, color: Theme.of(context).primaryColor)),
                                    SizedBox(width: 12.0),
                                    InkWell(
                                        onTap: () {
                                          alertDialog(
                                            context,
                                            'Alert',
                                            'Are you sure you want to delete?',
                                            hideNeutralButton: true,
                                            positiveButtonText: 'Yes',
                                            positiveButtonAction: () {
                                              setState(() {
                                                isLoading = true;
                                              });
                                              getProvider.deleteCreditCard(getProvider.creditCard[i].id).then((value) {
                                                getProvider.getCreditCard(getIntAsync(USER_ID)).then((value) {
                                                  setState(() {
                                                    isLoading = false;
                                                  });
                                                });
                                              });
                                            },
                                            negativeButtonText: 'No',
                                            negativeButtonAction: () {
                                              // setState(() {
                                              //   isLoading = true;
                                              // });
                                              // getProvider.getCreditCard(getIntAsync(USER_ID)).then((value) {
                                              //   setState(() {
                                              //     isLoading = false;
                                              //   });
                                              // });
                                            },
                                          );
                                        },
                                        child: Icon(Icons.delete, color: Theme.of(context).errorColor)),
                                  ],
                                ),
                              ],
                            ),
                            leading: Text(getProvider.creditCard[i].id.toString()),
                            subtitle: Text("****************"),
                          ),
                          Divider(),
                        ],
                      ),
                    );
                  },
                );
        }),
      ),
    );
  }

  Widget OutlineActionIcon(IconData icon, Color color, String message, Function() onTap) {
    return GestureDetector(
      child: Tooltip(
        message: message,
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          child: Container(
            height: 25,
            width: 25,
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(2.0),
              border: Border.all(color: color),
            ),
            child: Icon(icon, color: color, size: 14),
          ),
        ),
      ),
      onTap: onTap,
    );
  }

  Widget myPopMenu(BuildContext context) {
    return PopupMenuButton(
      padding: EdgeInsets.zero,
      icon: Container(
          color: Colors.red,
          height: 20,
          width: 48,
          alignment: Alignment.topLeft,
          child: Icon(
            Icons.more_horiz,
          )),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(
          Radius.circular(15.0),
        ),
      ),
      color: Colors.white.withOpacity(0.9),
      onSelected: (value) async {
        if (value == 1) {}
      },
      itemBuilder: (context) => [
        PopupMenuItem(
          value: 1,
          child: Text('Mark All Read'),
        ),
      ],
    );
  }
}
