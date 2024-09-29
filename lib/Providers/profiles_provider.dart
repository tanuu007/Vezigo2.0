import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';


class ProfileProvider with ChangeNotifier {
  String _name = 'Loading...';
  String _lastLogin = 'Loading...';
  

                
  String get name => _name;
  String get lastLogin => _lastLogin;

Future<void> fetchProfile() async {
    const String url = 'https://api.vezigo.in/v1/app/profile';
    final prefs = await SharedPreferences.getInstance();
    final accessToken = prefs.getString('accessToken');
    
    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
      );

      if (response.statusCode == 200) {
        
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
       
       
        _name = jsonResponse['data']['name'];

        
        final DateTime parsedDate = DateTime.parse(jsonResponse['data']['createdAt']);
        _lastLogin = DateFormat('d MMM, y').format(parsedDate); 
        
        notifyListeners();
      } else {
        throw Exception('Failed to load profile');
      }
    } catch (error) {
      _name = 'Error';
      _lastLogin = 'Error';
      notifyListeners();
    }
  }

  Future<void> updateProfile(String newName, String newEmail) async {
    const String url = 'https://api.vezigo.in/v1/app/profile';
    final prefs = await SharedPreferences.getInstance();
    final accessToken = prefs.getString('accessToken');


    try {
      final response = await http.patch(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: json.encode({
          'name': newName,
          'email': newEmail,
        }),
      );

      if (response.statusCode == 200) {
        final responseBody = json.decode(response.body);
        print(responseBody);

        _name = responseBody['data']['name'];
        notifyListeners();

        await prefs.setString('name', _name);
        await prefs.setString('email', responseBody['data']['email']);
      } else {
        throw Exception('Failed to update profile');
      }
    } catch (error) {
      print('Error updating profile: $error');
    }
  }
}
