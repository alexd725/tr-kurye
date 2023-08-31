import 'package:flutter/material.dart';
import '../../models/CityListModel.dart';
import '../../models/CountryListModel.dart';
import '../../utils/Extensions/context_extensions.dart';
import '../../utils/Extensions/int_extensions.dart';
import '../../main.dart';
import '../../network/ClientRestApi.dart';
import '../../network/RestApis.dart';
import '../../utils/Colors.dart';
import '../../utils/Common.dart';
import '../../utils/Constants.dart';
import '../../utils/Extensions/live_stream.dart';
import '../../utils/ResponsiveWidget.dart';
import '../../utils/Extensions/common.dart';
import '../../utils/Extensions/constants.dart';
import '../../utils/Extensions/decorations.dart';
import '../../utils/Extensions/shared_pref.dart';
import '../../utils/Extensions/text_styles.dart';

class UserCitySelectScreen extends StatefulWidget {
  static String tag = '/citySelection';
  final bool isBack;
  final Function()? onUpdate;

  UserCitySelectScreen({this.isBack = false, this.onUpdate});

  @override
  UserCitySelectScreenState createState() => UserCitySelectScreenState();
}

class UserCitySelectScreenState extends State<UserCitySelectScreen> {
  TextEditingController searchCityController = TextEditingController();

  int? selectedCountry;
  int? selectedCity;

  List<CountryData> countryData = [];
  List<CityData> cityData = [];

  @override
  void initState() {
    super.initState();
    afterBuildCreated(() {
      appStore.setLoading(true);
      init();
    });
  }

  Future<void> init() async {
    getCountryApiCall();
  }

  getCountryApiCall() async {
    await getCountryList().then((value) {
      appStore.setLoading(false);
      countryData = value.data!;
      selectedCountry = countryData[0].id!;
      countryData.forEach((element) {
        if (element.id! == getIntAsync(COUNTRY_ID)) {
          selectedCountry = getIntAsync(COUNTRY_ID);
        }
      });
      setValue(COUNTRY_ID, selectedCountry);
      getCountryDetailApiCall();
      getCityApiCall();
      setState(() {});
    }).catchError((error) {
      appStore.setLoading(false);
      log(error);
    });
  }

  getCityApiCall({String? name}) async {
    appStore.setLoading(true);
    await getClientCityList(countryId: selectedCountry!, name: name).then((value) {
      appStore.setLoading(false);
      cityData.clear();
      cityData.addAll(value.data!);
      cityData.forEach((element) {
        if (element.id! == getIntAsync(CITY_ID)) {
          selectedCity = getIntAsync(CITY_ID);
        }
      });
      setState(() {});
    }).catchError((error) {
      appStore.setLoading(false);
      log(error);
    });
  }

  getCountryDetailApiCall() async {
    await getCountryDetail(selectedCountry!).then((value) {
      setValue(COUNTRY_DATA, value.toJson());
    }).catchError((error) {});
  }

  Future<void> updateCountryCityApiCall() async {
    appStore.setLoading(true);
    await updateCountryCity(countryId: selectedCountry, cityId: selectedCity).then((value) {
      appStore.setLoading(false);
      if (widget.isBack) {
        finish(context);
        LiveStream().emit('UpdateOrderData');
        widget.onUpdate!.call();
      } else {
        finish(context);
        widget.onUpdate!.call();
      }
    }).catchError((error) {
      appStore.setLoading(false);
      log(error);
    });
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      elevation: 0,
      contentPadding: EdgeInsets.all(0),
      shape: RoundedRectangleBorder(borderRadius: radius(16)),
      backgroundColor: Colors.white,
      content: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.all(16),
          width: ResponsiveWidget.isSmallScreen(context) ? context.width() * 0.8 : context.width() * 0.4,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(language.selectCity, style: boldTextStyle()),
                  IconButton(
                    onPressed: () {
                      finish(context);
                    },
                    icon: Icon(Icons.close),
                  ),
                ],
              ),
              //   Lottie.asset('assets/delivery.json', height: 200, fit: BoxFit.contain, width: context.width()),
              16.height,
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(flex: 1, child: Text(language.country, style: boldTextStyle())),
                      16.width,
                      Expanded(
                        flex: 2,
                        child: DropdownButtonFormField<int>(
                          value: selectedCountry,
                          decoration: commonInputDecoration(),
                          items: countryData.map<DropdownMenuItem<int>>((item) {
                            return DropdownMenuItem(
                              value: item.id,
                              child: Text(item.name ?? ''),
                            );
                          }).toList(),
                          onChanged: (value) {
                            selectedCountry = value!;
                            setValue(COUNTRY_ID, selectedCountry);
                            getCountryDetailApiCall();
                            selectedCity = null;
                            getCityApiCall();
                            setState(() {});
                          },
                          validator: (value) {
                            if (selectedCountry == null) return errorThisFieldRequired;
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                  16.height,
                  Row(children: [
                    Expanded(child: Text(language.city, style: boldTextStyle())),
                    16.width,
                    Expanded(
                      child: TextField(
                        controller: searchCityController,
                        keyboardType: TextInputType.name,
                        textInputAction: TextInputAction.next,
                        decoration: commonInputDecoration(hintText: language.selectCity, suffixIcon: Icons.search),
                        onChanged: (value) {
                          getCityApiCall(name: value);
                        },
                      ),
                    ),
                  ]),
                  16.height,
                  appStore.isLoading && cityData.isEmpty
                      ? SizedBox()
                      : ListView.builder(
                          itemCount: cityData.length,
                          physics: NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemBuilder: (context, index) {
                            CityData mData = cityData[index];
                            return ListTile(
                              contentPadding: EdgeInsets.zero,
                              title: Text(mData.name!, style: selectedCity == mData.id ? boldTextStyle(color: primaryColor) : primaryTextStyle()),
                              trailing: selectedCity == mData.id ? Icon(Icons.check_circle, color: primaryColor) : SizedBox(),
                              onTap: () {
                                selectedCity = mData.id!;
                                setValue(CITY_ID, selectedCity);
                                setValue(CITY_DATA, mData.toJson());
                                updateCountryCityApiCall();
                                LiveStream().emit(streamVehicleMode);
                              },
                            );
                          },
                        )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
