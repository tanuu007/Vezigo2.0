import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vezigo/Auth/otp.dart';
import 'package:vezigo/models/colors.dart';
import 'package:vezigo/Auth/signup.dart';
import 'package:http/http.dart' as http;
import 'package:vezigo/Api_Models/login_model.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final FocusNode _mobileNumberFocusNode = FocusNode();
  OverlayEntry? _overlayEntry;
     final TextEditingController _phoneNumberController = TextEditingController();

       Future<void> _saveUserData(String name, String phoneNumber) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString('name', name);
  await prefs.setString('phoneNumber', phoneNumber);
}



Future<void> _login() async {
  if (!_formKey.currentState!.validate()) return;

  final request = LoginRequest(
    countryCode: "+91",
    phoneNumber: _phoneNumberController.text,
  );

  try {
    final response = await http.post(
      Uri.parse('https://api.vezigo.in/v1/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(request.toJson()),
    );

    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');

    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = jsonDecode(response.body);
      final loginResponse = LoginResponse.fromJson(data);
        await _saveUserData('Your Name', _phoneNumberController.text); 

      if (loginResponse.message != '' && loginResponse.message.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(loginResponse.message)),
        );

        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) =>  OtpScreen(
              phoneNumber: _phoneNumberController.text,
              countryCode: '+91',
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
        const  SnackBar(content: Text('Login successful, but no message provided')),
        );
      }
    } else {
      final errorData = jsonDecode(response.body);
      final errorMessage = errorData['message'] ?? 'Failed to sign up';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage)),
      );
    }
  } catch (e) {
    print('Error: $e');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('An error occurred: $e')),
    );
  }
}


  @override
  void initState() {
    super.initState();
    _mobileNumberFocusNode.addListener(_handleFocusChange);
  }

  void _handleFocusChange() {
    if (_mobileNumberFocusNode.hasFocus 
     && Platform.isIOS 
    ) { 
      _showDoneButton();
    } else {
      _removeDoneButton();
    }
  }

  void _showDoneButton() {
    _overlayEntry = _createOverlayEntry();
    Overlay.of(context).insert(_overlayEntry!);
  }

  void _removeDoneButton() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  OverlayEntry _createOverlayEntry() {
    return OverlayEntry(
      builder: (context) => Positioned(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 0,
        right: 0,
        child: Material(
          color: Colors.transparent,
          child: Container(
            height: 45.0,
            color: Colors.grey.shade300,
            child: Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: const EdgeInsets.only(right: 16.0),
                child: TextButton(
                  onPressed: () {
                    _mobileNumberFocusNode.unfocus();
                    if (_formKey.currentState!.validate()) {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (context) =>  OtpScreen(
                            countryCode: '+91',
                            phoneNumber: _phoneNumberController.text,
                          ),
                        ),
                      );
                    }
                  },
                  child: const Text(
                    'Done',
                    style: TextStyle(color: Colors.black),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _mobileNumberFocusNode.removeListener(_handleFocusChange);
    _mobileNumberFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            color: AppColors.appbarColor,
          ),
          child: SafeArea(
            child: Column(
              children: [
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: Center(
                      child: Image(image: AssetImage('assets/images/vezigo.png',),height: 110,),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(30.0),
                        child: SingleChildScrollView(
                          child: Form(
                            key: _formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Mobile Number',
                                  style: TextStyle(
                                      fontSize: 15, fontWeight: FontWeight.w800),
                                ),
                                const SizedBox(height: 10),
                               TextFormField(
                                controller: _phoneNumberController,
                                textInputAction: TextInputAction.done,
                                keyboardType: TextInputType.phone,
                                focusNode: _mobileNumberFocusNode,
                                decoration: InputDecoration(
                                 hintText: '+91',
                                  hintStyle: TextStyle(
                                  color: Colors.grey.shade400,
                                  fontSize: 14,
                                 ),
                                  border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                               ),
                                validator: (value) {
                                 if (value == null || value.isEmpty) {
                                  return 'Please enter your mobile number';
                               }
                                if (value.length != 10) {
                                  return 'Mobile number must be 10 digits';
                                }
                                return null;
                              },
                                onChanged: (value) {
                               
                              },
                                inputFormatters: [
                                LengthLimitingTextInputFormatter(10),
                               FilteringTextInputFormatter.digitsOnly,
                             ],
                             autofocus: true,
                            ),

                                const SizedBox(height: 20),
                                const SizedBox(height: 30),
                                Center(
                                  child: ElevatedButton(
                                     onPressed:_login,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.appbarColor,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      textStyle: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      foregroundColor: Colors.white,
                                      padding: EdgeInsets.symmetric(
                                        horizontal: MediaQuery.of(context).size.width * 0.3,
                                        vertical: MediaQuery.of(context).size.height * 0.02,
                                      ),
                                    ),
                                    child: const Text('Get OTP',style: TextStyle(color: AppColors.textColor),),
                                  ),
                                ),
                                const SizedBox(height: 20),
                                Center(
                                  child: TextButton(
                                    onPressed: () {
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (context) =>const  SignupScreen(),
                                        ),
                                      );
                                    },
                                    child:  Text(
                                      'SignUp',
                                      style: TextStyle(color: AppColors.buttonColor),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
