import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async'; 
import 'dart:io';
import 'package:vezigo/models/bottom_bar.dart';
import 'package:vezigo/models/colors.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:vezigo/Api_Models/otp_model.dart';
import 'package:vezigo/Api_Models/login_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OtpScreen extends StatefulWidget {
  const OtpScreen({super.key,required this.phoneNumber, required this.countryCode});
  final phoneNumber;
  final countryCode;

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isButtonEnabled = true;
  final FocusNode _otpFocusNode = FocusNode();
  Timer? _timer;
  OverlayEntry? _overlayEntry;
    final TextEditingController _otpController = TextEditingController();


Future<void> _verifyOtp() async {
  if (_formKey.currentState!.validate()) {
    final otp = _otpController.text;
    const url = 'https://api.vezigo.in/v1/auth/verify-otp';

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'phoneNumber': widget.phoneNumber,
          'countryCode': widget.countryCode,
          'otp': otp,
        }),
      );

      print('Response status: ${response.statusCode}');
      print('Response headers: ${response.headers}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {  
        final data = jsonDecode(response.body);
        final otpResponse = OtpResponse.fromJson(data);
        print(otpResponse);

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('accessToken', otpResponse.data.tokens.access.token);
        await prefs.setString('refreshToken', otpResponse.data.tokens.refresh.token);

        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) =>const BottomBars(), 
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Invalid OTP or server error. Status code: ${response.statusCode}')),
        );
      }
    } catch (e) {
      print('Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred: $e')),
      );
    }
  }
}

Future<void> _reSendOtp() async {
  final request = LoginRequest(
    countryCode: widget.countryCode,
    phoneNumber: widget.phoneNumber,
  );

  try {
    final response = await http.post(
      Uri.parse('https://api.vezigo.in/v1/auth/resend-otp'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(request.toJson()),
    );

    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');

    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = jsonDecode(response.body);
      final loginResponse = LoginResponse.fromJson(data);

      if (loginResponse.message != '' && loginResponse.message.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(loginResponse.message)),
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
    _startResendOtpTimer();
    _otpFocusNode.addListener(_handleFocusChange); 
  }

  @override
  void dispose() {
    _timer?.cancel();
    _otpFocusNode.removeListener(_handleFocusChange);  
    _otpFocusNode.dispose();
    super.dispose();
  }

  void _startResendOtpTimer() {
    setState(() {
      _isButtonEnabled = false;
    });

    _timer = Timer(const Duration(seconds: 30), () {
      setState(() {
        _isButtonEnabled = true;
      });
    });
  }

  void _handleFocusChange() {
    if (_otpFocusNode.hasFocus && Platform.isIOS) {
      _showDoneButton();
    } else {
      _removeDoneButton();
    }
  }

  void _showDoneButton() {
    if (_overlayEntry == null) {
      _overlayEntry = _createOverlayEntry();
      Overlay.of(context).insert(_overlayEntry!);
    }
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
                    _otpFocusNode.unfocus();  
                    if (_formKey.currentState!.validate()) {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (context) =>const BottomBars()
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.appbarColor,
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: const Icon(Icons.cancel),
        ),
      ),
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
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 0.0),
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: Center(
                      child: Image(
                        image: AssetImage('assets/images/vezigo.png'),
                        height: 110,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      width: MediaQuery.of(context).size.width * 0.9,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(30.0),
                        child: Form(
                          key: _formKey,
                          child: SingleChildScrollView(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Enter OTP',
                                  style: TextStyle(
                                      fontSize: 15, fontWeight: FontWeight.w800),
                                ),
                                const SizedBox(height: 10),
                                TextFormField(
                                  controller: _otpController,
                                  focusNode: _otpFocusNode, 
                                  textInputAction: TextInputAction.done,
                                  keyboardType: TextInputType.number,
                                  decoration: InputDecoration(
                                    hintText: '000000',
                                    hintStyle: TextStyle(
                                        color: Colors.grey.shade400, fontSize: 14),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter the OTP';
                                    }
                                    if (value.length != 6) {
                                      return 'OTP must be 6 digits';
                                    }
                                    return null;
                                  },
                                  autofocus: true,
                                  inputFormatters: [
                                    LengthLimitingTextInputFormatter(6),
                                  ],
                                ),
                                const SizedBox(height: 20),
                                const SizedBox(height: 30),
                                Center(
                                  child: ElevatedButton(
                                    onPressed:_verifyOtp,
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
                                        horizontal:
                                            MediaQuery.of(context).size.width *
                                                0.3,
                                        vertical:
                                            MediaQuery.of(context).size.height *
                                                0.02,
                                      ),
                                    ),
                                    child: const Text(
                                      'Login',
                                      style: TextStyle(color: AppColors.textColor),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 20),
                                Center(
                                  child: TextButton(
                                    onPressed: _isButtonEnabled
                                        ? () {
                                           _reSendOtp();
                                          }
                                        : null,
                                    child: Text(
                                      'Resend OTP',
                                      style: TextStyle(
                                        color: _isButtonEnabled
                                            ? AppColors.buttonColor
                                            : Colors.grey,
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
