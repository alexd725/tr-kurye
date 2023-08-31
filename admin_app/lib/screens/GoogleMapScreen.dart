import 'dart:convert';
import '../utils/Constants.dart';

import '../../main.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_place_picker_mb/google_maps_place_picker.dart';

import '../models/PlaceAddressModel.dart';

class GoogleMapScreen extends StatefulWidget {
  static final kInitialPosition = LatLng(-33.8567844, 151.213108);
  final bool isPick;

  GoogleMapScreen({this.isPick = true});

  @override
  _GoogleMapScreenState createState() => _GoogleMapScreenState();
}

class _GoogleMapScreenState extends State<GoogleMapScreen> {
  PickResult? selectedPlace;
  bool showPlacePickerInContainer = false;
  bool showGoogleMapInContainer = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isPick ? language.selectPickupLocation : language.selectDeliveryLocation),
      ),
      body: PlacePicker(
        apiKey: googleMapAPIKey,
        hintText: language.searchAddress,
        searchingText: language.pleaseWait,
        selectText: widget.isPick ? language.confirmPickupLocation : language.confirmDeliveryLocation,
        outsideOfPickAreaText: language.addressNotInArea,
        initialPosition: GoogleMapScreen.kInitialPosition,
        useCurrentLocation: true,
        selectInitialPosition: true,
        usePinPointingSearch: true,
        usePlaceDetailSearch: true,
        zoomGesturesEnabled: true,
        zoomControlsEnabled: true,
        automaticallyImplyAppBarLeading: false,
        autocompleteLanguage: appStore.selectedLanguage,
        onMapCreated: (GoogleMapController controller) {
          //
        },
        onPlacePicked: (PickResult result) {
          setState(() {
            selectedPlace = result;
            PlaceAddressModel selectedModel = PlaceAddressModel(
              placeId: selectedPlace!.placeId!,
              latitude: selectedPlace!.geometry!.location.lat,
              longitude: selectedPlace!.geometry!.location.lng,
              placeAddress: selectedPlace!.formattedAddress,
            );
            List<PlaceAddressModel> list = (sharedPref.getStringList(RECENT_ADDRESS_LIST) ?? []).map((e) => PlaceAddressModel.fromJson(jsonDecode(e))).toList();
            bool isExist = list.any((element) => element.placeId == selectedPlace!.placeId);
            if (!isExist) {
              list.add(selectedModel);
              sharedPref.setStringList(RECENT_ADDRESS_LIST, list.map((element) => jsonEncode(element)).toList());
            }
            Navigator.pop(context,selectedModel);
          });
        },
        onMapTypeChanged: (MapType mapType) {
          //
        },
      ),
    );
  }
}
