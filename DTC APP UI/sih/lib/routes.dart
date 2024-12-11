import 'package:flutter/material.dart';
import 'package:sih/pages/Driver_homepage.dart';
import 'package:sih/pages/driver_notifications_page.dart';
import 'package:sih/pages/editprofile.dart';
import 'package:sih/pages/loginpage.dart';
import 'package:sih/pages/profile.dart';
import 'package:sih/pages/user_report.dart';
import 'package:sih/pages/splash_screen.dart';
import 'package:sih/Signup/DriverSignUp.dart';
import 'package:sih/Signup/MainSignUp.dart';
import 'package:sih/Signup/UserSignUp.dart';
import 'package:sih/pages/user_homepage.dart';
import 'package:sih/pages/coupons.dart';
class AppRoutes {
  static final Map<String, WidgetBuilder> routes = {
    '/': (context) => SplashScreen(),
    '/login': (context) => LoginPage(),
    '/signup': (context) => SignupPage(),
    '/profile': (context) => ProfileScreen(),
    '/edit': (context) => EditProfileScreen(),
    '/driver_signup': (context) => DriverSignupPage(),
    '/user_signup': (context) => UserSignupPage(),
    '/user_home':(context)=>UserHomeScreen(),
    '/driver_notifications': (context) => DriverNotificationScreen(),
    '/coupons': (context) => RewardsPage(),
    '/reportpage': (context) => UserReportFormScreen(),
  };
}
