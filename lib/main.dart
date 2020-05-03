import 'package:firebase_admob/firebase_admob.dart';
import 'package:flutter/material.dart';
import 'package:godotclassreference/constants/stored_values.dart';

import 'screens/class_select.dart';

import 'constants/colors.dart';

const appId = 'ca-app-pub-3569371273195353~4389051701';
const appUnitId = 'ca-app-pub-3569371273195353/9278184798';

MobileAdTargetingInfo targetingInfo = MobileAdTargetingInfo(
  keywords: <String>['godot', 'game develop', 'document'],
//  contentUrl: 'https://flutter.io',
//  birthday: DateTime.now(),
  childDirected: false,
//  designedForFamilies: false,
//  gender:
//      MobileAdGender.male, // or MobileAdGender.female, MobileAdGender.unknown
  testDevices: <String>[], // Android emulators are considered test devices
);

BannerAd myBanner = BannerAd(
  // Replace the testAdUnitId with an ad unit id from the AdMob dash.
  // https://developers.google.com/admob/android/test-ads
  // https://developers.google.com/admob/ios/test-ads
  adUnitId: appUnitId,
  size: AdSize.smartBanner,
  targetingInfo: targetingInfo,
  listener: (MobileAdEvent event) {
    print("BannerAd event is $event");
  },
);

//InterstitialAd myInterstitial = InterstitialAd(
//  // Replace the testAdUnitId with an ad unit id from the AdMob dash.
//  // https://developers.google.com/admob/android/test-ads
//  // https://developers.google.com/admob/ios/test-ads
//  adUnitId: InterstitialAd.testAdUnitId,
//  targetingInfo: targetingInfo,
//  listener: (MobileAdEvent event) {
//    print("InterstitialAd event is $event");
//  },
//);

void main() => runApp(GCRApp());

class GCRApp extends StatefulWidget {
  @override
  _GCRAppState createState() => _GCRAppState();
}

class _GCRAppState extends State<GCRApp> {
  @override
  void initState() {
    FirebaseAdMob.instance.initialize(appId: appId);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    StoredValues().readValue();
    myBanner
      // typically this happens well before the ad is shown
      ..load()
      ..show(
        // Positions the banner ad 60 pixels from the bottom of the screen
        anchorOffset: 0.0,
        // Positions the banner ad 10 pixels from the center of the screen to the right
        horizontalCenterOffset: 0.0,
        // Banner Position
        anchorType: AnchorType.bottom,
      );

    return MaterialApp(
//      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: godotColor,
      ),
      home: ClassSelect(),
//      builder: (BuildContext context, Widget child) {
//        return Padding(
//          child: child,
//          padding: EdgeInsets.only(bottom: 50),
////          padding: EdgeInsets.all(0),
//        );
//      },
    );
  }
}
