import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../Models/add_model.dart';
import 'package:vezigo/Api_Models/get_address.dart';

class AddressProvider extends ChangeNotifier {
  final List<Address> _addresses = [];

  List<Address> get addresses => List.unmodifiable(_addresses);

  //fetch address
  Future<void> fetchAddresses() async {
    const String apiUrl = "https://api.vezigo.in/v1/app/address";
    final prefs = await SharedPreferences.getInstance();
    final accessToken = prefs.getString('accessToken');

    try {
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {
          "Authorization": "Bearer $accessToken",
          "Content-Type": "application/json",
        },
      );

      if (response.statusCode == 200) {
        final decodedData = jsonDecode(response.body);
        debugPrint("Location Data : ${decodedData["data"]}");
        final List<Result> results =
            Data.fromJson(decodedData['data']).results!;
        _addresses.clear();

        for (var result in results) {
          _addresses.add(Address(
            addressType: result.label ?? "Unknown",
            houseNumber: result.text ?? "",
            landmark: result.description ?? "",
            yourName: result.user ?? "",
            phoneNumber: result.id ?? "",
            alternatePhoneNumber: "",
            notes: "",
            latitude: null,
            longitude: null,
          ));
        }

        notifyListeners();
      } else {
        throw Exception('Failed to load addresses');
      }
    } catch (e) {
      print('Error fetching addresses: $e');
      rethrow;
    }
  }

  //delete address

  Future<void> deleteAddress(String id) async {
    const String apiUrl = "https://api.vezigo.in/v1/app/address";
    final prefs = await SharedPreferences.getInstance();
    final accessToken = prefs.getString('accessToken');

    try {
      final response = await http.delete(
        Uri.parse('$apiUrl/$id'),
        headers: {
          "Authorization": "Bearer $accessToken",
          "Content-Type": "application/json",
        },
      );

      if (response.statusCode == 200) {
        print(response.body);
        _addresses.removeWhere((address) => address.phoneNumber == id);
        notifyListeners();
      } else {
        throw Exception('Failed to delete address');
      }
    } catch (e) {
      print('Error deleting address: $e');
      rethrow;
    }
  }

  void addAddress(Address address) {
    _addresses.add(address);
    notifyListeners();
  }

  void updateAddress(int index, Address updatedAddress) {
    if (index >= 0 && index < _addresses.length) {
      _addresses[index] = updatedAddress;
      notifyListeners();
    }
  }
}
