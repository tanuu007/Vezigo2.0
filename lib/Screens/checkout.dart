import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vezigo/Models/add_model.dart';
import 'package:vezigo/Models/colors.dart';
import 'package:vezigo/Providers/add_provider.dart';
import 'package:vezigo/Providers/item_provider.dart';
import 'package:vezigo/Screens/delivery_loc.dart';
import 'package:vezigo/Models/radiobutton.dart';
import 'package:vezigo/Screens/edit_loc.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {

   int? _selectedAddressIndex;

  
Future<void> postData(Cart cart, Address selectedAddress) async {
 const  url = 'https://api.vezigo.in/v1/orders';

  final body = {
    "items": cart.items.map((cartItem) {
      return {
        "pack": {
          "price": cartItem.price,
          "unit": cartItem.package.unit,
          "quantity": cartItem.quantity,
        },
        "product": cartItem.package.id,
        "quantity": cartItem.quantity
      };
    }).toList(),
    "billAmount": cart.totalAmount.toStringAsFixed(2),
    "userDetails": {
      "name": selectedAddress.yourName,
      "phoneNumber": selectedAddress.phoneNumber,
      "altPhoneNumber": selectedAddress.alternatePhoneNumber,
      "address": "${selectedAddress.houseNumber}, ${selectedAddress.landmark}",
      "notes": selectedAddress.notes
    },
    "geo": {
      "lat": selectedAddress.latitude.toString(),
      "lng": selectedAddress.longitude.toString()
    }
  };

  final prefs = await SharedPreferences.getInstance();
  final accessToken = prefs.getString('accessToken');

  try {
    final response = await http.post(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
      body: json.encode(body),
    );

    
    print('Status Code: ${response.statusCode}');
    print('Response body: ${response.body}');

    if (response.statusCode == 201) {
      final responseBody = json.decode(response.body);
      final orderId = responseBody['data']['id'];

      
      _showOrderSuccessfulPopup(context, orderId);
    } else {
  
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Failed to create the order. Status code: ${response.statusCode}"),
        ),
      );
    }
  } catch (e) {
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("An error occurred: $e"),
      ),
    );
  }
}


void _showOrderSuccessfulPopup(BuildContext context, String orderId) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Image.asset('assets/payment/tick.png'),
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Order Successful',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black,
                fontSize: 30,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Your order #$orderId has been placed successfully!',
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.buttonColor,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 50, vertical: 15,
                    ),
                  ),
                  onPressed: () {},
                  child: const Text('Track my Order',
                    style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.w800)),
                ),
                const SizedBox(height: 18),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    side:  BorderSide(
                      color: AppColors.buttonColor, width: 1,
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 70, vertical: 15,
                    ),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child:  Text('Go Back',
                    style: TextStyle(
                      color: AppColors.buttonColor,
                      fontWeight: FontWeight.w800)),
                ),
                const SizedBox(height: 20)
              ],
            ),
          ),
        ],
      );
    },
  );
}
  @override
  Widget build(BuildContext context) {
    final addresses = Provider.of<AddressProvider>(context).addresses;
    final cart = Provider.of<Cart>(context);

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: AppColors.appbarColor,
        title: const Text('CheckOut', style: TextStyle(color: AppColors.textColor)),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Address',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ConfirmDeliveryLocationScreen(),
                      ),
                    );
                  },
                  child:  Text('Add New',
                      style:
                          TextStyle(color: AppColors.buttonColor)),
                ),
              ],
            ),
          ),
          if (addresses.isEmpty)
            Expanded(
              child: Center(
                child: IconButton(
                  icon:  Icon(Icons.add, color: AppColors.buttonColor, size: 60),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ConfirmDeliveryLocationScreen(),
                      ),
                    );
                  },
                ),
              ),
            )
          else
            Expanded(
              child: ListView.builder(
                itemCount: addresses.length,
                itemBuilder: (context, index) {
                  final address = addresses[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 8.0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10.0),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.shade200,
                            spreadRadius: 2,
                            blurRadius: 5,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: ListTile(
                        title:    Text(address.addressType,),
      subtitle:  Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('${address.houseNumber}, ${address.landmark}'),
          const SizedBox(height: 3),
          // Text('Name: ${address.yourName}'),
          // Text('Phone Number: ${address.phoneNumber}'),
        ],
      ),
                        
                        
                        leading: CustomRadioButton(
                          isSelected: _selectedAddressIndex == index,
                          onTap: () {
                            setState(() {
                              _selectedAddressIndex = index;
                            });
                          },
                        ),
                       trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => EditAddressScreen(
                                      address: address,
                                      index: index,
                                      id: address.phoneNumber,
                                    ),
                                  ),
                                );
                              },
                            ),
                          IconButton(
  icon: const Icon(Icons.delete_outline),
  onPressed: () async {
    final confirmed = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Confirm Delete'),
        content: Text('Are you sure you want to delete this address?'),
        actions: [
          TextButton(
            child: Text('No'),
            onPressed: () => Navigator.of(context).pop(false),
          ),
          TextButton(
            child: Text('Yes'),
            onPressed: () => Navigator.of(context).pop(true),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      Provider.of<AddressProvider>(context, listen: false)
          .deleteAddress(address.phoneNumber);
    }
  },
),

                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
        const  SizedBox(height: 32,)
        ],
      ),
      
      bottomNavigationBar: Container(
        color: Colors.white,
        height: MediaQuery.of(context).size.height * 0.15,
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Total Price',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18,color: AppColors.textColor),
                  ),
                  Text(
                    '₹${cart.totalAmount.toStringAsFixed(2)}',
                    style:const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textColor,
                     ),
                  ),
                ],
              ),
            ),
           ElevatedButton(
  onPressed: () {
    if (_selectedAddressIndex != null) {
     
      final selectedAddress = addresses[_selectedAddressIndex!];
      postData(cart, selectedAddress);
    } else {
     
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please select an address."),
        ),
      );
    }
  },
  style: ElevatedButton.styleFrom(
    backgroundColor: AppColors.buttonColor,
    padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
  ),
  child: const Text(
    'Place Order',
    style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
  ),
),

          ],
        ),
      ),
    );
  }
}



