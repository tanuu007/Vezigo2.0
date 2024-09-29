import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vezigo/Api_Models/signup_model.dart';

class SignupProvider with ChangeNotifier {
  SignupRequest? _signupRequest;

  SignupRequest? get signupRequest => _signupRequest;

  Future<void> setSignupDetails(String name, String countryCode, String phoneNumber) async {
    _signupRequest = SignupRequest(
      name: name,
      countryCode: countryCode,
      phoneNumber: phoneNumber,
    );
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('name', name);
    await prefs.setString('phoneNumber', phoneNumber);
  }

  Future<void> loadSignupDetails() async {
    final prefs = await SharedPreferences.getInstance();
    String? name = prefs.getString('name');
    String? phoneNumber = prefs.getString('phoneNumber');

    if (name != null && phoneNumber != null) {
      _signupRequest = SignupRequest(
        name: name,
        countryCode: "+91",
        phoneNumber: phoneNumber,
      );
      notifyListeners();
    }
  }
}
