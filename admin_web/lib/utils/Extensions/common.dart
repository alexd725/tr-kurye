import 'dart:math';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:html/parser.dart';
import '../../utils/Extensions/string_extensions.dart';
import '../../utils/Extensions/text_styles.dart';
import '../../utils/Colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import '../../main.dart';
import 'colors.dart';
import 'constants.dart';
import 'decorations.dart';

T? makeNullable<T>(T? value) => value;

enum PageRouteAnimation { Fade, Scale, Rotate, Slide, SlideBottomTop }

bool hasMatch(String? s, String p) {
  return (s == null) ? false : RegExp(p).hasMatch(s);
}

const bool kReleaseMode = bool.fromEnvironment('dart.vm.product');

/// Prints only if in debug or profile mode
void log(Object? value) {
  if (!kReleaseMode) print(value);
}

/// Hide soft keyboard
void hideKeyboard(context) => FocusScope.of(context).requestFocus(FocusNode());


class SBehavior extends ScrollBehavior {
  @override
  Widget buildViewportChrome(BuildContext context, Widget child, AxisDirection axisDirection) {
    return child;
  }
}

const double degrees2Radians = pi / 180.0;
void afterBuildCreated(Function()? onCreated) {
  makeNullable(SchedulerBinding.instance)!.addPostFrameCallback((_) => onCreated?.call());
}

Route<T> buildPageRoute<T>(Widget child, PageRouteAnimation? pageRouteAnimation, Duration? duration) {
  if (pageRouteAnimation != null) {
    if (pageRouteAnimation == PageRouteAnimation.Fade) {
      return PageRouteBuilder(
        pageBuilder: (c, a1, a2) => child,
        transitionsBuilder: (c, anim, a2, child) => FadeTransition(opacity: anim, child: child),
        transitionDuration: duration ?? pageRouteTransitionDurationGlobal,
      );
    } else if (pageRouteAnimation == PageRouteAnimation.Rotate) {
      return PageRouteBuilder(
        pageBuilder: (c, a1, a2) => child,
        transitionsBuilder: (c, anim, a2, child) => RotationTransition(turns: ReverseAnimation(anim), child: child),
        transitionDuration: duration ?? pageRouteTransitionDurationGlobal,
      );
    } else if (pageRouteAnimation == PageRouteAnimation.Scale) {
      return PageRouteBuilder(
        pageBuilder: (c, a1, a2) => child,
        transitionsBuilder: (c, anim, a2, child) => ScaleTransition(scale: anim, child: child),
        transitionDuration: duration ?? pageRouteTransitionDurationGlobal,
      );
    } else if (pageRouteAnimation == PageRouteAnimation.Slide) {
      return PageRouteBuilder(
        pageBuilder: (c, a1, a2) => child,
        transitionsBuilder: (c, anim, a2, child) => SlideTransition(
          position: Tween(begin: const Offset(1.0, 0.0), end: const Offset(0.0, 0.0)).animate(anim),
          child: child,
        ),
        transitionDuration: duration ?? pageRouteTransitionDurationGlobal,
      );
    } else if (pageRouteAnimation == PageRouteAnimation.SlideBottomTop) {
      return PageRouteBuilder(
        pageBuilder: (c, a1, a2) => child,
        transitionsBuilder: (c, anim, a2, child) => SlideTransition(
          position: Tween(begin: const Offset(0.0, 1.0), end: const Offset(0.0, 0.0)).animate(anim),
          child: child,
        ),
        transitionDuration: duration ?? pageRouteTransitionDurationGlobal,
      );
    }
  }
  return MaterialPageRoute<T>(builder: (_) => child);
}


Widget appButton(BuildContext context, {String? title, Function? onCall, Color? color, Color? textColor}) {
  return InkWell(
    onTap: () {
      onCall!();
    },
    child: Container(
      alignment: Alignment.center,
      padding: EdgeInsets.symmetric(vertical: 12,horizontal: 16),
      decoration: BoxDecoration(borderRadius: radius(defaultRadius), color: color ?? primaryColor),
      child: Text(title!, style: boldTextStyle(color: textColor ?? Colors.white)),
    ),
  );
}

/// Returns true is snapshot is loading
bool isSnapshotLoading(AsyncSnapshot snap, {bool checkHasData = false}) {
  return snap.connectionState == ConnectionState.active || snap.connectionState == ConnectionState.waiting;
}

void finish(BuildContext context, [Object? result]) {
  if (Navigator.canPop(context)) Navigator.pop(context, result);
}

Widget mStatus(String? value, Color? color) {
  return Container(
    decoration: boxDecorationWithRoundedCorners(backgroundColor: color!),
    padding: EdgeInsets.symmetric(horizontal: 6, vertical: 4),
    child: Text(value!, style: primaryTextStyle(color: whiteColor)),
  );
}

String parseHtmlString(String? htmlString) {
  return parse(parse(htmlString).body!.text).documentElement!.text;
}

toast(String? value, {ToastGravity? gravity, length = Toast.LENGTH_SHORT, Color? bgColor, Color? textColor}) {
  Fluttertoast.showToast(
    msg: value!.validate(),
    toastLength: length,
    gravity: ToastGravity.BOTTOM,
    timeInSecForIosWeb: 1,
    backgroundColor: bgColor,
    textColor: textColor,
    fontSize: 16.0,
  );
}
