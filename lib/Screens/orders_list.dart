import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:vezigo/models/colors.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vezigo/Screens/order_details.dart';
import '../Api_Models/order_lists.dart';
import 'package:intl/intl.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  List orders = [];
  bool isLoading = true;

  final String apiUrl = "https://api.vezigo.in/v1/app/orders";

  @override
  void initState() {
    super.initState();
    fetchOrders();
  }

  Future<void> fetchOrders() async {
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
        OrdersResponse ordersResponse = OrdersResponse.fromJson(decodedData);

        setState(() {
          orders = ordersResponse.data.results;
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load orders');
      }
    } catch (e) {
      print('Error fetching orders: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:  Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: AppColors.appbarColor,
        title:const Text("My Orders"),
      ),
      body: isLoading
          ?const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: orders.length,
              itemBuilder: (context, index) {
                final order = orders[index];
                final orderId = order.id;
                final orderDate = order.createdAt; 
                final items = order.items;
                final userAddress = order.userDetails.address;
                final firstItem = items.isNotEmpty ? items[0] : null;
                final imageUrl =
                    firstItem != null ? firstItem.product.imageUrl : '';
                // final itemCount = items.length > 3 ? 3 : items.length;
                 DateTime parsedDate = DateTime.parse(orderDate); 
                 String formattedDate = DateFormat("d MMM, yyyy").format(parsedDate);

                return GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(MaterialPageRoute(builder: (ctx) => OrderDetails(id: orderId)));
                  },
                  child: Container(
                    margin:
                    const EdgeInsets.symmetric(vertical: 4),
                    color: Colors.white,
                    child: Padding(
                      padding:
                      const EdgeInsets.only(left: 2,right: 12,top: 5),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                "    Order ID:",
                                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
                              ),
                              Text(
                                orderId,
                                style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
                              ),
                            ],
                          ),
                          const Divider(thickness: 0.3),
                          if (firstItem != null)
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 0),
                              child: Row(
                                children: [
                                   Container(
                                    width: 100,
                                    height: 90,
                                    margin: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                     color: AppColors.lightTheme,
                                     borderRadius: BorderRadius.circular(10),
                                   ),
                                    child: ClipRRect(
                                     borderRadius: BorderRadius.circular(10),
                                     child: Image.network(
                                      imageUrl,
                                       fit: BoxFit.cover,
                                       errorBuilder: (context, error, stackTrace) =>const Icon(Icons.image_not_supported),
                                    ),
                                   ),
                                 ),
                                 Expanded(
                                  child: Column(
                                   crossAxisAlignment: CrossAxisAlignment.start,
                                     children: [
                                     if (items.isNotEmpty)
                                      Text(
                                       items.take(3).map((item) => item.product.title).join(' || '),
                                         style:
                                         const TextStyle(
                                          fontWeight: FontWeight.bold,
                                           fontSize: 16,
                                         ),
                                        ),
                                       if (items.length > 3) 
                                       Text(
                                         "+ ${items.length - 3} more",
                                        style:const TextStyle(
                                        fontWeight: FontWeight.normal,
                                        fontSize: 14,
                                        color: Colors.grey,
                                       ),
                                     ),
                                     Text(
                                      userAddress,
                                      style:
                                      const TextStyle(color: Colors.grey),
                                    ),
                                  const  SizedBox(height: 10,),
                                   Container(
                                     padding: 
                                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                     decoration: BoxDecoration(
                                        color: AppColors.buttonColor,
                                        borderRadius: BorderRadius.circular(12),
                                    ), child:
                                    const Text(
                                     'Delivered',
                                     style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                      Align(
                                       alignment: Alignment.centerRight,
                                       child: Text(formattedDate, 
                                        style: TextStyle(color: Colors.grey.shade800, fontSize: 12)),
                                     ),
                                  ],
                               ),
                             ),
                           ],
                          ),
                         ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          );
       }
     }

