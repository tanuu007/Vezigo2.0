import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vezigo/Auth/otp.dart';
import 'package:vezigo/models/colors.dart';
import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:vezigo/Api_Models/signup_model.dart';
import 'package:provider/provider.dart';
import 'package:vezigo/Providers/signup_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final FocusNode _mobileNumberFocusNode = FocusNode();
  OverlayEntry? _overlayEntry;


   final TextEditingController _nameController = TextEditingController();
    final TextEditingController _phoneNumberController = TextEditingController();

    Future<void> _saveUserData(String name, String phoneNumber) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString('name', name);
  await prefs.setString('phoneNumber', phoneNumber);
}


 Future<void> _signup() async {
    if (!_formKey.currentState!.validate()) return;

    final request = SignupRequest(
      name: _nameController.text,
      countryCode: "+91",  
      phoneNumber: _phoneNumberController.text,
    );

    try {
      final response = await http.post(
        Uri.parse('https://api.vezigo.in/v1/auth/signup'), 
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(request.toJson()),
      );
    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');

     if (response.statusCode == 201) {
        await _saveUserData(request.name, request.phoneNumber);
        
        Provider.of<SignupProvider>(context, listen: false)
            .setSignupDetails(request.name, request.countryCode, request.phoneNumber);
        
     
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => OtpScreen(phoneNumber: _phoneNumberController.text, countryCode: '+91'),
          ),
        );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
      const  SnackBar(content: Text('Failed to sign up')),
      );
    }
  } catch (e) {
    print('Error: $e'); 
    ScaffoldMessenger.of(context).showSnackBar(
   const   SnackBar(content: Text('An error occurred')),
    );
  }
}



 @override
void initState() {
  super.initState();
  WidgetsBinding.instance.addPostFrameCallback((_) {
    FocusScope.of(context).requestFocus(_mobileNumberFocusNode);
  });

  _mobileNumberFocusNode.addListener(_handleFocusChange);
}

  void _handleFocusChange() {
    if (_mobileNumberFocusNode.hasFocus && Platform.isIOS) {
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
                    _signup();
                    }
                  },
                  child: const Text(
                    'Done',
                    style: TextStyle(color: Colors.black, fontSize: 15),
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
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
                    child: Align(
                      alignment: Alignment.topLeft,
                      child: Center(
                          child: Image(image: AssetImage('assets/images/vezigo.png',),height: 110,),
                      
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Container(
                          width: MediaQuery.of(context).size.width * 0.9,
                          height: MediaQuery.of(context).size.height * 0.8,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(30.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Mobile Number',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                TextFormField(
                                  controller: _phoneNumberController,
                                  focusNode: _mobileNumberFocusNode,
                                  textInputAction: TextInputAction.next,
                                  decoration: InputDecoration(
                                    hintText: '+91',
                                    hintStyle: TextStyle(color: Colors.grey.shade400,fontSize: 14),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  keyboardType: TextInputType.phone,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter your mobile number.';
                                    }
                                    if (value.length != 10) {
                                      return 'Mobile number should be exactly 10 digits.';
                                    }
                                    return null;
                                  },
                                  onChanged: (value) {
                             
                                  },
                                  inputFormatters: [
                                    LengthLimitingTextInputFormatter(10),
                                    FilteringTextInputFormatter.digitsOnly,
                                  ],
                                ),
                                const SizedBox(height: 20),
                                const Text(
                                  'Full Name',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                TextFormField(
                                  controller: _nameController,
                                  textInputAction: TextInputAction.next,
                                  keyboardType: TextInputType.name,
                                  decoration: InputDecoration(
                                    hintText: 'Enter your name',
                                    hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter your full name.';
                                    }
                                    return null;
                                  },
                                ),
                               
                                const SizedBox(height: 30),
                                Center(
                                  child:ElevatedButton(
  onPressed: _signup,
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
  child: const Text('SignUp', style: TextStyle(color: AppColors.textColor)),
),

                                ),
                                const SizedBox(height: 20),
                                Center(
                                  child: TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                    child:  Text(
                                      'Login',
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
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
